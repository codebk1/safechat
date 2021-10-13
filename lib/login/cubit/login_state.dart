part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email.init(),
    this.password = const Password.init(),
    this.formStatus = FormStatus.init,
  });

  final Email email;
  final Password password;
  final FormStatus formStatus;

  @override
  List<Object> get props => [email, password, formStatus];

  LoginState copyWith({
    Email? email,
    Password? password,
    FormStatus? formStatus,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
