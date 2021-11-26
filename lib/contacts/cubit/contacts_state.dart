part of 'contacts_cubit.dart';

enum ListStatus { unknow, loading, success, failure }

class ContactsState extends Equatable with ValidationMixin {
  const ContactsState({
    this.email = const Email(''),
    this.contacts = const [],
    this.listStatus = ListStatus.unknow,
    this.formStatus = FormStatus.init,
  });

  final Email email;
  final List<Contact> contacts;
  final ListStatus listStatus;
  final FormStatus formStatus;

  @override
  List<Object> get props => [email, contacts, listStatus, formStatus];

  @override
  List<FormItem> get inputs => [email];

  List<Contact> get pendingContacts =>
      contacts.where((e) => e.currentState == CurrentState.pending).toList();

  List<Contact> get newContacts =>
      contacts.where((e) => e.currentState == CurrentState.inviting).toList();

  List<Contact> get acceptedContacts =>
      contacts.where((e) => e.currentState == CurrentState.accepted).toList();

  ContactsState copyWith({
    Email? email,
    FormStatus? formStatus,
    ListStatus? listStatus,
    List<Contact>? contacts,
  }) {
    return ContactsState(
      email: email ?? this.email,
      formStatus: formStatus ?? this.formStatus,
      listStatus: listStatus ?? this.listStatus,
      contacts: contacts ?? this.contacts,
    );
  }
}
