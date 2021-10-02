import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({List<Contact> contacts = const []})
      : super(ContactsState(contacts: contacts)) {
    _wsService.socket.on('status', (data) {
      print('STATUS');

      if (state.contacts.isNotEmpty) {
        final index = state.contacts.indexWhere((c) => c.id == data['id']);

        if (index != -1) {
          final newContacts = List.of(state.contacts);

          newContacts[index] = state.contacts[index].copyWith(
            status: data['status'] == 'online' ? Status.online : Status.offline,
            lastSeen: data['date'] != null
                ? DateTime.parse(data['date'])
                : state.contacts[index].lastSeen,
          );

          emit(state.copyWith(contacts: newContacts));
        }
      }
    });
  }

  final _wsService = SocketService();
  final _contactsRepository = ContactsRepository();

  Future<void> getContacts() async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final contacts = await _contactsRepository.getContacts();

      contacts.sort(
        (a, b) => b.currentState.toString().compareTo(
              a.currentState.toString(),
            ),
      );

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
      emit(state.copyWith(status: const FormStatus.loading()));

      final newContact = await _contactsRepository.addContact(
        user,
        state.email.value,
      );

      final contacts = [
        newContact,
        ...state.contacts,
      ];

      emit(state.copyWith(
          status: const FormStatus.success(), contacts: contacts));
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

  startLoading(String contactId) {
    emit(state.copyWith(
      contacts: List.of(state.contacts)
          .map((c) => c.id == contactId ? c.copyWith(working: true) : c)
          .toList(),
    ));
  }

  stopLoading(String contactId) {
    emit(state.copyWith(
      contacts: List.of(state.contacts)
          .map((c) => c.id == contactId ? c.copyWith(working: false) : c)
          .toList(),
    ));
  }

  Future<void> acceptInvitation(String contactId) async {
    try {
      await _contactsRepository.acceptInvitation(contactId);

      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..firstWhere((c) => c.id == contactId).copyWith(
            currentState: CurrentState.accepted,
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
            state.contacts[index].currentState == CurrentState.deleting
                ? CurrentState.accepted
                : CurrentState.deleting);

    emit(state.copyWith(contacts: newContacts));
  }

  // Future<void> acceptInvitation(ContactState contactState) async {
  //   try {
  //     await _contactsRepository.acceptInvitation(contactState);

  //     final newContacts = state.contacts.toList();
  //     final index = newContacts
  //         .indexWhere((e) => e.contact.id == contactState.contact.id);
  //     newContacts[index] =
  //         contactState.copyWith(currentState: CurrentState.accepted);

  //     emit(state.copyWith(contacts: newContacts));

  //     // emit(state.copyWith(
  //     //   contacts: List.of(state.contacts)
  //     //     ..map((e) => e.id == contact.id
  //     //         ? contact.copyWith(state: ContactState.accepted)
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
      status: const FormStatus.init(),
    ));
  }
}
