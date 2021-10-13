import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safechat/chats/models/attachment.dart';
import 'package:safechat/chats/models/chat.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/chats/models/name.dart';
import 'package:safechat/chats/models/new_chat.dart';
import 'package:safechat/chats/repository/chats_repository.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/common/models/notification.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/utils/notification_service.dart';
import 'package:safechat/utils/utils.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(const ChatsState()) {
    _wsService.socket.on('msg', (data) async {
      final chat = await _findOrFetchChat(data['room']);
      var msg = Message.fromJson(data['msg']);

      print({'uuuuuuuuuu', chat.opened});
      if (chat.opened) {
        print({'USERRR IDDDD', _userRepository.user.id});
        msg = msg.copyWith(
          unreadBy: List.of(msg.unreadBy)..remove(_userRepository.user.id),
        );

        _chatsRepository.readAllMessages(chat.id);

        _wsService.socket.emit('messages.readall', {
          'room': chat.id,
        });
      }

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(messages: [
                    msg.copyWith(
                        content: msg.content.map((item) {
                      if (item.type == MessageType.text) {
                        return item.copyWith(
                          data: utf8.decode(
                            _encryptionService.chachaDecrypt(
                              item.data,
                              chat.sharedKey,
                            ),
                          ),
                        );
                      }

                      return item;
                    }).toList()),
                    ...chat.messages,
                  ])
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('messages.readby', (data) async {
      final chat = await _findOrFetchChat(data['room']);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(
                    messages: c.messages
                        .map((m) => m.copyWith(
                              unreadBy: List.of(m.unreadBy)
                                ..removeWhere((id) => id == data['userId']),
                            ))
                        .toList())
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('typing.start', (data) async {
      print('ON TYPING START');
      final chat = await _findOrFetchChat(data['room']);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(
                    typing: List.of(c.typing)..add(data['participantId']),
                  )
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('typing.stop', (data) async {
      final chat = await _findOrFetchChat(data['room']);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(
                    typing: List.of(c.typing)
                      ..removeWhere((e) => e == data['participantId']),
                  )
                : c)
            .toList(),
      ));
    });

    _notificationService.notification.listen((event) async {
      print('KAKAKAKAKAKAKAKAK');
      final chat = await _findOrFetchChat(event.data['chatId']);

      if (chat.opened == false) {
        final sender = chat.participants.firstWhere(
          (p) => p.id == event.data['senderId'],
        );

        final notification = NotificationData(
          id: event.data['chatId'],
          title: '${sender.firstName} ${sender.lastName}',
          body: utf8.decode(
            _encryptionService.chachaDecrypt(
              event.data['body'],
              chat.sharedKey,
            ),
          ),
          image: sender.avatar,
        );

        _notificationService.showNotification(notification);
      }
    });

    _notificationService.selectNotification.listen((chatId) async {
      final chat = await _findOrFetchChat(chatId);

      emit(state.copyWith(nextChat: chat));
    });
  }

  final _wsService = SocketService();
  final _encryptionService = EncryptionService();
  final _notificationService = NotificationService();
  final _cacheManager = DefaultCacheManager();

  final _userRepository = UserRepository();
  final _chatsRepository = ChatsRepository();

  Future<Chat> _findOrFetchChat(String chatId) async {
    var chat = state.chats.firstWhereOrNull(
      (c) => c.id == chatId,
    );

    if (chat == null) {
      chat = await _chatsRepository.getChat(chatId);
      emit(state.copyWith(chats: List.of(state.chats)..insert(0, chat)));
    }

    return chat;
  }

  Future<void> getChats() async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final chats = await _chatsRepository.getChats();

      for (var chat in state.chats) {
        _wsService.socket.emit('join-chat', chat.id);
      }

      emit(state.copyWith(chats: chats, listStatus: ListStatus.success));
    } on DioError catch (e) {
      print(e);
      emit(state.copyWith(listStatus: ListStatus.failure));
    } catch (e) {
      print(e);
      emit(state.copyWith(listStatus: ListStatus.failure));
    }
  }

  Future<Chat?> createChat(
    ChatType type,
    User creator,
    List<Contact> participants,
  ) async {
    try {
      emit(state.copyWith(
        newChat: state.newChat.copyWith(
          form: FormStatus.loading,
        ),
      ));

      final chat = await _chatsRepository.createChat(
        type,
        creator,
        participants,
      );

      emit(state.copyWith(
        chats: [...state.chats, chat],
        newChat: state.newChat.copyWith(
          selectedParticipants: [],
          form: FormStatus.success,
        ),
      ));

      return chat;
    } on DioError catch (e) {
      print(e);

      // emit(state.copyWith(
      //   status: FormStatus.failure(e.response?.data['message']),
      // ));
    } catch (e) {
      print(e);
      // emit(state.copyWith(
      //   status: FormStatus.failure(e.toString()),
      // ));
    }
  }

  // getMessages(Chat chat) async {
  //   final messages = await _chatsRepository.getMessages(
  //     chat.id,
  //     chat.sharedKey,
  //   );

  //   emit(state.copyWith(
  //     chats: List.of(state.chats)
  //         .map((c) => c.id == chat.id
  //             ? c.copyWith(messages: messages.reversed.toList())
  //             : c)
  //         .toList(),
  //   ));
  // }

  Future<File> getAttachment(Chat chat, Attachment attachment,
      {bool thumbnail = true}) async {
    final cacheManager = DefaultCacheManager();
    var attachmentName = attachment.name;

    if (attachment.type != AttachmentType.file && thumbnail) {
      attachmentName = '${attachment.name.split('.').first}_thumb.jpg';
    }

    var cachedFile = await cacheManager.getFileFromCache(attachmentName);

    if (cachedFile != null) {
      return cachedFile.file;
    }

    final attachmentFile = await _chatsRepository.getAttachment(
      chat.id,
      attachmentName,
      chat.sharedKey,
    );

    return await cacheManager.putFile(attachmentName, attachmentFile);
  }

  checkIfChatExist(List<String> participantsIDs) {}

  sendMessage(Chat chat, String senderId, List<Attachment> attachments) async {
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
      if (attachments[i].type != AttachmentType.file) {
        final thumbName = '${attachmentName.split('.').first}_thumb.jpg';

        Uint8List? thumb;

        if (attachments[i].type == AttachmentType.video) {
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
            chat.sharedKey,
          ),
          filename: thumbName,
        ));

        await cacheManager.putFile(thumbName, thumb);
      }

      encryptedAttachments.add(MultipartFile.fromBytes(
        _encryptionService.chachaEncrypt(
          file,
          chat.sharedKey,
        ),
        filename: attachmentName,
      ));

      await cacheManager.putFile(attachmentName, file);
    }

    final newMessage = chat.message.copyWith(
      senderId: senderId,
      status: MessageStatus.sending,
      content: [...chat.message.content, ...items],
      unreadBy: chat.participants
          .map((e) => e.id)
          .where((id) => id != senderId)
          .toList(),
    );

    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((c) => c.id == chat.id
              ? c.copyWith(
                  messages: c.messages..insert(0, newMessage),
                  message: chat.message.copyWith(content: []))
              : c)
          .toList(),
    ));

    // szyfrowanie wiadomości tekstowej
    final encryptedMessage = newMessage.copyWith(
      content: newMessage.content.map((e) {
        if (e.type == MessageType.text) {
          return e.copyWith(
              data: base64.encode(_encryptionService.chachaEncrypt(
            utf8.encode(e.data) as Uint8List,
            chat.sharedKey,
          )));
        }

        return e;
      }).toList(),
    );

    final messageId = await _chatsRepository.addMessage(
      chat.id,
      encryptedMessage,
      encryptedAttachments,
    );

    stopTyping(chat.id, encryptedMessage.senderId);

    _wsService.socket.emit('msg', {
      'room': chat.id,
      'msg': encryptedMessage.copyWith(id: messageId).toJson(),
    });

    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((c) => c.id == chat.id
              ? c.copyWith(messages: [
                  c.messages[0].copyWith(
                    id: messageId,
                    status: MessageStatus.sent,
                  ),
                  ...c.messages.sublist(1)
                ])
              : c)
          .toList(),
    ));
  }

  readAllMessages(Chat chat, String currentUserId) async {
    if (chat.messages.any((msg) => msg.unreadBy.contains(currentUserId))) {
      print("READ ALL MESSAGES");

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(
                    messages: c.messages
                        .map((m) => m.copyWith(
                              unreadBy: List.of(m.unreadBy)
                                ..removeWhere((id) => id == currentUserId),
                            ))
                        .toList())
                : c)
            .toList(),
      ));

      await _chatsRepository.readAllMessages(chat.id);

      _wsService.socket.emit('messages.readall', {
        'room': chat.id,
      });
    }
  }

  deleteMessages(String chatId) async {
    emit(state.copyWith(
      chats: List.of(state.chats)..removeWhere((chat) => chat.id == chatId),
    ));

    await _chatsRepository.deleteMessages(chatId);
  }

  deleteMessage(String chatId, String messageId) async {
    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((chat) => chat.id == chatId
              ? chat.copyWith(
                  messages: List.of(chat.messages)
                      .map((m) => m.id == messageId
                          ? m.copyWith(status: MessageStatus.deleting)
                          : m)
                      .toList(),
                )
              : chat)
          .toList(),
    ));

    await _chatsRepository.deleteMessage(chatId, messageId);

    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((chat) => chat.id == chatId
              ? chat.copyWith(
                  messages: List.of(chat.messages)
                    ..removeWhere((m) => m.id == messageId),
                )
              : chat)
          .toList(),
    ));
  }

  startTyping(String chatId, String participantId) {
    print('Start typing');
    _wsService.socket.emit('typing.start', {
      'room': chatId,
      'participantId': participantId,
    });
  }

  stopTyping(String chatId, String participantId) {
    _wsService.socket.emit('typing.stop', {
      'room': chatId,
      'participantId': participantId,
    });
  }

  openChat(String chatId) {
    print('OPEN CHAT');
    emit(state.copyWith(
        chats: List.of(state.chats)
            .map((chat) =>
                chat.id == chatId ? chat.copyWith(opened: true) : chat)
            .toList()));
  }

  closeChat(String chatId) {
    print('CLOSE CHAT');
    emit(state.copyWith(
        chats: List.of(state.chats)
            .map((chat) =>
                chat.id == chatId ? chat.copyWith(opened: false) : chat)
            .toList()));
  }

  textMessageChanged(String chatId, String value) {
    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((c) => c.id == chatId
              ? c.copyWith(
                  message: c.message.copyWith(
                  content: List.of(c.message.content)
                    ..removeWhere((e) => e.type == MessageType.text)
                    ..add(MessageItem(type: MessageType.text, data: value)),
                ))
              : c)
          .toList(),
    ));
  }

  toggleParticipant(Contact participant) {
    if (state.newChat.selectedParticipants.contains(participant)) {
      emit(state.copyWith(
        newChat: state.newChat.copyWith(
          selectedParticipants: List.of(state.newChat.selectedParticipants)
            ..removeWhere((e) => e == participant),
          form: FormStatus.init,
        ),
      ));
    } else {
      emit(state.copyWith(
        newChat: state.newChat.copyWith(
          selectedParticipants: List.of(state.newChat.selectedParticipants)
            ..add(participant),
          form: FormStatus.init,
        ),
      ));
    }
  }

  Future<void> editChatNameSubmit(String chatId) async {
    try {
      emit(state.copyWith(form: FormStatus.loading));

      await _chatsRepository.updateChatName(
        state.chats.firstWhere((chat) => chat.id == chatId),
        state.name.value,
      );

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((chat) => chat.id == chatId
                ? chat.copyWith(name: state.name.value)
                : chat)
            .toList(),
        form: FormStatus.success,
      ));
    } on DioError catch (e) {
      emit(state.copyWith(
        form: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  Future<void> setAvatar(String chatId) async {
    final chat = state.chats.firstWhere((chat) => chat.id == chatId);

    final XFile? pickedPhoto = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedPhoto != null) {
      emit(state.copyWith(loadingAvatar: true));

      var data = await pickedPhoto.readAsBytes();
      var processedAvatar = await computeCropAvatar(data) as Uint8List;

      final avatar = await _cacheManager.putFile(
        '$chatId.jpg',
        processedAvatar,
      );

      await _chatsRepository.updateAvatar(chat, avatar);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((chat) =>
                chat.id == chatId ? chat.copyWith(avatar: () => avatar) : chat)
            .toList(),
        loadingAvatar: false,
      ));
    }
  }

  Future<void> removeAvatar(String chatId) async {
    emit(state.copyWith(loadingAvatar: true));

    await _chatsRepository.deleteAvatar(chatId);

    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((chat) =>
              chat.id == chatId ? chat.copyWith(avatar: () => null) : chat)
          .toList(),
      loadingAvatar: false,
    ));
  }

  void nameChanged(String value) {
    emit(state.copyWith(
      name: Name(value),
      form: FormStatus.init,
    ));
  }

  Future<List<int>> computeCropAvatar(Uint8List photo) async {
    return await compute(cropAvatar, photo);
  }

  @override
  Future<void> close() {
    _notificationService.dispose();
    return super.close();
  }
}

List<int> cropAvatar(Uint8List data) {
  Image croppedPhoto = copyResizeCropSquare(
    decodeImage(data)!,
    150,
  );

  return encodeJpg(croppedPhoto);
}
