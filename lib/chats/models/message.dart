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
}
