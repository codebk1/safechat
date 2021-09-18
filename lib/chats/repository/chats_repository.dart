import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/contacts/contacts.dart';

import 'package:safechat/utils/utils.dart';

class ChatsRepository {
  final Dio _apiService = ApiService().init();
  final EncryptionService _encryptionService = EncryptionService();
  final ContactsRepository _contactsRepository = ContactsRepository();

  Future<List<ChatState>> getChats() async {
    final res = await _apiService.get('/chat');
    final chatsData = res.data as List;

    List<ChatState> chats = [];

    for (var i = 0; i < chatsData.length; i++) {
      final decryptedChatSharedKey = _encryptionService.rsaDecrypt(
        chatsData[i]['sharedKey'],
      );

      final chatParticipants =
          await _contactsRepository.getDecryptedContactsList(
        chatsData[i]['participants'] as List,
        decryptedChatSharedKey,
      );

      //print(chatParticipants);

      List<Message> chatMessages = [];

      for (var j = 0; j < chatsData[i]['messages'].length; j++) {
        // DODAC ID DO WIADOMOSCI
        final msg = Message.fromJson(chatsData[i]['messages'][j]);

        chatMessages.add(msg.copyWith(
            content: msg.content.map((item) {
          if (item.type == MessageType.TEXT) {
            return item.copyWith(
                data: utf8.decode(_encryptionService.chachaDecrypt(
              item.data,
              decryptedChatSharedKey,
            )));
          }

          return item;
        }).toList()));
      }

      final chat = ChatState(
        id: chatsData[i]['id'],
        sharedKey: decryptedChatSharedKey,
        participants: chatParticipants,
        messages: chatMessages.reversed.toList(),
      );

      //print(chat);

      chats.add(chat);
    }

    return chats.toList();
  }

  Future<void> createChat(List<String> participantsIDs) async {
    final chatSharedKey =
        _encryptionService.genereateSecureRandom().nextBytes(32);

    final chat = await _apiService.post('/chat', data: {
      'creatorSharedKey': base64.encode(
        _encryptionService.chachaEncrypt(
          _encryptionService.sharedKey!,
          chatSharedKey,
        ),
      ),
      'chatSharedKey': _encryptionService.rsaEncrypt(
        chatSharedKey,
        _encryptionService.publicKey,
      ),
    });

    for (var i = 0; i < participantsIDs.length; i++) {
      final participant = await _apiService.get(
        '/user/contacts/${participantsIDs[i]}',
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
  }

  Future<List<Message>> getMessages(String chatId, Uint8List sharedKey) async {
    final res = await _apiService.get('/chat/$chatId/messages/');
    final messagesData = res.data as List;

    List<Message> messages = [];

    for (var i = 0; i < messagesData.length; i++) {
      final msg = Message.fromJson(messagesData[i]);

      messages.add(msg.copyWith(
          content: msg.content.map((item) {
        if (item.type == MessageType.TEXT) {
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

  Future<void> addMessage(
    String chatId,
    Message encryptedMessage,
    List<MultipartFile> encryptedAttachments,
  ) async {
    final formData = FormData.fromMap(
      {
        'id': chatId,
        'message': encryptedMessage.toJson(),
        'attachments': encryptedAttachments,
      },
    );

    await _apiService.post(
      '/chat/messages',
      data: formData,
      onSendProgress: (int sent, int total) {
        //print('${(sent / total) * 100} %');
      },
    );
  }

  Future<void> readAllMessages(String chatId) async {
    await _apiService.post('/chat/messages/readall', data: {
      'chatId': chatId,
    });
  }
}
