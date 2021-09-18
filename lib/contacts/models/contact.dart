import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum Status { ONLINE, OFFLINE }
enum CurrentState { NEW, PENDING, ACCEPTED, REJECTED, DELETING }

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.status = Status.OFFLINE,
    this.currentState = CurrentState.NEW,
    this.sharedKey,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final dynamic avatar;
  final Status status;
  final CurrentState currentState;
  final Uint8List? sharedKey;

  @override
  List<Object?> get props => [
        email,
        firstName,
        lastName,
        avatar,
        status,
        currentState,
      ];

  Contact copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    dynamic avatar,
    Status? status,
    CurrentState? currentState,
    Uint8List? sharedKey,
  }) {
    return Contact(
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        avatar: avatar ?? this.avatar,
        status: status ?? this.status,
        currentState: currentState ?? this.currentState,
        sharedKey: sharedKey ?? this.sharedKey);
  }

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['profile']['avatar'],
        status = json['online']! == 1 ? Status.ONLINE : Status.OFFLINE,
        currentState = CurrentState.values.firstWhere((e) =>
            e.toString().split('.').last == (json['state'] ?? 'ACCEPTED')),
        sharedKey = json['sharedKey'];
}
