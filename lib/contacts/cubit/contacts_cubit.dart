import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/chats/repository/chats_repository.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({ContactsState contactsState = const ContactsState()})
      : super(contactsState) {
    _wsService.socket.on('status', (data) {
      print('STATUS');

      if (state.contacts.isNotEmpty) {
        final index = state.contacts.indexWhere((c) => c.id == data['id']);

        if (index != -1) {
          final newContacts = List.of(state.contacts);

          newContacts[index] = state.contacts[index].copyWith(
            status: data['status'] == 'online' ? Status.ONLINE : Status.OFFLINE,
          );

          emit(state.copyWith(contacts: newContacts));
        }
      }
    });
  }

  final _wsService = SocketService();
  final _contactsRepository = ContactsRepository();
  final _chatsRepository = ChatsRepository();

  Future<void> getContacts({bool onlyAccepted = false}) async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final contacts = await _contactsRepository.getContacts();

      contacts.sort(
        (a, b) => b.currentState.toString().compareTo(
              a.currentState.toString(),
            ),
      );

      if (onlyAccepted)
        contacts.removeWhere((c) => c.currentState != CurrentState.ACCEPTED);

      emit(state.copyWith(contacts: contacts, listStatus: ListStatus.success));
    } on DioError catch (e) {
      print({'CONTACTS', e});
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      print({'CONTACTS', e});
      emit(state.copyWith(
        status: FormStatus.failure(e.toString()),
      ));
    }
  }

  Future<void> addContact(User user) async {
    try {
      emit(state.copyWith(status: FormStatus.loading()));

      final newContact = await _contactsRepository.addContact(
        user,
        state.email.value,
      );

      final contacts = [
        newContact,
        ...state.contacts,
      ];

      emit(state.copyWith(status: FormStatus.success(), contacts: contacts));
    } on DioError catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.toString()),
      ));
    }
  }

  Future<void> cancelInvitation(String contactId) async {
    try {
      await _contactsRepository.cancelInvitation(contactId);

      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..removeWhere((e) => e.id == contactId),
      ));
    } on DioError catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.toString()),
      ));
    }
  }

  Future<void> createChat(String contactId) async {
    try {
      await _chatsRepository.createChat([contactId]);
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

  Future<void> acceptInvitation(String contactId) async {
    try {
      await _contactsRepository.acceptInvitation(contactId);

      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..firstWhere((c) => c.id == contactId).copyWith(
            currentState: CurrentState.ACCEPTED,
          ),
      ));
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

  toggleActionsMenu(String contactId) {
    final index = state.contacts.indexWhere((c) => c.id == contactId);
    final newContacts = List.of(state.contacts);

    newContacts[index] = state.contacts[index].copyWith(
        currentState:
            state.contacts[index].currentState == CurrentState.DELETING
                ? CurrentState.ACCEPTED
                : CurrentState.DELETING);

    emit(state.copyWith(contacts: newContacts));
  }

  // Future<void> acceptInvitation(ContactState contactState) async {
  //   try {
  //     await _contactsRepository.acceptInvitation(contactState);

  //     final newContacts = state.contacts.toList();
  //     final index = newContacts
  //         .indexWhere((e) => e.contact.id == contactState.contact.id);
  //     newContacts[index] =
  //         contactState.copyWith(currentState: CurrentState.ACCEPTED);

  //     emit(state.copyWith(contacts: newContacts));

  //     // emit(state.copyWith(
  //     //   contacts: List.of(state.contacts)
  //     //     ..map((e) => e.id == contact.id
  //     //         ? contact.copyWith(state: ContactState.ACCEPTED)
  //     //         : e),
  //     // ));
  //   } on DioError catch (e) {
  //     emit(state.copyWith(
  //       status: FormStatus.failure(e.response?.data['message']),
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: FormStatus.failure(e.toString()),
  //     ));
  //   }
  // }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
      status: FormStatus.init(),
    ));
  }
}
