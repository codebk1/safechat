import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:safechat/chats/cubits/attachment/attachment_cubit.dart';
import 'package:safechat/chats/cubits/message/message_cubit.dart';
import 'package:safechat/chats/repository/chats_repository.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatState chatState}) : super(chatState) {
    // print({'INIT CHAT', state.id});
    _wsService.socket.emit('join-chat', state.id);

    _wsService.socket.on('msg', (data) {
      print({'participants', state.participants.length});
      if (data['room'] == state.id) {
        data['msg']['unreadBy'] = state.participants
            .map((e) => e.id)
            .where((id) => id != data['msg']['sender']);

        final msg = MessageState.fromJson(data['msg']);

        print(data['msg']['unreadBy']);
        print({'msg.unreadBy', msg.unreadBy});

        emit(state.copyWith(isNewMessage: true, messages: [
          msg.copyWith(
              content: msg.content.map((item) {
            if (item.type == MessageType.TEXT) {
              return item.copyWith(
                data: utf8.decode(
                  _encryptionService.chachaDecrypt(
                    item.data,
                    state.sharedKey,
                  ),
                ),
              );
            }

            return item;
          }).toList()),
          ...state.messages,
        ]));

        _wsService.socket.emit('messages.readall', {
          'room': state.id,
        });
      }
    });

    _wsService.socket.on('messages.readby', (data) {
      if (data['room'] == state.id) {
        final newMessages = List.of(state.messages);

        for (var i = 0; i < newMessages.length; i++) {
          newMessages[i] = newMessages[i].copyWith(
              unreadBy: List.of(newMessages[i].unreadBy)
                ..removeWhere((id) => id == data['userId']));
        }

        emit(state.copyWith(messages: newMessages));
      }
    });

    _wsService.socket.on('typing.start', (participantId) {
      emit(state.copyWith(typing: [...state.typing, participantId]));
    });

    _wsService.socket.on('typing.stop', (participantId) {
      emit(state.copyWith(
        typing: List.of(state.typing)..removeWhere((e) => e == participantId),
      ));
    });
  }

  final _wsService = SocketService();
  final _chatsRepository = ChatsRepository();
  final _encryptionService = EncryptionService();

  getMessages() async {
    emit(state.copyWith(listStatus: ListStatus.loading));

    final messages = await _chatsRepository.getMessages(
      state.id,
      state.sharedKey,
    );

    emit(state.copyWith(
      messages: messages.reversed.toList(),
      listStatus: ListStatus.success,
    ));
  }

  Future<File> getAttachment(AttachmentState attachment,
      {bool thumbnail = true}) async {
    final cacheManager = DefaultCacheManager();
    var attachmentName = attachment.name;

    if (attachment.type != AttachmentType.FILE && thumbnail) {
      attachmentName = '${attachment.name.split('.').first}_thumb.jpg';
    }

    var cachedFile = await cacheManager.getFileFromCache(attachmentName);

    if (cachedFile != null) {
      return cachedFile.file;
    }

    final attachmentFile = await _chatsRepository.getAttachment(
      state.id,
      attachmentName,
      state.sharedKey,
    );

    return await cacheManager.putFile(attachmentName, attachmentFile);
  }

  sendMessage(String senderId, List<AttachmentState> attachments) async {
    DefaultCacheManager cacheManager = DefaultCacheManager();
    List<MultipartFile> encryptedAttachments = [];
    List<MessageItem> items = [];

    for (var i = 0; i < attachments.length; i++) {
      final attachmentName =
          '${DateTime.now().millisecondsSinceEpoch}_$i.${attachments[i].name.split('.').last}';

      items.add(MessageItem(
        type: MessageType.values.firstWhere(
          (e) => describeEnum(e) == describeEnum(attachments[i].type),
        ),
        data: attachmentName,
      ));

      final file = File(attachments[i].name).readAsBytesSync();

      // generate thumbnail for video or photo
      if (attachments[i].type != AttachmentType.FILE) {
        final thumbName = '${attachmentName.split('.').first}_thumb.jpg';

        Uint8List? thumb;

        if (attachments[i].type == AttachmentType.VIDEO) {
          thumb = await VideoThumbnail.thumbnailData(
            video: attachments[i].name,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 1024,
            quality: 50,
          );
        } else {
          var image = copyResize(
            decodeImage(file)!,
            width: 512,
            interpolation: Interpolation.nearest,
          );
          thumb = encodeJpg(image) as Uint8List;
        }

        encryptedAttachments.add(MultipartFile.fromBytes(
          _encryptionService.chachaEncrypt(
            thumb!,
            state.sharedKey,
          ),
          filename: thumbName,
        ));

        await cacheManager.putFile(thumbName, thumb);
      }

      encryptedAttachments.add(MultipartFile.fromBytes(
        _encryptionService.chachaEncrypt(
          file,
          state.sharedKey,
        ),
        filename: attachmentName,
      ));

      await cacheManager.putFile(attachmentName, file);
    }

    final newMessages = List.of(state.messages)
      ..insert(
        0,
        state.message.copyWith(
          status: MessageStatus.SENDING,
          content: [...state.message.content, ...items],
          unreadBy: state.participants
              .map((e) => e.id)
              .where((id) => id != senderId)
              .toList(),
        ),
      );

    emit(state.copyWith(
      messages: newMessages.toList(),
      message: state.message.copyWith(content: []),
    ));

    // szyfrowanie wiadomości tekstowej
    final encryptedMessage = state.messages[0].copyWith(
      content: state.messages[0].content.map((e) {
        if (e.type == MessageType.TEXT) {
          return e.copyWith(
              data: base64.encode(_encryptionService.chachaEncrypt(
            utf8.encode(e.data) as Uint8List,
            state.sharedKey,
          )));
        }

        return e;
      }).toList(),
    );

    await this._chatsRepository.addMessage(
          state.id,
          encryptedMessage,
          encryptedAttachments,
        );

    stopTyping(encryptedMessage.senderId);

    this._wsService.socket.emit('msg', {
      'room': state.id,
      'msg': encryptedMessage.toJson(),
    });

    emit(state.copyWith(
      messages: [
        state.messages[0].copyWith(status: MessageStatus.SENT),
        ...state.messages.sublist(1)
      ],
    ));
  }

  readAllMessages(String currentUserId) async {
    print("READ ALL MESSAGES");

    // final newMessages = List.of(state.messages);

    // for (var i = 0; i < newMessages.length; i++) {
    //   newMessages[i] = newMessages[i].copyWith(
    //       unreadBy: newMessages[i].unreadBy
    //         ..removeWhere((id) => id == currentUserId));
    // }

    // emit(state.copyWith(messages: newMessages));

    await _chatsRepository.readAllMessages(state.id);

    _wsService.socket.emit('messages.readall', {
      'room': state.id,
    });
  }

  textMessageChanged(String value) {
    emit(state.copyWith(
      message: state.message.copyWith(
        content: List.of(state.message.content)
          ..removeWhere((e) => e.type == MessageType.TEXT)
          ..add(MessageItem(type: MessageType.TEXT, data: value)),
      ),
    ));
  }

  startTyping(String participantId) {
    _wsService.socket.emit('typing.start', {
      'room': state.id,
      'participantId': participantId,
    });
  }

  stopTyping(String participantId) {
    _wsService.socket.emit('typing.stop', {
      'room': state.id,
      'participantId': participantId,
    });
  }
}
