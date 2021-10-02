import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:safechat/contacts/models/contact.dart';

import 'message.dart';

enum ChatType { direct, group }

class Chat extends Equatable {
  const Chat({
    required this.id,
    required this.sharedKey,
    required this.type,
    this.name,
    this.participants = const [],
    this.messages = const [],
    this.message = Message.empty,
    this.typing = const [],
    this.opened = false,
  });

  final String id;
  final Uint8List sharedKey;
  final ChatType type;
  final String? name;
  final List<Contact> participants;
  final List<Message> messages;
  final Message message;
  final List<String> typing;
  final bool opened;

  @override
  List<Object?> get props => [
        name,
        participants,
        messages,
        message,
        typing,
        opened,
      ];

  Chat copyWith({
    String? id,
    Uint8List? sharedKey,
    ChatType? type,
    String? name,
    List<Contact>? participants,
    List<Message>? messages,
    Message? message,
    List<String>? typing,
    bool? opened,
    bool? showActions,
  }) {
    return Chat(
      id: id ?? this.id,
      sharedKey: sharedKey ?? this.sharedKey,
      type: type ?? this.type,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      message: message ?? this.message,
      typing: typing ?? this.typing,
      opened: opened ?? this.opened,
    );
  }
}
