import 'package:equatable/equatable.dart';

enum MessageType { TEXT, PHOTO }

class Message extends Equatable {
  const Message({
    required this.sender,
    required this.type,
    required this.data,
  });

  final String sender;
  final MessageType type;
  final dynamic data;

  @override
  List<Object?> get props => [sender, type, data];

  static const empty = Message(sender: '', type: MessageType.TEXT, data: '');

  Message copyWith({
    String? sender,
    MessageType? type,
    dynamic data,
  }) {
    return Message(
      sender: sender ?? this.sender,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}
