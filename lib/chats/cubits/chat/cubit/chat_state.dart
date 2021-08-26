part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.id,
    this.participants = const [],
    this.messages = const [],
    this.newMessage = Message.empty,
  });

  final String id;
  final List<ContactState> participants;
  final List<Message> messages;
  final Message newMessage;

  @override
  List<Object> get props => [participants, messages, newMessage];

  ChatState copyWith({
    String? id,
    List<ContactState>? participants,
    List<Message>? messages,
    Message? newMessage,
  }) {
    return ChatState(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      newMessage: newMessage ?? this.newMessage,
    );
  }
}
