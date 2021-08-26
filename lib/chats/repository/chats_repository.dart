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

      final participants = participantsData.map((participant) {
        return _contactsRepository.getContactState(
          participant,
          directory,
        );
      }).toList();

      print(messagesData);

      final messages = messagesData.map((message) {
        return Message(
          sender: message['sender'],
          type: MessageType.values.firstWhere(
            (e) => describeEnum(e) == message['type'],
          ),
          data: message['data'],
        );
      }).toList();

      return ChatState(
        id: chatData['id'],
        participants: participants,
        messages: messages.reversed.toList(),
      );
    });

    return chats.toList();
  }

  Future<void> createChat(String participantId) async {
    final sharedKey = _encryptionService.genereateSecureRandom().nextBytes(32);

    final chat = await _apiService.post('/chat', data: {
      'sharedKey': _encryptionService.rsaEncrypt(
        sharedKey,
        _encryptionService.publicKey,
      ),
    });

    print(chat.data['id']);

    final participant = await _apiService.get(
      '/user/key/public/id/$participantId',
    );

    await _apiService.post('/chat/participants', data: {
      'chatId': chat.data['id'],
      'participantId': participantId,
      'sharedKey': _encryptionService.rsaEncrypt(
        sharedKey,
        _encryptionService.parsePublicKeyFromPem(participant.data['publicKey']),
      ),
    });
  }

  Future<void> addMessage(String chatId, Message message) async {
    await _apiService.post('/chat/messages', data: {
      'id': chatId,
      'message': {
        'sender': message.sender,
        'type': describeEnum(message.type),
        'data': message.data,
      }
    });
  }
}
