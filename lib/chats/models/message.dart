import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum MessageType { TEXT, PHOTO, VIDEO, FILE }
enum MessageStatus { SENDING, SENT, FAILURE, UNKNOW }

class MessageItem extends Equatable {
  const MessageItem({
    required this.type,
    required this.data,
  });

  final MessageType type;
  final dynamic data;

  @override
  List<Object?> get props => [type, data];

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
    required this.senderId,
    this.content = const [],
    this.status = MessageStatus.UNKNOW,
    this.unreadBy = const [],
  });

  final String? id;
  final String senderId;
  final List<MessageItem> content;
  final MessageStatus status;
  final List<String> unreadBy;

  @override
  List<Object?> get props => [senderId, content, status, unreadBy];

  static const empty = Message(
    senderId: '',
  );

  Message copyWith({
    String? id,
    String? senderId,
    List<MessageItem>? content,
    MessageStatus? status,
    List<String>? unreadBy,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      status: status ?? this.status,
      unreadBy: unreadBy ?? this.unreadBy,
    );
  }

  Message.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        senderId = json['sender']!,
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
      'id': this.id,
      'sender': this.senderId,
      'content': this
          .content
          .map((e) => {
                'type': describeEnum(e.type),
                'data': e.data,
              })
          .toList(),
      'unreadBy': this.unreadBy
    };
  }
}
