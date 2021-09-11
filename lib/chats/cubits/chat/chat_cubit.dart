import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:safechat/chats/cubits/attachment/attachment_cubit.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/chats/repository/chats_repository.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatState chatState}) : super(chatState) {
    print({'INIT CHAT', state.id});
    _wsService.socket.emit('join-chat', state.id);

    _wsService.socket.on('msg', (data) {
      print({'ALAKALKSKSLDKASD', data['msg']});
      if (data['room'] == state.id) {
        data['msg']['unreadBy'] = [
          ...state.participants.map((e) => e.id)
            ..where((id) => id != data['msg']['sender'])
        ];

        print({'ALAKALKSKSLDKASD', data['msg']});

        final msg = Message.fromJson(data['msg']);

        emit(state.copyWith(messages: [
          msg.copyWith(
              content: msg.content.map((item) {
            print(item.data);
            return item.copyWith(
              data: _encryptionService.chachaDecrypt(
                item.data,
                state.sharedKey,
              ),
            );
          }).toList()),
          // Message(
          //   id: data['msg']['id'],
          //   sender: data['msg']['sender'],
          //   content: (data['msg']['content'] as List).map((msg) {
          //     return MessageItem(
          //         type: MessageType.values.firstWhere(
          //           (e) => describeEnum(e) == msg['type'],
          //         ),
          //         data: utf8.decode(
          //           _encryptionService.chachaDecrypt(
          //             msg['data'],
          //             state.sharedKey,
          //           ),
          //         ));
          //   }).toList(),
          //   // [
          //   //   MessageContent(
          //   //     type: MessageType.values.firstWhere(
          //   //       (e) => describeEnum(e) == data['msg']['type'],
          //   //     ),
          //   //     data: utf8.decode(
          //   //       _encryptionService.chachaDecrypt(
          //   //         data['msg']['data'],
          //   //         state.sharedKey,
          //   //       ),
          //   //     ),
          //   //   )
          //   // ],
          //   unreadBy: [
          //     ...state.participants.map((e) => e.contact.id)
          //       ..where((id) => id != data['msg']['sender'])
          //   ],
          // ),
          ...state.messages,
        ]));
      }
    });

    _wsService.socket.on('messages.readby', (data) {
      if (data['room'] == state.id) {
        final newMessages = List.of(state.messages);

        for (var i = 0; i < newMessages.length; i++) {
          newMessages[i].unreadBy.removeWhere((u) => u == data['userId']);
        }

        emit(state.copyWith(messages: [...newMessages]));
      }
    });

    _wsService.socket.on('typing.toggle', (participantId) {
      emit(state.copyWith(
        typing: state.typing.contains(participantId)
            ? [...List.of(state.typing)..remove(participantId)]
            : [...state.typing, participantId],
      ));
    });

    // _wsService.socket.on('typing.start', (participantId) {
    //   emit(state.copyWith(typing: [...state.typing, participantId]));
    // });

    // _wsService.socket.on('typing.stop', (participantId) {
    //   emit(state.copyWith(
    //     typing: List.of(state.typing)..removeWhere((e) => e == participantId),
    //   ));
    // });
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

  Future<File> getAttachment(String attachmentName) async {
    final cacheManager = DefaultCacheManager();

    var cachedFile = await cacheManager.getFileFromCache(attachmentName);

    if (cachedFile != null) {
      return cachedFile.file;
    }

    final attachment = await _chatsRepository.getAttachment(
      state.id,
      attachmentName,
      state.sharedKey,
    );

    return await cacheManager.putFile(attachmentName, attachment);
  }

  sendMessage(List<AttachmentState> attachments) async {
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
          data: attachmentName));

      final file = File(attachments[i].name).readAsBytesSync();

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
          unreadBy: [...state.participants.map((e) => e.id)],
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

    toggleTyping(encryptedMessage.sender);

    // this._wsService.socket.emit('msg', {
    //   'room': state.id,
    //   'msg': encryptedMessage.toJson(),
    // });

    emit(state.copyWith(
      messages: [
        state.messages[0].copyWith(status: MessageStatus.SENT),
        ...state.messages.sublist(1)
      ],
    ));
  }

  readAllMessages() async {
    print("READ ALL MESSAGES");

    await _chatsRepository.readAllMessages(state.id);

    _wsService.socket.emit('messages.readall', {
      'room': state.id,
    });
  }

  // setMessageType(MessageType type) {
  //   emit(state.copyWith(
  //     newMessage: state.newMessage.copyWith(type: type),
  //   ));
  // }

  textMessageChanged(String value) {
    emit(state.copyWith(
      message: state.message.copyWith(
        content: List.of(state.message.content)
          ..removeWhere((e) => e.type == MessageType.TEXT)
          ..add(MessageItem(type: MessageType.TEXT, data: value)),
      ),
    ));
  }

  toggleTyping(String participantId) {
    _wsService.socket.emit('typing.toggle', {
      'room': state.id,
      'participantId': participantId,
    });
  }

  // startTyping(String participantId) {
  //   _wsService.socket.emit('typing.start', {
  //     'room': state.id,
  //     'participantId': participantId,
  //   });
  // }

  // stopTyping(String participantId) {
  //   _wsService.socket.emit('typing.stop', {
  //     'room': state.id,
  //     'participantId': participantId,
  //   });
  // }
}
