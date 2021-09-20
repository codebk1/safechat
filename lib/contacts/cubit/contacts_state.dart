part of 'contacts_cubit.dart';

enum ListStatus { unknow, loading, success, failure }

class ContactsState extends Equatable {
  const ContactsState({
    this.email = const Email(''),
    this.status = const FormStatus.init(),
    this.listStatus = ListStatus.unknow,
    this.contacts = const [],
  });

  final Email email;
  final FormStatus status;
  final ListStatus listStatus;
  final List<Contact> contacts;

  List<Contact> get pendingContacts =>
      contacts.where((e) => e.currentState == CurrentState.pending).toList();

  List<Contact> get newContacts =>
      contacts.where((e) => e.currentState == CurrentState.inviting).toList();

  List<Contact> get acceptedContacts =>
      contacts.where((e) => e.currentState == CurrentState.accepted).toList();

  // Map<String, List<Contact>> get sortedContacts {
  //   return this.contacts.fold<Map<String, List<Contact>>>(
  //       Map<String, List<Contact>>(), (previousValue, element) {
  //     final currentState = element.state.toString();
  //     previousValue..[currentState] ??= [];

  //     return previousValue..[currentState]?.add(element);
  //   });
  // }

  ContactsState copyWith({
    Email? email,
    FormStatus? status,
    ListStatus? listStatus,
    List<Contact>? contacts,
  }) {
    return ContactsState(
      email: email ?? this.email,
      status: status ?? this.status,
      listStatus: listStatus ?? this.listStatus,
      contacts: contacts ?? this.contacts,
    );
  }

  @override
  List<Object> get props => [email, status, listStatus, contacts];
}
