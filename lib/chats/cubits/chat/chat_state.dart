part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.id,
    required this.sharedKey,
    this.participants = const [],
    this.messages = const [],
    this.message = Message.empty,
    this.typing = const [],
    this.listStatus = ListStatus.unknow,
  });

  final String id;
  final Uint8List sharedKey;
  final List<ContactState> participants;
  final List<Message> messages;
  final Message message;
  final List<String> typing;
  final ListStatus listStatus;

  @override
  List<Object> get props => [
        participants,
        messages,
        message,
        typing,
        listStatus,
      ];

  ChatState copyWith({
    String? id,
    Uint8List? sharedKey,
    List<ContactState>? participants,
    List<Message>? messages,
    Message? message,
    List<String>? typing,
    ListStatus? listStatus,
  }) {
    return ChatState(
      id: id ?? this.id,
      sharedKey: sharedKey ?? this.sharedKey,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      message: message ?? this.message,
      typing: typing ?? this.typing,
      listStatus: listStatus ?? this.listStatus,
    );
  }

  // do wywalenia
  // ChatState.fromJson(Map<String, dynamic> json)
  //     : id = json['id'],
  //       sharedKey = json['sharedKey']!,
  //       participants = (json['participants']! as List)
  //           .map((participant) => ContactState.fromJson(participant))
  //           .toList(),
  //       messages = (json['messages']! as List)
  //           .map((msg) => Message.fromJson(msg))
  //           .toList(),
  //       message = Message.empty,
  //       typing = [],
  //       listStatus = ListStatus.unknow;
}
