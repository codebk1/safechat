part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email(''),
    this.password = const Password(''),
    this.status = const FormStatus.init(),
  });

  final Email email;
  final Password password;
  final FormStatus status;

  LoginState copyWith({
    Email? email,
    Password? password,
    FormStatus? status,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [email, password, status];
}
