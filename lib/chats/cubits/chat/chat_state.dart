part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.id,
    required this.sharedKey,
    this.participants = const [],
    this.messages = const [],
    this.newMessage = Message.empty,
    this.typing = const [],
  });

  final String id;
  final Uint8List sharedKey;
  final List<ContactState> participants;
  final List<Message> messages;
  final Message newMessage;
  final List<String> typing;

  @override
  List<Object> get props => [participants, messages, newMessage, typing];

  ChatState copyWith({
    String? id,
    Uint8List? sharedKey,
    List<ContactState>? participants,
    List<Message>? messages,
    Message? newMessage,
    List<String>? typing,
  }) {
    return ChatState(
      id: id ?? this.id,
      sharedKey: sharedKey ?? this.sharedKey,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      newMessage: newMessage ?? this.newMessage,
      typing: typing ?? this.typing,
    );
  }
}
