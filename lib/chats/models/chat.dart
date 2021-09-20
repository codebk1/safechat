import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:safechat/contacts/cubit/contacts_cubit.dart';
import 'package:safechat/contacts/models/contact.dart';

import 'message.dart';

enum ChatType { direct, group }

class Chat extends Equatable {
  const Chat({
    required this.id,
    required this.sharedKey,
    required this.type,
    this.participants = const [],
    this.messages = const [],
    this.message = Message.empty,
    this.typing = const [],
    this.opened = false,
    this.listStatus = ListStatus.unknow,
  });

  final String id;
  final Uint8List sharedKey;
  final ChatType type;
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

  Chat copyWith({
    String? id,
    Uint8List? sharedKey,
    ChatType? type,
    List<Contact>? participants,
    List<Message>? messages,
    Message? message,
    List<String>? typing,
    bool? opened,
    bool? showActions,
    ListStatus? listStatus,
  }) {
    return Chat(
      id: id ?? this.id,
      sharedKey: sharedKey ?? this.sharedKey,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      message: message ?? this.message,
      typing: typing ?? this.typing,
      opened: opened ?? this.opened,
      listStatus: listStatus ?? this.listStatus,
    );
  }
}
