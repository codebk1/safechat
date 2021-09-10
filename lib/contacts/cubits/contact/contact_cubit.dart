import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/chats/repository/chats_repository.dart';
import 'package:safechat/contacts/repository/contacts_repository.dart';
import 'package:safechat/utils/socket_service.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit({
    required ContactState contact,
  }) : super(contact) {
    _wsService.socket.on(state.id, (status) {
      emit(state.copyWith(
        status: status == 'online' ? Status.ONLINE : Status.OFFLINE,
      ));
    });
  }

  final SocketService _wsService = SocketService();
  final ContactsRepository _contactsRepository = ContactsRepository();
  final ChatsRepository _chatsRepository = ChatsRepository();

  Future<void> createChat() async {
    try {
      await _chatsRepository.createChat([state.id]);
    } on DioError catch (e) {
      print(e);
      // emit(state.copyWith(
      //   status: FormStatus.failure(e.response?.data['message']),
      // ));
    } catch (e) {
      print(e);
      // emit(state.copyWith(
      //   status: FormStatus.failure(e.toString()),
      // ));
    }
  }

  Future<void> acceptInvitation() async {
    try {
      await _contactsRepository.acceptInvitation(state.id);

      emit(state.copyWith(currentState: CurrentState.ACCEPTED));
    } on DioError catch (e) {
      print(e);
      // emit(state.copyWith(
      //   status: FormStatus.failure(e.response?.data['message']),
      // ));
    } catch (e) {
      print(e);
      // emit(state.copyWith(
      //   status: FormStatus.failure(e.toString()),
      // ));
    }
  }
}
