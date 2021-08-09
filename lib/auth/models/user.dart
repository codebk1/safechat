import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String email;

  @override
  List<Object> get props => [firstName, lastName, email];

  User.fromJson(Map<String, dynamic> json)
      : firstName = json['firstName']!,
        lastName = json['lastName']!,
        email = json['email']!;

  static const empty = User(firstName: '', lastName: '', email: '');
}
