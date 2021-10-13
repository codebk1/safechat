part of 'login_cubit.dart';

class LoginState extends Equatable with ValidationMixin {
  const LoginState({
    this.email = const Email(''),
    this.password = const Password(''),
    this.formStatus = FormStatus.init,
  });

  final Email email;
  final Password password;
  final FormStatus formStatus;

  @override
  List<Object> get props => [email, password, formStatus];

  @override
  List<FormItem> get inputs => [email, password];

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
