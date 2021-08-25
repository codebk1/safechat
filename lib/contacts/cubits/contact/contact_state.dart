part of 'contact_cubit.dart';

enum CurrentState { NEW, PENDING, ACCEPTED, REJECTED, DELETING }

class ContactState extends Equatable {
  const ContactState({
    this.contact = Contact.empty,
    this.currentState = CurrentState.NEW,
  });

  final Contact contact;
  final CurrentState currentState;

  ContactState copyWith({
    Contact? contact,
    CurrentState? currentState,
  }) {
    return ContactState(
      contact: contact ?? this.contact,
      currentState: currentState ?? this.currentState,
    );
  }

  @override
  List<Object> get props => [contact, currentState];
}
