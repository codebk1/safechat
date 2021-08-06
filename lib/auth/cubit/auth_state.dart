part of 'auth_cubit.dart';

enum AuthStatus { unknow, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknow,
    this.user = User.empty,
  });

  final AuthStatus status;
  final User user;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object> get props => [status, user];
}
