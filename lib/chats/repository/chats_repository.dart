import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

class ChatsRepository {
  final _apiService = ApiService().init();
  final _encryptionService = EncryptionService();
  final _cacheManager = DefaultCacheManager();
  final _contactsRepository = ContactsRepository();

  Future<dynamic> getChat({String? chatId, List<String>? participants}) async {
    final res = await _apiService.get(
      chatId != null
          ? '/chat/$chatId'
          : '/chat/participants/${participants!.join(',')}',
    );

    print({'hjghgj', res, res.data?.isEmpty});

    if (res.data?.isEmpty) return null;

    return await _decryptChat(res.data);
  }

  Future<Chat?> _decryptChat(dynamic data) async {
    data['sharedKey'] = _encryptionService.rsaDecrypt(
      data['sharedKey'],
    );

    data['participants'] = await _contactsRepository.getDecryptedContactsList(
      data['participants'],
      data['sharedKey'],
    );

    var chat = Chat.fromJson(data);

    if (chat.name != null) {
      chat = chat.copyWith(
        name: utf8.decode(_encryptionService.chachaDecrypt(
          chat.name!,
          chat.sharedKey,
        )),
      );
    }

    if (chat.avatar != null) {
      var cachedFile = await _cacheManager.getFileFromCache(
        chat.avatar,
      );

      if (cachedFile != null) {
        chat = chat.copyWith(avatar: () => cachedFile.file);
      } else {
        final file = await _cacheManager.putFile(
          chat.avatar,
          await _getAvatar(chat.id, chat.sharedKey),
        );

        chat = chat.copyWith(
          avatar: () => file,
        );
      }
    }

    chat = chat.copyWith(
      messages: chat.messages
          .map((message) => message.copyWith(
                content: message.content.map((item) {
                  if (item.type == MessageType.text) {
                    return item.copyWith(
                        data: utf8.decode(_encryptionService.chachaDecrypt(
                      item.data,
                      chat.sharedKey,
                    )));
                  }

                  return item;
                }).toList(),
              ))
          .toList()
          .reversed
          .toList(),
    );

    return chat;
  }

  Future<List<Chat>> getChats() async {
    final res = await _apiService.get('/chat');
    final chatsData = res.data as List;

    List<Chat> chats = [];

    for (var i = 0; i < chatsData.length; i++) {
      chatsData[i]['sharedKey'] = _encryptionService.rsaDecrypt(
        chatsData[i]['sharedKey'],
      );

      chatsData[i]['participants'] =
          await _contactsRepository.getDecryptedContactsList(
        chatsData[i]['participants'],
        chatsData[i]['sharedKey'],
      );

      var chat = Chat.fromJson(chatsData[i]);

      if (chat.name != null) {
        chat = chat.copyWith(
          name: utf8.decode(_encryptionService.chachaDecrypt(
            chat.name!,
            chat.sharedKey,
          )),
        );
      }

      if (chat.avatar != null) {
        var cachedFile = await _cacheManager.getFileFromCache(
          chat.avatar,
        );

        if (cachedFile != null) {
          chat = chat.copyWith(avatar: () => cachedFile.file);
        } else {
          final file = await _cacheManager.putFile(
            chat.avatar,
            await _getAvatar(chat.id, chat.sharedKey),
          );

          chat = chat.copyWith(
            avatar: () => file,
          );
        }
      }

      chat = chat.copyWith(
        messages: chat.messages
            .map((message) => message.copyWith(
                  content: message.content.map((item) {
                    print(item);
                    if (item.type == MessageType.text) {
                      return item.copyWith(
                          data: utf8.decode(_encryptionService.chachaDecrypt(
                        item.data,
                        chat.sharedKey,
                      )));
                    } else {
                      return item.copyWith(
                        data: item.data,
                      );
                    }
                  }).toList(),
                ))
            .toList()
            .reversed
            .toList(),
      );

      chats.add(chat);
    }

    return chats.toList();
  }

  Future<Chat> createChat(
    ChatType type,
    User creator,
    List<Contact> participants,
  ) async {
    final chatSharedKey =
        _encryptionService.genereateSecureRandom().nextBytes(32);

    final chat = await _apiService.post('/chat', data: {
      'creator': {
        'sharedKey': base64.encode(
          _encryptionService.chachaEncrypt(
            _encryptionService.sharedKey!,
            chatSharedKey,
          ),
        ),
      },
      'chat': {
        'type': describeEnum(type),
        'sharedKey': _encryptionService.rsaEncrypt(
          chatSharedKey,
          _encryptionService.publicKey,
        ),
      }
    });

    for (var i = 0; i < participants.length; i++) {
      final participant = await _apiService.get(
        '/user/contacts/${participants[i].id}',
      );

      await _apiService.post('/chat/participants', data: {
        'chat': {
          'id': chat.data['id'],
          'sharedKey': _encryptionService.rsaEncrypt(
            chatSharedKey,
            _encryptionService
                .parsePublicKeyFromPem(participant.data['publicKey']),
          ),
        },
        'participant': {
          'id': participant.data['id'],
          'sharedKey': base64.encode(
            _encryptionService.chachaEncrypt(
              _encryptionService.rsaDecrypt(participant.data['sharedKey']),
              chatSharedKey,
            ),
          ),
        }
      });
    }

    final creatorContact = Contact(
      id: creator.id,
      email: creator.email,
      firstName: creator.firstName,
      lastName: creator.lastName,
      avatar: creator.avatar,
      status: creator.status,
      isOnline: true,
    );

    return Chat(
      id: chat.data['id'],
      sharedKey: chatSharedKey,
      type: type,
      participants: [...participants, creatorContact],
      messages: List<Message>.empty(growable: true),
    );
  }

  Future<List<Message>> getMessages(String chatId, Uint8List sharedKey) async {
    final res = await _apiService.get('/chat/$chatId/messages/');
    final messagesData = res.data as List;

    List<Message> messages = [];

    for (var i = 0; i < messagesData.length; i++) {
      final msg = Message.fromJson(messagesData[i]);

      messages.add(msg.copyWith(
          content: msg.content.map((item) {
        if (item.type == MessageType.text) {
          return item.copyWith(
              data: utf8.decode(_encryptionService.chachaDecrypt(
            item.data,
            sharedKey,
          )));
        }

        return item;
      }).toList()));
    }

    return messages;
  }

  // TODO
  // downloadVideo(
  //   String chatId,
  //   String attachmentName,
  //   Uint8List chatSharedKey,
  // ) {
  //   Stream<List<int>> stream = _apiService
  //       .download('', '')
  //       .asStream()
  //       .transform(
  //           StreamTransformer.fromHandlers(handleData: (data, EventSink sink) {
  //     final decryptedData = _encryptionService.chachaDecrypt(
  //       data as String,
  //       chatSharedKey,
  //     );

  //     sink.add(decryptedData);
  //   }));

  //   File('').openWrite(mode: FileMode.append).addStream(stream);
  // }

  Future<Uint8List> getAttachment(
    String chatId,
    String attachmentName,
    Uint8List chatSharedKey,
  ) async {
    final res = await _apiService.get(
      '/chat/$chatId/messages/attachments/$attachmentName',
    );

    final decryptedAttachment = _encryptionService.chachaDecrypt(
      res.data,
      chatSharedKey,
    );

    return decryptedAttachment;
  }

  Future<dynamic> addMessage(
    String chatId,
    Message encryptedMessage,
    List<MultipartFile> encryptedAttachments,
  ) async {
    final formData = FormData.fromMap({
      'id': chatId,
      'message': encryptedMessage.toJson(),
      'attachments': encryptedAttachments,
    });

    final res = await _apiService.post(
      '/chat/message',
      data: formData,
    );

    return res.data;
  }

  Future<void> readAllMessages(String chatId) async {
    await _apiService.post('/chat/messages/readall', data: {
      'chatId': chatId,
    });
  }

  Future<void> updateChatName(Chat chat, String name) async {
    final encryptedName = _encryptionService.chachaEncrypt(
      Uint8List.fromList(utf8.encode(name.trim())),
      chat.sharedKey,
    );

    await _apiService.patch('/chat', data: {
      'id': chat.id,
      'chat': {
        'name': base64.encode(encryptedName),
      }
    });
  }

  Future<void> updateAvatar(Chat chat, File avatar) async {
    final encryptedAvatar = _encryptionService.chachaEncrypt(
      avatar.readAsBytesSync(),
      chat.sharedKey,
    );

    final formData = FormData.fromMap(
      {
        'id': chat.id,
        'avatarName': '${chat.id}.jpg',
        'avatar': MultipartFile.fromBytes(
          encryptedAvatar,
          filename: '${chat.id}.jpg',
        )
      },
    );

    await _apiService.patch('/chat/avatar', data: formData);
  }

  Future<void> leaveChat(String chatId) async {
    await _apiService.patch('/chat/leave', data: {
      'chatId': chatId,
    });
  }

  Future<void> deleteChat(String id) async {
    await _apiService.delete('/chat/$id');
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _apiService.delete('/chat/message', data: {
      'chatId': chatId,
      'messageId': messageId,
    });
  }

  Future<void> updateMessageDeletedBy(String chatId, String messageId) async {
    await _apiService.patch('/chat/message/deletedby', data: {
      'chatId': chatId,
      'messageId': messageId,
    });
  }

  Future<void> deleteAvatar(String chatId) async {
    await _apiService.patch('/chat', data: {
      'id': chatId,
      'chat': {
        'avatar': null,
      }
    });
  }

  Future<Uint8List> _getAvatar(String chatId, Uint8List sharedKey) async {
    final res = await _apiService.get('/chat/$chatId/avatar');

    return _encryptionService.chachaDecrypt(
      res.data,
      sharedKey,
    );
  }
}
