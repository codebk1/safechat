part of 'user_cubit.dart';

enum AuthState { unknow, authenticated, unauthenticated }

class UserState extends Equatable {
  const UserState({
    this.authState = AuthState.unknow,
    this.user = User.empty,
    this.formStatus = FormStatus.init,
  });

  final AuthState authState;
  final User user;
  final FormStatus formStatus;

  @override
  List<Object> get props => [authState, user, formStatus];

  UserState copyWith({
    AuthState? authState,
    User? user,
    FormStatus? formStatus,
  }) {
    return UserState(
      authState: authState ?? this.authState,
      user: user ?? this.user,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
