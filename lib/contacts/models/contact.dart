import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum Status { visible, idle, busy, invisible }
enum CurrentState { inviting, pending, accepted, rejected, deleting }
// INVITING

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.status,
    required this.isOnline,
    this.lastSeen,
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
  final bool isOnline;
  final DateTime? lastSeen;
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
        isOnline,
        lastSeen,
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
    bool? isOnline,
    DateTime? lastSeen,
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
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
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
        status = Status.values.firstWhere(
          (e) => describeEnum(e) == json['profile']['status']!,
        ),
        isOnline = json['isOnline']!,
        lastSeen = DateTime.parse(json['lastSeen']!),
        //json['lastSeen'] == null ? null : DateTime.parse(json['lastSeen']),
        currentState = CurrentState.values.firstWhere(
            (e) => describeEnum(e) == (json['state'] ?? 'accepted')),
        sharedKey = json['sharedKey'],
        working = false;
}
