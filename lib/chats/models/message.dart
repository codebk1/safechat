import 'package:equatable/equatable.dart';

enum MessageType { TEXT, PHOTO }
enum MessageStatus { SENDING, SENT, FAILURE, UNKNOW }

class Message extends Equatable {
  const Message({
    required this.sender,
    required this.type,
    required this.data,
    this.status = MessageStatus.UNKNOW,
  });

  final String sender;
  final MessageType type;
  final dynamic data;
  final MessageStatus status;
  // final String[] unreadBy;

  @override
  List<Object?> get props => [sender, type, data, status];

  static const empty = Message(sender: '', type: MessageType.TEXT, data: '');

  Message copyWith({
    String? sender,
    MessageType? type,
    dynamic data,
    MessageStatus? status,
  }) {
    return Message(
      sender: sender ?? this.sender,
      type: type ?? this.type,
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }
}
