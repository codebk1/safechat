part of 'contact_cubit.dart';

enum CurrentState { NEW, PENDING, ACCEPTED, REJECTED, DELETING }

class ContactState extends Equatable {
  const ContactState({
    this.contact = User.empty,
    this.currentState = CurrentState.NEW,
  });

  final User contact;
  final CurrentState currentState;

  ContactState copyWith({
    User? contact,
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
