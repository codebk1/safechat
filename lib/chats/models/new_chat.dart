import 'package:equatable/equatable.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

class NewChat extends Equatable {
  const NewChat({
    this.selectedParticipants = const [],
    this.form = FormStatus.init,
  });

  final List<Contact> selectedParticipants;
  final FormStatus form;

  @override
  List<Object> get props => [selectedParticipants, form];

  NewChat copyWith({
    List<Contact>? selectedParticipants,
    FormStatus? form,
  }) {
    return NewChat(
      selectedParticipants: selectedParticipants ?? this.selectedParticipants,
      form: form ?? this.form,
    );
  }
}
