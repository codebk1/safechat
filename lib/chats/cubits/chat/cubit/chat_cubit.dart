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
          ),
          ...state.messages,
        ]));
      }
    });

    _wsService.socket.on('typing.start', (data) {
      emit(state.copyWith(typing: [...state.typing, data]));
    });
  }

  final _wsService = SocketService();
  final _chatsRepository = ChatsRepository();
  final _encryptionService = EncryptionService();

  sendMessage() async {
    final msg = state.newMessage;

    emit(state.copyWith(
      messages: state.messages
        ..insert(0, msg.copyWith(status: MessageStatus.SENDING)),
      newMessage: state.newMessage.copyWith(data: ''),
    ));

    final encryptedMessage = msg.copyWith(
      data: _encryptionService.chachaEncrypt(
        utf8.encode(msg.data) as Uint8List,
        state.sharedKey,
      ),
    );

    await this._chatsRepository.addMessage(state.id, encryptedMessage);

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

  setMessageType(MessageType type) {
    emit(state.copyWith(
      newMessage: state.newMessage.copyWith(type: type),
    ));
  }

  textMessageChanged(String value) {
    _wsService.socket.emit('typing.start', {
      'room': state.id,
      'data': value,
    });

    emit(state.copyWith(
      newMessage: state.newMessage.copyWith(data: value),
    ));
  }
}
