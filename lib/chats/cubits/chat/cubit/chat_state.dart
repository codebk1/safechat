part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.id,
    this.participants = const [],
    this.messages = const [],
    this.message = '',
  });

  final String id;
  final List<ContactState> participants;
  final List<Message> messages;
  final dynamic message;

  @override
  List<Object> get props => [participants, messages, message!];

  ChatState copyWith({
    String? id,
    List<ContactState>? participants,
    List<Message>? messages,
    dynamic message,
  }) {
    return ChatState(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      message: message ?? this.message,
    );
  }
}
