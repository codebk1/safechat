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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

import 'package:video_thumbnail/video_thumbnail.dart' as vt;

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(const ChatsState()) {
    _wsService.socket.on('message.new', (data) async {
      final chat = await _findOrFetchChat(data['chatId']);
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

    _wsService.socket.on('chat.read', (data) async {
      final chat = await _findOrFetchChat(data['chatId']);

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
      print('deleteeee');
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
      print('CHAT LEAVE');

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
      final chat = await _findOrFetchChat(data['chatId']);

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
      final chat = await _findOrFetchChat(data['chatId']);

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

    _notificationService.notification.listen((event) async {
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
      chat = await _chatsRepository.getChat(chatId: chatId);

      emit(state.copyWith(
        chats: List.of(state.chats)..insert(0, chat!),
      ));
    }

    return chat;
  }

  Future<Chat?> findChatByParticipants(List<String> participants) async {
    Chat? chat = state.chats.firstWhereOrNull((c) =>
        c.participants.every((p) => participants.contains(p.id)) &&
        c.participants.length == participants.length &&
        c.type == ChatType.direct);

    if (chat != null) return chat;

    chat ??= await _chatsRepository.getChat(participants: participants);

    if (chat != null) {
      emit(state.copyWith(
        chats: List.of(state.chats)..add(chat),
      ));
    }

    return chat;
  }

  Future<void> getChats() async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final chats = await _chatsRepository.getChats();

      for (var chat in state.chats) {
        _wsService.socket.emit('chat.join', chat.id);
      }

      emit(state.copyWith(chats: chats, listStatus: ListStatus.success));
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

      emit(state.copyWith(
        chats: [...state.chats, chat],
        selectedContacts: [],
        formStatus: const FormStatus.success(),
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
    List<MultipartFile> encryptedAttachments = [];
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

      encryptedItems.add(MessageItem(
        type: messageType,
        data: base32.encode(encryptedName),
      ));

      final file = File(attachments[i].name);

      // generate thumbnail for video or photo
      if (!attachments[i].type.isFile) {
        // Uint8List? thumb = await computeGenerateThumbnail(
        //   file,
        //   attachments[i].type.isVideo,
        // );

        Uint8List? thumb = await _generateThumbnail(
          file,
          attachments[i].type.isVideo,
        );

        print(file.lengthSync());
        print(thumb!.length);

        encryptedAttachments.add(MultipartFile.fromBytes(
          _encryptionService.chachaEncrypt(
            (await cacheManager.putFile('thumb_$attachmentName', thumb))
                .readAsBytesSync(),
            chat.sharedKey,
          ),
          filename: 'thumb_${base32.encode(encryptedName)}',
        ));
      }

      encryptedAttachments.add(MultipartFile.fromBytes(
        _encryptionService.chachaEncrypt(
          (await cacheManager.putFile(attachmentName, file.readAsBytesSync()))
              .readAsBytesSync(),
          chat.sharedKey,
        ),
        filename: base32.encode(encryptedName),
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
                  messages: List.of(c.messages)..insert(0, newMessage),
                  message: chat.message.copyWith(content: []))
              : c)
          .toList(),
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

    print({'ddddd', newMessage.content});

    final message = await _chatsRepository.addMessage(
      chat.id,
      newMessage,
      encryptedAttachments,
    );

    // _wsService.socket.emit('message.new', {
    //   'chatId': chat.id,
    //   'message': newMessage.copyWith(id: messageId).toJson(),
    // });

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
    print('READ CHAT');
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

      _wsService.socket.emit('chat.read', {
        'chatId': chat.id,
      });
    }
  }

  leaveChat(String chatId) async {
    emit(state.copyWith(
      chats: List.of(state.chats)..removeWhere((chat) => chat.id == chatId),
    ));

    await _chatsRepository.leaveChat(chatId);
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
    _wsService.socket.emit('typing.start', {
      'chatId': chatId,
    });
  }

  stopTyping(String chatId) {
    _wsService.socket.emit('typing.stop', {
      'chatId': chatId,
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
        formStatus: const FormStatus.success(),
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
      emit(state.copyWith(loadingAvatar: true));

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
    ));
  }

  Future<Uint8List?> _generateThumbnail(File file,
      [bool isVideo = false]) async {
    if (isVideo) {
      return await vt.VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: vt.ImageFormat.JPEG,
        maxWidth: 1024,
        quality: 50,
      );
    } else {
      return await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        //minWidth: 500,
        quality: 60,
      );
    }
  }

  // Future<Uint8List?> computeGenerateThumbnail(File file,
  //     [bool isVideo = false]) async {
  //   print('GENERATED THUMBNAIL!!!!');

  //   return await compute(
  //     generateThumbnail,
  //     GenerateThumbnailProperties(file, isVideo),
  //   );
  // }

  Future<List<int>> computeCropAvatar(Uint8List photo) async {
    return await compute(cropAvatar, photo);
  }

  @override
  Future<void> close() {
    _notificationService.dispose();
    return super.close();
  }
}

// class GenerateThumbnailProperties {
//   GenerateThumbnailProperties(this.file, this.isVideo);

//   final File file;
//   final bool isVideo;
// }

// Future<Uint8List?> generateThumbnail(GenerateThumbnailProperties data) async {
//   if (data.isVideo) {
//     return await vt.VideoThumbnail.thumbnailData(
//       video: data.file.path,
//       imageFormat: vt.ImageFormat.JPEG,
//       maxWidth: 1024,
//       quality: 50,
//     );
//   } else {
//     // var image = copyResize(
//     //   decodeImage(data.file.readAsBytesSync())!,
//     //   width: 512,
//     //   interpolation: Interpolation.nearest,
//     // );

//     // return encodeJpg(image) as Uint8List;
//     // ImageProperties properties =
//     //     await FlutterNativeImage.getImageProperties(data.file.path);

//     // print(properties);

//     // File compressedFile = await FlutterNativeImage.compressImage(data.file.path,
//     //     quality: 80,
//     //     targetWidth: 512,
//     //     targetHeight: (properties.height! * 512 / properties.width!).round());

//     // return compressedFile.readAsBytesSync();
//     // print(data.file);
//     // var result = await FlutterImageCompress.compressWithFile(
//     //   data.file.absolute.path,
//     //   minWidth: 500,
//     //   quality: 60,
//     // );
//     // print(data.file.lengthSync());
//     // print(result!.length);
//     // return result;

//     CompressObject compressObject = CompressObject(
//       imageFile: data.file, //image
//       //path: tempDir.path, //compress to path
//       quality: 60, //first compress quality, default 80
//       step:
//           9, //compress quality step, The bigger the fast, Smaller is more accurate, default 6
//       mode: CompressMode.LARGE2SMALL,
//       //default AUTO
//     );

//     var path = await Luban.compressImage(compressObject);
//     return File(path!).readAsBytesSync();
//   }
// }

List<int> cropAvatar(Uint8List data) {
  Image croppedPhoto = copyResizeCropSquare(
    decodeImage(data)!,
    150,
  );

  return encodeJpg(croppedPhoto);
}
