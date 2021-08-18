import 'dart:io';

import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final File? avatar;

  @override
  List<Object?> get props => [email, firstName, lastName, avatar];

  User.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['profile']['avatar'];

  static const empty = User(
    id: '',
    email: '',
    firstName: '',
    lastName: '',
  );

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    File? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
    );
  }
}
