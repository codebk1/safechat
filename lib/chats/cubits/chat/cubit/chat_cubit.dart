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
    print('INIT CHAT');
    _wsService.socket.emit('join-chat', state.id);

    _wsService.socket.on('msg', (message) {
      emit(state.copyWith(messages: [
        Message(
          sender: message['sender'],
          type: MessageType.values.firstWhere(
            (e) => describeEnum(e) == message['type'],
          ),
          data: message['data'],
        ),
        ...state.messages,
      ]));
    });
  }

  final SocketService _wsService = SocketService();
  final ChatsRepository _chatsRepository = ChatsRepository();

  sendMessage() async {
    final msg = state.newMessage;

    emit(state.copyWith(
      messages: state.messages..insert(0, msg),
      newMessage: state.newMessage.copyWith(data: ''),
    ));

    await this._chatsRepository.addMessage(state.id, msg);

    this._wsService.socket.emit('msg', {
      'room': state.id,
      'msg': {
        'sender': msg.sender,
        'type': describeEnum(msg.type),
        'data': msg.data
      }
    });
  }

  setMessageType(MessageType type) {
    emit(state.copyWith(
      newMessage: state.newMessage.copyWith(type: type),
    ));
  }

  void textMessageChanged(String value) {
    emit(state.copyWith(
      newMessage: state.newMessage.copyWith(data: value),
    ));
  }
}
