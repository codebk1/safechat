part of 'contact_cubit.dart';

enum Status { ONLINE, OFFLINE }
enum CurrentState { NEW, PENDING, ACCEPTED, REJECTED, DELETING }

class ContactState extends Equatable {
  const ContactState({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.status = Status.OFFLINE,
    this.currentState = CurrentState.NEW,
    this.sharedKey,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final Uint8List? avatar;
  final Status status;
  final CurrentState currentState;
  final Uint8List? sharedKey;

  @override
  List<Object?> get props => [
        email,
        firstName,
        lastName,
        avatar,
        status,
        currentState,
      ];

  ContactState copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    Uint8List? avatar,
    Status? status,
    CurrentState? currentState,
    Uint8List? sharedKey,
  }) {
    return ContactState(
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        avatar: avatar ?? this.avatar,
        status: status ?? this.status,
        currentState: currentState ?? this.currentState,
        sharedKey: sharedKey ?? this.sharedKey);
  }

  ContactState.fromJson(Map<String, dynamic> json)
      : id = json['id']!,
        email = json['email']!,
        firstName = json['profile']['firstName']!,
        lastName = json['profile']['lastName']!,
        avatar = json['profile']['avatar'] != null
            ? base64.decode(json['profile']['avatar'])
            : null,
        status = json['online']! == 1 ? Status.ONLINE : Status.OFFLINE,
        currentState = CurrentState.values.firstWhere((e) =>
            e.toString().split('.').last == (json['state'] ?? 'ACCEPTED')),
        sharedKey = json['sharedKey'];
}
