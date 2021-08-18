part of 'user_cubit.dart';

enum AuthStatus { unknow, authenticated, unauthenticated }

class UserState extends Equatable {
  const UserState({
    this.status = AuthStatus.unknow,
    this.user = User.empty,
  });

  final AuthStatus status;
  final User user;

  UserState copyWith({
    AuthStatus? status,
    User? user,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object> get props => [status, user];
}
