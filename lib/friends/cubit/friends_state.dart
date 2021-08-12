part of 'friends_cubit.dart';

enum ListStatus { unknow, loading, success, failure }

class FriendsState extends Equatable {
  const FriendsState({
    this.email = const Email(''),
    this.status = const FormStatus.init(),
    this.listStatus = ListStatus.unknow,
    this.friends = const [],
  });

  final Email email;
  final FormStatus status;
  final ListStatus listStatus;
  final List<Friend> friends;

  FriendsState copyWith({
    Email? email,
    FormStatus? status,
    ListStatus? listStatus,
    List<Friend>? friends,
  }) {
    return FriendsState(
      email: email ?? this.email,
      status: status ?? this.status,
      listStatus: listStatus ?? this.listStatus,
      friends: friends ?? this.friends,
    );
  }

  @override
  List<Object> get props => [email, status, listStatus];
}
