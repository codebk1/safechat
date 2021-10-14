import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:safechat/contacts/contacts.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.status,
    required this.fcmToken,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final dynamic avatar;
  final Status status;
  final String fcmToken;

  @override
  List<Object?> get props => [
        email,
        firstName,
        lastName,
        avatar,
        status,
      ];

  static const empty = User(
    id: '',
    email: '',
    firstName: '',
    lastName: '',
    status: Status.visible,
    fcmToken: '',
  );

  User.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['profile']['avatar'],
        status = Status.values.firstWhere(
          (e) => describeEnum(e) == json['profile']['status']!,
        ),
        fcmToken = json['fcmToken']!;

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    dynamic avatar,
    Status? status,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
