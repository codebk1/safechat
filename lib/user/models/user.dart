import 'dart:io';

import 'package:equatable/equatable.dart';

enum Status { ONLINE, OFFLINE }

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.status = Status.OFFLINE,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final File? avatar;
  final Status status;

  @override
  List<Object?> get props => [email, firstName, lastName, avatar, status];

  User.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['profile']['avatar'],
        status = Status.OFFLINE;

  static const empty = User(
    id: '',
    email: '',
    firstName: '',
    lastName: '',
  );

  User copyWith(
      {String? id,
      String? email,
      String? firstName,
      String? lastName,
      File? avatar,
      Status? status}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
    );
  }
}
