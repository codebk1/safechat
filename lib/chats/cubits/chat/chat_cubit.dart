import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
      if (data['room'] == state.id) {
        emit(state.copyWith(messages: [
          Message(
            sender: data['msg']['sender'],
            type: MessageType.values.firstWhere(
              (e) => describeEnum(e) == data['msg']['type'],
            ),
            data: utf8.decode(
              _encryptionService.chachaDecrypt(
                data['msg']['data'],
                state.sharedKey,
              ),
            ),
            unreadBy: [
              ...state.participants.map((e) => e.contact.id)
                ..where((id) => id != data['msg']['sender'])
            ],
          ),
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

  sendMessage() async {
    final msg = state.newMessage;

    emit(state.copyWith(
      messages: state.messages
        ..insert(
          0,
          msg.copyWith(
            status: MessageStatus.SENDING,
            unreadBy: [...state.participants.map((e) => e.contact.id)],
          ),
        ),
      newMessage: state.newMessage.copyWith(
        data: '',
      ),
    ));

    final encryptedMessage = msg.copyWith(
      data: _encryptionService.chachaEncrypt(
        utf8.encode(msg.data) as Uint8List,
        state.sharedKey,
      ),
    );

    await this._chatsRepository.addMessage(state.id, encryptedMessage);
    stopTyping(msg.sender);

    this._wsService.socket.emit('msg', {
      'room': state.id,
      'msg': {
        'sender': msg.sender,
        'type': describeEnum(msg.type),
        'data': base64.encode(encryptedMessage.data),
      }
    });

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

  setMessageType(MessageType type) {
    emit(state.copyWith(
      newMessage: state.newMessage.copyWith(type: type),
    ));
  }

  textMessageChanged(String value) {
    emit(state.copyWith(
      newMessage: state.newMessage.copyWith(data: value),
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
