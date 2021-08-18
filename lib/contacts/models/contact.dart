import 'dart:io';

import 'package:equatable/equatable.dart';

enum ContactState { NEW, PENDING, ACCEPTED, REJECTED, DELETING }

class Contact extends Equatable {
  Contact({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.state,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  File? avatar;
  final ContactState state;

  @override
  List<Object?> get props => [id, email, firstName, lastName, avatar, state];

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email'],
        firstName = json['profile']['firstName'] ?? '',
        lastName = json['profile']['lastName'] ?? '',
        avatar = json['profile']['avatar'],
        state = ContactState.values.firstWhere(
          (e) => e.toString().split('.').last == json['state']!,
        );

  Contact copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    File? avatar,
    ContactState? state,
  }) {
    return Contact(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar,
      state: state ?? this.state,
    );
  }
}
