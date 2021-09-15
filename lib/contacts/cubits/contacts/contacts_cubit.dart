import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({contactsState = const ContactsState()}) : super(contactsState);

  final ContactsRepository _contactsRepository = ContactsRepository();

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
