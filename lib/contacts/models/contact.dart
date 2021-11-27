import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';

enum Status { visible, idle, busy, invisible }
enum CurrentState { inviting, pending, accepted, rejected }

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.email,
    required this.status,
    this.firstName = '',
    this.lastName = '',
    this.isOnline = false,
    this.avatar,
    this.lastSeen,
    this.currentState = CurrentState.inviting,
    this.sharedKey,
    this.showActions = false,
    this.working = false,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final Status status;
  final bool isOnline;
  final dynamic avatar;
  final DateTime? lastSeen;
  final CurrentState currentState;
  final Uint8List? sharedKey;
  final bool showActions;
  final bool working;

  @override
  List<Object?> get props => [
        email,
        firstName,
        lastName,
        status,
        isOnline,
        avatar,
        lastSeen,
        currentState,
        showActions,
        working,
      ];

  Contact copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    Status? status,
    bool? isOnline,
    dynamic avatar,
    DateTime? lastSeen,
    CurrentState? currentState,
    Uint8List? sharedKey,
    bool? showActions,
    bool? working,
  }) {
    return Contact(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      avatar: avatar ?? this.avatar,
      lastSeen: lastSeen ?? this.lastSeen,
      currentState: currentState ?? this.currentState,
      sharedKey: sharedKey ?? this.sharedKey,
      showActions: showActions ?? this.showActions,
      working: working ?? this.working,
    );
  }

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['state'] == 'pending' ? null : json['profile']['avatar'],
        status = Status.values.firstWhere(
          (e) => describeEnum(e) == json['profile']['status']!,
        ),
        isOnline = json['isOnline']!,
        lastSeen = DateTime.parse(json['lastSeen']!),
        currentState = CurrentState.values.firstWhere(
            (e) => describeEnum(e) == (json['state'] ?? 'accepted')),
        sharedKey = json['sharedKey'],
        showActions = false,
        working = false;
}

extension CurrentStateExtension on CurrentState {
  bool get isAccepted => this == CurrentState.accepted;
  bool get isInviting => this == CurrentState.inviting;
  bool get isPending => this == CurrentState.pending;
}
