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
  final List<ContactState> contacts;

  int get pendingContacts =>
      this.contacts.where((e) => e.currentState == CurrentState.PENDING).length;

  int get newContacts =>
      this.contacts.where((e) => e.currentState == CurrentState.NEW).length;

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
    List<ContactState>? contacts,
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
