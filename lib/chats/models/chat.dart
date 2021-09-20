import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:safechat/contacts/cubit/contacts_cubit.dart';
import 'package:safechat/contacts/models/contact.dart';

import 'message.dart';

class Chat extends Equatable {
  const Chat({
    required this.id,
    required this.sharedKey,
    this.participants = const [],
    this.messages = const [],
    this.message = Message.empty,
    this.typing = const [],
    this.opened = false,
    this.showActions = false,
    this.listStatus = ListStatus.unknow,
  });

  final String id;
  final Uint8List sharedKey;
  final List<Contact> participants;
  final List<Message> messages;
  final Message message;
  final List<String> typing;
  final bool opened;
  final bool showActions;
  final ListStatus listStatus;

  @override
  List<Object> get props => [
        participants,
        messages,
        message,
        typing,
        opened,
        showActions,
        listStatus,
      ];

  Chat copyWith({
    String? id,
    Uint8List? sharedKey,
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
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      message: message ?? this.message,
      typing: typing ?? this.typing,
      opened: opened ?? this.opened,
      showActions: showActions ?? this.showActions,
      listStatus: listStatus ?? this.listStatus,
    );
  }
}
