import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safechat/chats/cubits/chat/cubit/chat_cubit.dart';
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
    final directory = await getApplicationDocumentsDirectory();

    final chats = chatsData.map((chatData) {
      final participantsData = chatData['participants'] as List;
      final messagesData = chatData['messages'] as List;

      final decryptedChatSharedKey = _encryptionService.rsaDecrypt(
        chatData['sharedKey'],
      );

      final participants = participantsData.map((participant) {
        // odszyfrowany klucz współdzielony członka czatu za pomocą klucza współdzielonego danego czatu
        final sharedKey = _encryptionService.chachaDecrypt(
          participant['sharedKey'],
          decryptedChatSharedKey,
        );

        return _contactsRepository.getContactState(
          participant,
          directory,
          sharedKey,
        );
      }).toList();

      final messages = messagesData.map((message) {
        return Message(
          sender: message['sender'],
          type: MessageType.values.firstWhere(
            (e) => describeEnum(e) == message['type'],
          ),
          data: utf8.decode(
            _encryptionService.chachaDecrypt(
              message['data'],
              decryptedChatSharedKey,
            ),
          ),
        );
      }).toList();

      return ChatState(
        id: chatData['id'],
        sharedKey: decryptedChatSharedKey,
        participants: participants,
        messages: messages.reversed.toList(),
      );
    });

    return chats.toList();
  }

  Future<void> createChat(String participantId) async {
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

    final participant = await _apiService.get(
      '/user/contacts/$participantId',
    );

    print(participant);

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

  Future<void> addMessage(String chatId, Message message) async {
    await _apiService.post('/chat/messages', data: {
      'id': chatId,
      'message': {
        'sender': message.sender,
        'type': describeEnum(message.type),
        'data': base64.encode(message.data),
      }
    });
  }
}
