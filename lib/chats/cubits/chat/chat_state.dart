part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.id,
    required this.sharedKey,
    this.participants = const [],
    this.messages = const [],
    this.message = Message.empty,
    this.typing = const [],
    this.opened = false,
    this.listStatus = ListStatus.unknow,
  });

  final String id;
  final Uint8List sharedKey;
  final List<Contact> participants;
  final List<Message> messages;
  final Message message;
  final List<String> typing;
  final bool opened;
  final ListStatus listStatus;

  @override
  List<Object> get props => [
        participants,
        messages,
        message,
        typing,
        opened,
        listStatus,
      ];

  ChatState copyWith({
    String? id,
    Uint8List? sharedKey,
    List<Contact>? participants,
    List<Message>? messages,
    Message? message,
    List<String>? typing,
    bool? opened,
    ListStatus? listStatus,
  }) {
    return ChatState(
      id: id ?? this.id,
      sharedKey: sharedKey ?? this.sharedKey,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      message: message ?? this.message,
      typing: typing ?? this.typing,
      opened: opened ?? this.opened,
      listStatus: listStatus ?? this.listStatus,
    );
  }
}
