import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;

  @override
  List<Object> get props => [email, firstName, lastName];

  User.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!;

  static const empty = User(id: '', email: '', firstName: '', lastName: '');
}
