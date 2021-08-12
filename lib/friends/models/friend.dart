import 'package:equatable/equatable.dart';

enum FriendState { NEW, PENDING, ACCEPTED, REJECTED }

class Friend extends Equatable {
  const Friend({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.state,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final FriendState state;
  final String email;

  @override
  List<Object> get props => [firstName, lastName];

  Friend.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        firstName = json['friend']['profile']['firstName'] ?? '',
        lastName = json['friend']['profile']['lastName'] ?? '',
        state = FriendState.values.firstWhere(
          (e) => e.toString().split('.').last == json['state']!,
        ),
        email = json['friend']['email']!;
}
