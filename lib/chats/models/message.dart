import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum MessageType { TEXT, PHOTO, VIDEO, FILE }
enum MessageStatus { SENDING, SENT, FAILURE, UNKNOW }

class MessageItem {
  const MessageItem({
    required this.type,
    required this.data,
  });

  final MessageType type;
  final dynamic data;

  MessageItem copyWith({
    MessageType? type,
    dynamic data,
  }) {
    return MessageItem(
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}

class Message extends Equatable {
  const Message({
    this.id,
    required this.sender,
    this.content = const [],
    this.status = MessageStatus.UNKNOW,
    this.unreadBy = const [],
  });

  final String? id;
  final String sender;
  final List<MessageItem> content;
  final MessageStatus status;
  final List<String> unreadBy;

  @override
  List<Object?> get props => [sender, content, status, unreadBy];

  static const empty = Message(
    sender: '',
  );

  Message copyWith({
    String? id,
    String? sender,
    List<MessageItem>? content,
    MessageStatus? status,
    List<String>? unreadBy,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      status: status ?? this.status,
      unreadBy: unreadBy ?? this.unreadBy,
    );
  }

  Message.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        sender = json['sender']!,
        content = (json['content']! as List)
            .map((item) => MessageItem(
                type: MessageType.values.firstWhere(
                  (e) => describeEnum(e) == item['type'],
                ),
                data: item['data']))
            .toList(),
        status = MessageStatus.SENT,
        unreadBy = List<String>.from(json['unreadBy']);

  Map toJson() {
    return {
      'sender': this.sender,
      'content': this
          .content
          .map((e) => {
                'type': describeEnum(e.type),
                'data': e.data,
              })
          .toList(),
    };
  }
}
