import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum Status { online, offline }
enum CurrentState { inviting, pending, accepted, rejected, deleting }
// INVITING

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.status = Status.offline,
    this.currentState = CurrentState.inviting,
    this.sharedKey,
    this.working = false,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final dynamic avatar;
  final Status status;
  final CurrentState currentState;
  final Uint8List? sharedKey;
  final bool working;

  @override
  List<Object?> get props => [
        email,
        firstName,
        lastName,
        avatar,
        status,
        currentState,
        working,
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
    bool? working,
  }) {
    return Contact(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      currentState: currentState ?? this.currentState,
      sharedKey: sharedKey ?? this.sharedKey,
      working: working ?? this.working,
    );
  }

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['profile']['avatar'],
        status = json['online']! == 1 ? Status.online : Status.offline,
        currentState = CurrentState.values.firstWhere((e) =>
            e.toString().split('.').last == (json['state'] ?? 'accepted')),
        sharedKey = json['sharedKey'],
        working = false;
}
