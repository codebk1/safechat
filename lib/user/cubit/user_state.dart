part of 'user_cubit.dart';

enum AuthState { unknow, authenticated, unauthenticated }

class UserState extends Equatable {
  const UserState({
    this.authState = AuthState.unknow,
    this.user = User.empty,
  });

  final AuthState authState;
  final User user;

  UserState copyWith({
    AuthState? authState,
    User? user,
  }) {
    return UserState(
      authState: authState ?? this.authState,
      user: user ?? this.user,
    );
  }

  @override
  List<Object> get props => [authState, user];
}
