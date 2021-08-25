import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required String id,
    required List<ContactState> participants,
  }) : super(ChatState(id: id, participants: participants)) {
    print('INIT CHAT');
    _wsService.socket.emit('join-chat', id);

    _wsService.socket.on('msg', (message) {
      print(message['senderId']);

      emit(state.copyWith(messages: [
        ...state.messages,
        Message(
          sender: message['senderId'],
          type: MessageType.TEXT,
          data: message['data'],
        )
      ]));
    });
  }

  final SocketService _wsService = SocketService();

  sendMessage() {
    _wsService.socket.emit('message', {'room': state.id, 'msg': state.message});

    emit(state.copyWith(
      message: '',
    ));
  }

  void messageChanged(String value) {
    emit(state.copyWith(
      message: value,
    ));
  }
}
