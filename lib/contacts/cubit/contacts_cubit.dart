import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit() : super(ContactsState());

  final ContactsRepository _contactsRepository = ContactsRepository();

  Future<void> getContacts() async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final contacts = await _contactsRepository.getContacts();

      contacts.sort((a, b) => b.state.toString().compareTo(a.state.toString()));

      emit(state.copyWith(contacts: contacts, listStatus: ListStatus.success));
    } on DioError catch (e) {
      print(e);
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      print(e);
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

  Future<void> cancelInvitation(String id) async {
    try {
      await _contactsRepository.cancelInvitation(id);

      emit(state.copyWith(
        contacts: List.of(state.contacts)..removeWhere((e) => e.id == id),
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

  Future<void> acceptInvitation(Contact contact) async {
    try {
      await _contactsRepository.acceptInvitation(contact);

      final newContacts = state.contacts.toList();
      final index = newContacts.indexWhere((e) => e.id == contact.id);
      newContacts[index] = contact.copyWith(state: ContactState.ACCEPTED);

      emit(state.copyWith(contacts: newContacts));

      // emit(state.copyWith(
      //   contacts: List.of(state.contacts)
      //     ..map((e) => e.id == contact.id
      //         ? contact.copyWith(state: ContactState.ACCEPTED)
      //         : e),
      // ));
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

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
      status: FormStatus.init(),
    ));
  }
}
