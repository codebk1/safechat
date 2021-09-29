import 'package:equatable/equatable.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

class NewChat extends Equatable {
  const NewChat({
    this.selectedParticipants = const [],
    this.status = const FormStatus.init(),
  });

  final List<Contact> selectedParticipants;
  final FormStatus status;

  @override
  List<Object> get props => [selectedParticipants, status];

  NewChat copyWith({
    List<Contact>? selectedParticipants,
    FormStatus? status,
  }) {
    return NewChat(
      selectedParticipants: selectedParticipants ?? this.selectedParticipants,
      status: status ?? this.status,
    );
  }
}
