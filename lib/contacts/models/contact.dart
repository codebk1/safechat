import 'dart:io';

import 'package:equatable/equatable.dart';

enum Status { ONLINE, OFFLINE }

class Contact extends Equatable {
  const Contact({
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

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['profile']['avatar'],
        status = json['online']! == 1 ? Status.ONLINE : Status.OFFLINE;

  static const empty = Contact(
    id: '',
    email: '',
    firstName: '',
    lastName: '',
  );

  Contact copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    File? avatar,
    Status? status,
  }) {
    return Contact(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
    );
  }
}
