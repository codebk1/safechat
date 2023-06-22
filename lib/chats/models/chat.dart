
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

import 'package:safechat/contacts/contacts.dart';

import 'message.dart';

enum ChatType { direct, group }

class Chat extends Equatable {
  const Chat({
    required this.id,
    required this.sharedKey,
    required this.type,
    required this.updatedAt,
    this.name,
    this.avatar,
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
  final DateTime updatedAt;
  final dynamic avatar;
  final List<Contact> participants;
  final List<Message> messages;
  final Message message;
  final List<String> typing;
  final bool opened;

  @override
  List<Object?> get props => [
        name,
        avatar,
        participants,
        messages,
        updatedAt,
        message,
        typing,
        opened,
      ];

  Chat copyWith({
    String? id,
    Uint8List? sharedKey,
    ChatType? type,
    String? name,
    DateTime? updatedAt,
    dynamic avatar,
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
      updatedAt: updatedAt ?? this.updatedAt,
      avatar: avatar != null ? avatar() : this.avatar,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      message: message ?? this.message,
      typing: typing ?? this.typing,
      opened: opened ?? this.opened,
    );
  }

  Chat.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        sharedKey = json['sharedKey']!,
        type = ChatType.values.firstWhere(
          (e) => describeEnum(e) == json['type'],
        ),
        name = json['name'],
        updatedAt = DateTime.parse(json['updatedAt']),
        avatar = json['avatar'],
        participants = json['participants']!,
        messages = (json['messages']! as List)
            .map((item) => Message.fromJson(item))
            .toList(),
        message = Message.empty,
        opened = false,
        typing = [];
}

extension ChatTypeExtension on ChatType {
  bool get isDirect => this == ChatType.direct;
  bool get isGroup => this == ChatType.group;
}
