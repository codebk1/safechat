part of 'create_chat_cubit.dart';

class CreateChatState extends Equatable {
  const CreateChatState({
    this.selectedParticipants = const [],
    this.status = const FormStatus.init(),
  });

  final List<Contact> selectedParticipants;
  final FormStatus status;

  @override
  List<Object> get props => [selectedParticipants];

  CreateChatState copyWith({
    List<Contact>? selectedParticipants,
    FormStatus? status,
  }) {
    return CreateChatState(
      selectedParticipants: selectedParticipants ?? this.selectedParticipants,
      status: status ?? this.status,
    );
  }
}
