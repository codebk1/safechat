import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/chats.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/contacts/contacts.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({List<Contact> contacts = const []})
      : super(ContactsState(contacts: contacts)) {
    _wsService.socket.on('activity', (data) {
      if (state.contacts.isNotEmpty) {
        final index = state.contacts.indexWhere((c) => c.id == data['id']);

        if (index != -1) {
          final newContacts = List.of(state.contacts);

          newContacts[index] = state.contacts[index].copyWith(
            isOnline: data['isOnline']!,
            lastSeen: data['lastSeen'] != null
                ? DateTime.parse(data['lastSeen'])
                : state.contacts[index].lastSeen,
          );

          emit(state.copyWith(contacts: newContacts));
        }
      }
    });

    _wsService.socket.on('status', (data) {
      if (state.contacts.isNotEmpty) {
        final index = state.contacts.indexWhere((c) => c.id == data['id']);

        if (index != -1) {
          final newContacts = List.of(state.contacts);

          newContacts[index] = state.contacts[index].copyWith(
            status: Status.values.firstWhere(
              (e) => describeEnum(e) == data['status']!,
            ),
          );

          emit(state.copyWith(contacts: newContacts));
        }
      }
    });

    _wsService.socket.on('contact.delete', (data) {
      if (state.contacts.isNotEmpty) {
        emit(state.copyWith(
          contacts: List.of(state.contacts)
            ..removeWhere((c) => c.id == data['userId']),
        ));
      }
    });

    _wsService.socket.on('invite.new', (data) async {
      final decryptedContact =
          (await _contactsRepository.getDecryptedContactsList([data['user']]))
              .first;

      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..add(decryptedContact)
          ..sort(
            (a, b) => a.currentState.index.compareTo(
              b.currentState.index,
            ),
          ),
      ));
    });

    _wsService.socket.on('invite.accept', (data) async {
      final decryptedContact =
          (await _contactsRepository.getDecryptedContactsList([data['user']]))
              .first;

      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..removeWhere((c) => c.id == decryptedContact.id)
          ..add(decryptedContact),
      ));
    });

    _wsService.socket.on('invite.cancel', (data) async {
      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..removeWhere(
            (c) => c.id == data['id'],
          ),
      ));
    });
  }

  final _wsService = SocketService();
  final _contactsRepository = ContactsRepository();

  Future<void> getContacts() async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final contacts = await _contactsRepository.getContacts();

      contacts.sort((a, b) => a.currentState.index.compareTo(
            b.currentState.index,
          ));

      emit(state.copyWith(contacts: contacts, listStatus: ListStatus.success));
    } on DioException catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  Future<void> addContact() async {
    emit(state.copyWith(formStatus: FormStatus.submiting));

    if (state.validate().isValid) {
      try {
        emit(state.copyWith(formStatus: FormStatus.loading));

        final newContact = await _contactsRepository.addContact(
          state.email.value,
        );

        final contacts = [
          newContact,
          ...state.contacts,
        ];

        emit(state.copyWith(
          email: const Email(''),
          formStatus: const FormStatus.success(),
          contacts: contacts,
        ));
      } on DioException catch (e) {
        emit(state.copyWith(
          formStatus: FormStatus.failure(e.response!.data['message']),
        ));
      }
    }
  }

  Future<void> acceptInvitation(String contactId) async {
    try {
      startLoading(contactId);

      final contact = await _contactsRepository.acceptInvitation(contactId);

      emit(state.copyWith(
        contacts: List.of(state.contacts)
            .map((c) => c.id == contactId
                ? c.copyWith(
                    isOnline: contact['isOnline'],
                    currentState: CurrentState.accepted,
                    working: false,
                  )
                : c)
            .toList(),
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  Future<void> cancelInvitation(String contactId) async {
    try {
      startLoading(contactId);

      await _contactsRepository.cancelInvitation(contactId);

      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..removeWhere((e) => e.id == contactId),
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  Future<void> deleteContact(String contactId, ChatsCubit chatsCubit) async {
    try {
      startLoading(contactId);

      await _contactsRepository.deleteContact(contactId);

      emit(state.copyWith(
        contacts: List.of(state.contacts)
          ..removeWhere((c) => c.id == contactId),
      ));

      chatsCubit.emit(chatsCubit.state.copyWith(
        chats: chatsCubit.state.chats
            .map((c) => c.participants.map((p) => p.id).contains(contactId) &&
                    c.type.isDirect
                ? c.copyWith(participants: [])
                : c)
            .toList(),
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  toggleActionsMenu(String contactId) {
    final index = state.contacts.indexWhere((c) => c.id == contactId);
    final contact = state.contacts[index];
    final newContacts = List.of(state.contacts);

    if (contact.currentState.isAccepted) {
      newContacts[index] = contact.copyWith(showActions: !contact.showActions);
      emit(state.copyWith(contacts: newContacts));
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

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
    ));
  }
}
