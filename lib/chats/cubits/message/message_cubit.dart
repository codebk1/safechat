import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:safechat/utils/socket_service.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  MessageCubit({required MessageState messageState}) : super(messageState) {
    _wsService.socket.on('message.readby', (data) {
      print('message.readby');
      //if (data['room'] == state.id) {
      print('KAKAKAKAKAK');
      if (state.unreadBy.contains(data['userId'])) {
        emit(state.copyWith(
          unreadBy: List.of(state.unreadBy)..remove(data['userId']),
        ));
      }
      //}
    });
  }

  final _wsService = SocketService();

  readMessage(String userId, String chatId) {
    if (state.unreadBy.contains(userId)) {
      print('READ MESSAGE');
      emit(state.copyWith(
        unreadBy: List.of(state.unreadBy)..remove(userId),
      ));

      _wsService.socket.emit('message.read', {'room': chatId});
    }
  }
}
