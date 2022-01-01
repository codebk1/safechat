import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:base32/base32.dart';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

import 'package:video_compress/video_compress.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(const ChatsState()) {
    _wsService.socket.on('chat.new', (data) async {
      emit(state.copyWith(
        chats: List.of(state.chats)
          ..insert(
            0,
            data['chat'],
          ),
      ));
    });

    _wsService.socket.on('message.new', (data) async {
      final chat = await _findOrFetchChat(
        id: data['chatId'],
        insert: true,
        sort: true,
      );

      var msg = Message.fromJson(data['message']);

      if (chat.opened) {
        msg = msg.copyWith(
          unreadBy: List.of(msg.unreadBy)..remove(_userRepository.user.id),
        );

        _chatsRepository.readAllMessages(chat.id);

        _wsService.socket.emit('chat.read', {
          'chatId': chat.id,
        });
      }

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(messages: [
                    if (chat.messages.last.id != msg.id)
                      msg.copyWith(
                          content: msg.content.map((item) {
                        if (item.type == MessageType.text) {
                          return item.copyWith(
                            data: utf8.decode(_encryptionService.chachaDecrypt(
                              item.data,
                              chat.sharedKey,
                            )),
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

    _wsService.socket.on('chat.read', (data) async {
      final chat = await _findOrFetchChat(id: data['chatId']);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(
                    messages: c.messages
                        .map((m) => m.copyWith(
                              unreadBy: List.of(m.unreadBy)
                                ..removeWhere((id) => id == data['readBy']),
                            ))
                        .toList())
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('message.delete', (data) {
      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((chat) => chat.id == data['chatId']
                ? chat.copyWith(
                    messages: List.of(chat.messages)
                      ..removeWhere((m) => m.id == data['messageId']),
                  )
                : chat)
            .toList(),
      ));
    });

    _wsService.socket.on('chat.leave', (data) {
      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == data['chatId']
                ? c.copyWith(
                    participants: List.of(c.participants)
                      ..removeWhere((p) => p.id == data['userId']))
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('typing.start', (data) async {
      final chat = await _findOrFetchChat(id: data['chatId']);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(
                    typing: List.of(c.typing)..add(data['userId']),
                  )
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('typing.stop', (data) async {
      final chat = await _findOrFetchChat(id: data['chatId']);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == chat.id
                ? c.copyWith(
                    typing: List.of(c.typing)
                      ..removeWhere((e) => e == data['userId']),
                  )
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('activity', (data) {
      emit(state.copyWith(
        chats: state.chats
            .map((c) => c.participants.map((p) => p.id).contains(data['id'])
                ? c.copyWith(
                    participants: List.of(c.participants)
                        .map((p) => p.id == data['id']
                            ? p.copyWith(
                                isOnline: data['isOnline'],
                                lastSeen: data['lastSeen'] != null
                                    ? DateTime.parse(data['lastSeen'])
                                    : p.lastSeen,
                              )
                            : p)
                        .toList(),
                  )
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('status', (data) {
      emit(state.copyWith(
        chats: state.chats
            .map((c) => c.participants.map((p) => p.id).contains(data['id'])
                ? c.copyWith(
                    participants: List.of(c.participants)
                        .map((p) => p.id == data['id']
                            ? p.copyWith(
                                status: Status.values.firstWhere(
                                  (e) => describeEnum(e) == data['status']!,
                                ),
                              )
                            : p)
                        .toList(),
                  )
                : c)
            .toList(),
      ));
    });

    _wsService.socket.on('contact.delete', (data) {
      if (state.chats.isNotEmpty) {
        emit(state.copyWith(
          chats: state.chats
              .map((c) =>
                  c.participants.map((p) => p.id).contains(data['userId']) &&
                          c.type.isDirect
                      ? c.copyWith(participants: [])
                      : c)
              .toList(),
        ));
      }
    });

    _notificationService.notification.listen((event) async {
      final chat = await _findOrFetchChat(id: event.data['chatId']);

      if (chat.opened == false) {
        final sender = chat.participants.firstWhere(
          (p) => p.id == event.data['senderId'],
        );
        final notification = NotificationData(
          id: event.data['chatId'],
          title: '${sender.firstName} ${sender.lastName}',
          body: event.data['type'] == 'text'
              ? utf8.decode(
                  _encryptionService.chachaDecrypt(
                    event.data['body'],
                    chat.sharedKey,
                  ),
                )
              : 'Wysłał(a) załącznik.',
          image: sender.avatar,
        );

        _notificationService.showNotification(notification);
      }
    });

    _notificationService.selectNotification.listen((chatId) async {
      final chat = await _findOrFetchChat(id: chatId, insert: true, sort: true);

      emit(state.copyWith(nextChat: chat));
    });
  }

  final _wsService = SocketService();
  final _encryptionService = EncryptionService();
  final _notificationService = NotificationService();
  final _cacheManager = DefaultCacheManager();

  final _userRepository = UserRepository();
  final _chatsRepository = ChatsRepository();

  Future<Chat> _findOrFetchChat(
      {required String id, bool insert = false, bool sort = false}) async {
    var chat = state.chats.firstWhereOrNull(
      (c) => c.id == id,
    );

    if (chat == null) {
      chat = await _chatsRepository.getChat(chatId: id);

      if (insert) {
        emit(state.copyWith(chats: List.of(state.chats)..insert(0, chat!)));
      }
    }

    if (sort) {
      emit(state.copyWith(
        chats: List.of(state.chats)
            .map((c) => c.id == id ? c.copyWith(updatedAt: DateTime.now()) : c)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
      ));
    }

    return chat!;
  }

  Future<Chat?> findDirectChatByParticipants(List<String> participants) async {
    Chat? chat = state.chats.firstWhereOrNull((c) =>
        c.participants.every((p) => participants.contains(p.id)) &&
        c.participants.length == participants.length &&
        c.type == ChatType.direct);

    if (chat != null) return chat;

    chat = await _chatsRepository.getChat(participants: participants);

    if (chat != null) {
      emit(state.copyWith(
        chats: List.of(state.chats)..insert(0, chat),
      ));
    }

    return chat;
  }

  Future<void> getChats() async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final chats = await _chatsRepository.getChats();

      for (var chat in state.chats) {
        _wsService.socket.emit('chat.join', {
          'chatId': chat.id,
          'isOnline': true,
        });
      }

      emit(state.copyWith(
        chats: chats..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
        listStatus: ListStatus.success,
      ));
    } on DioError catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  Future<Chat?> createChat(
    ChatType type,
    User creator,
    List<Contact> participants,
  ) async {
    try {
      emit(state.copyWith(
        formStatus: FormStatus.loading,
      ));

      final chat = await _chatsRepository.createChat(
        type,
        creator,
        participants,
      );

      if (chat.type.isGroup) {
        _wsService.socket.emit('chat.new', {
          'chatId': chat.id,
        });
      }

      emit(state.copyWith(
        chats: [chat, ...state.chats],
        selectedContacts: [],
        formStatus: FormStatus.init,
        // formStatus: FormStatus.success(
        //   'Utworzono czat${chat.type.isGroup ? ' grupowy' : ''}.',
        // ),
      ));

      return chat;
    } on DioError catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  sendMessage(Chat chat, String senderId, List<Attachment> attachments) async {
    DefaultCacheManager cacheManager = DefaultCacheManager();
    List<MessageItem> encryptedItems = [];

    for (var i = 0; i < attachments.length; i++) {
      var attachmentName = attachments[i].name.split('/').last;

      final encryptedName = _encryptionService.chachaEncrypt(
        Uint8List.fromList(utf8.encode(attachmentName)),
        chat.sharedKey,
      );

      final messageType = MessageType.values.firstWhere(
        (e) => describeEnum(e) == describeEnum(attachments[i].type),
      );

      if (attachments[i].type.isVideo) {
        final videoThumb = await VideoCompress.getByteThumbnail(
          attachments[i].name,
          quality: 80,
        );

        await cacheManager.putFile(
          'thumb_$attachmentName',
          videoThumb!,
          eTag: 'thumb_$attachmentName',
          maxAge: const Duration(days: 14),
        );
      }

      if (!attachments[i].type.isFile) {
        await cacheManager.putFile(
          attachmentName,
          File(attachments[i].name).readAsBytesSync(),
          eTag: attachmentName,
          maxAge: const Duration(days: 14),
        );
      }

      encryptedItems.add(MessageItem(
        type: messageType,
        data: base32.encode(encryptedName),
      ));
    }

    var newMessage = chat.message.copyWith(
      senderId: senderId,
      status: MessageStatus.sending,
      content: [...chat.message.content, ...encryptedItems],
      unreadBy: chat.participants
          .map((e) => e.id)
          .where((id) => id != senderId)
          .toList(),
    );

    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((c) => c.id == chat.id
              ? c.copyWith(
                  updatedAt: DateTime.now(),
                  messages: [newMessage, ...c.messages],
                  message: chat.message.copyWith(content: []))
              : c)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    ));

    if (newMessage.content.first.type == MessageType.text) {
      final encryptedItem = newMessage.content.first.copyWith(
          data: base64.encode(_encryptionService.chachaEncrypt(
        utf8.encode(newMessage.content.first.data) as Uint8List,
        chat.sharedKey,
      )));

      newMessage = newMessage.copyWith(
        content: List.of(newMessage.content)
          ..replaceRange(0, 1, [encryptedItem]),
      );
    }

    List<MultipartFile> encryptedAttachments = [];

    for (var i = 0; i < attachments.length; i++) {
      final file = File(attachments[i].name);
      final attachmentName = attachments[i].name.split('/').last;
      final encryptedName = encryptedItems[i].data;

      encryptedAttachments.add(MultipartFile.fromBytes(
        await computeEncryptAttachment(
          EncryptAttachmentProperties(
            file.readAsBytesSync(),
            chat.sharedKey,
            _encryptionService,
          ),
        ),
        filename: encryptedName,
      ));

      if (attachments[i].type.isPhoto) {
        Uint8List? thumb = await computeGenerateThumbnail(
          file,
          attachments[i].type.isVideo,
        );

        print(file.lengthSync());
        print(thumb!.length);

        final cachedThumb = await cacheManager.putFile(
          'thumb_$attachmentName',
          thumb,
          eTag: 'thumb_$attachmentName',
          maxAge: const Duration(days: 14),
        );

        encryptedAttachments.add(MultipartFile.fromBytes(
          await computeEncryptAttachment(
            EncryptAttachmentProperties(
              cachedThumb.readAsBytesSync(),
              chat.sharedKey,
              _encryptionService,
            ),
          ),
          filename: 'thumb_$encryptedName',
        ));
      }

      if (attachments[i].type.isVideo) {
        final videoThumb = await cacheManager.getFileFromCache(
          'thumb_$attachmentName',
        );

        encryptedAttachments.add(MultipartFile.fromBytes(
          await computeEncryptAttachment(
            EncryptAttachmentProperties(
              videoThumb!.file.readAsBytesSync(),
              chat.sharedKey,
              _encryptionService,
            ),
          ),
          filename: 'thumb_$encryptedName',
        ));
      }
    }

    stopTyping(chat.id);

    final message = await _chatsRepository.addMessage(
      chat.id,
      newMessage,
      encryptedAttachments,
    );

    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((c) => c.id == chat.id
              ? c.copyWith(messages: [
                  c.messages[0].copyWith(
                    id: message['_id'],
                    status: MessageStatus.sent,
                  ),
                  ...c.messages.sublist(1)
                ])
              : c)
          .toList(),
    ));
  }

  readChat(Chat chat, String currentUserId) async {
    if (chat.messages.any((msg) => msg.unreadBy.contains(currentUserId))) {
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

      _wsService.socket.emit('chat.read', {
        'chatId': chat.id,
      });
    }
  }

  leaveChat(String chatId) async {
    try {
      emit(state.copyWith(formStatus: FormStatus.loading));

      await _chatsRepository.leaveChat(chatId);

      emit(state.copyWith(
        chats: List.of(state.chats)..removeWhere((chat) => chat.id == chatId),
        formStatus: const FormStatus.success('Opuszczono czat.'),
      ));
    } on DioError catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  deleteChat(String id) async {
    try {
      emit(state.copyWith(formStatus: FormStatus.loading));

      await _chatsRepository.deleteChat(id);

      emit(state.copyWith(
        chats: List.of(state.chats)..removeWhere((chat) => chat.id == id),
        formStatus: const FormStatus.success('Usunięto czat.'),
      ));
    } on DioError catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  deleteMessage(String chatId, String messageId) async {
    emit(state.copyWith(formStatus: FormStatus.loading));

    await _chatsRepository.deleteMessage(chatId, messageId);

    emit(state.copyWith(
      formStatus: const FormStatus.success('Usunięto wiadomość.'),
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

  updateMessageDeletedBy(String chatId, String messageId) async {
    emit(state.copyWith(formStatus: FormStatus.loading));

    await _chatsRepository.updateMessageDeletedBy(chatId, messageId);

    emit(state.copyWith(
      formStatus: const FormStatus.success('Usunięto wiadomość.'),
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

  startTyping(String chatId) {
    print('start');
    _wsService.socket.emit('typing.start', {
      'chatId': chatId,
    });
  }

  stopTyping(String chatId) {
    print('stop');
    _wsService.socket.emit('typing.stop', {
      'chatId': chatId,
    });
  }

  openChat(String chatId) {
    emit(state.copyWith(
        chats: List.of(state.chats)
            .map((chat) =>
                chat.id == chatId ? chat.copyWith(opened: true) : chat)
            .toList()));
  }

  closeChat(String chatId) {
    emit(state.copyWith(
        chats: List.of(state.chats)
            .map((chat) =>
                chat.id == chatId ? chat.copyWith(opened: false) : chat)
            .toList()));
  }

  textMessageChanged(String chatId, String value, String prevValue) {
    print({value, prevValue});
    if (value.trim().isNotEmpty && prevValue.trim().isEmpty) {
      startTyping(chatId);
    }

    if (value.trim().isEmpty) {
      stopTyping(chatId);
    }

    emit(state.copyWith(
      chats: List.of(state.chats)
          .map((c) => c.id == chatId
              ? c.copyWith(
                  message: value.trim().isEmpty
                      ? c.message.copyWith(
                          content: List.of(c.message.content)
                            ..removeWhere((e) => e.type == MessageType.text),
                        )
                      : c.message.copyWith(
                          content: List.of(c.message.content)
                            ..removeWhere((e) => e.type == MessageType.text)
                            ..add(MessageItem(
                                type: MessageType.text, data: value)),
                        ))
              : c)
          .toList(),
    ));
  }

  toggleParticipant(Contact participant) {
    if (state.selectedContacts.contains(participant)) {
      emit(state.copyWith(
        selectedContacts: List.of(state.selectedContacts)
          ..removeWhere((e) => e == participant),
        formStatus: FormStatus.init,
      ));
    } else {
      emit(state.copyWith(
        selectedContacts: List.of(state.selectedContacts)..add(participant),
        formStatus: FormStatus.init,
      ));
    }
  }

  Future<void> editChatNameSubmit(String chatId) async {
    try {
      emit(state.copyWith(formStatus: FormStatus.loading));

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
        formStatus: const FormStatus.success('Zmieniono nazwę czatu.'),
      ));
    } on DioError catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  Future<void> setAvatar(String chatId) async {
    final chat = state.chats.firstWhere((chat) => chat.id == chatId);

    final XFile? pickedPhoto = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedPhoto != null) {
      emit(state.copyWith(
        formStatus: FormStatus.init,
        loadingAvatar: true,
      ));

      var data = await pickedPhoto.readAsBytes();
      var processedAvatar = await computeCropAvatar(data) as Uint8List;

      await _cacheManager.removeFile('$chatId.jpg');
      final avatar = await _cacheManager.putFile(
        '$chatId.jpg',
        processedAvatar,
        eTag: '$chatId-${Random(10)}',
        maxAge: const Duration(days: 14),
      );

      await _chatsRepository.updateAvatar(chat, avatar);

      emit(state.copyWith(
        chats: List.of(state.chats)
            .map(
              (chat) => chat.id == chatId
                  ? chat.copyWith(avatar: () => avatar)
                  : chat,
            )
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
    ));
  }

  resetSelectedContacts() {
    emit(state.copyWith(
      selectedContacts: [],
    ));
  }

  resetNextChat() {
    emit(state.copyWith(
      nextChat: null,
    ));
  }

  Future<Uint8List?> computeGenerateThumbnail(File file,
      [bool isVideo = false]) async {
    return await compute(
      generateThumbnail,
      GenerateThumbnailProperties(file, isVideo),
    );
  }

  Future<List<int>> computeCropAvatar(Uint8List photo) async {
    return await compute(cropAvatar, photo);
  }

  Future<Uint8List> computeEncryptAttachment(
    EncryptAttachmentProperties data,
  ) async {
    return await compute(encryptAttachment, data);
  }

  @override
  Future<void> close() {
    _notificationService.dispose();
    return super.close();
  }
}

class GenerateThumbnailProperties {
  GenerateThumbnailProperties(this.file, this.isVideo);

  final File file;
  final bool isVideo;
}

class EncryptAttachmentProperties {
  EncryptAttachmentProperties(
    this.data,
    this.sharedKey,
    this.encryptionService,
  );

  final Uint8List data;
  final Uint8List sharedKey;
  final EncryptionService encryptionService;
}

Future<Uint8List?> generateThumbnail(GenerateThumbnailProperties data) async {
  if (data.isVideo) {
    // return await vt.VideoThumbnail.thumbnailData(
    //   video: data.file.absolute.path,
    //   imageFormat: vt.ImageFormat.JPEG,
    //   maxWidth: 1024,
    //   quality: 50,
    // );
  } else {
    Image croppedPhoto = copyResizeCropSquare(
      decodeImage(data.file.readAsBytesSync())!,
      500,
    );
    return encodeJpg(croppedPhoto) as Uint8List;
  }
}

List<int> cropAvatar(Uint8List data) {
  Image croppedPhoto = copyResizeCropSquare(
    decodeImage(data)!,
    150,
  );

  return encodeJpg(croppedPhoto);
}

Uint8List encryptAttachment(EncryptAttachmentProperties properties) {
  return properties.encryptionService.chachaEncrypt(
    properties.data,
    properties.sharedKey,
  );
}
