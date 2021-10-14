part of 'signup_cubit.dart';

class SignupState extends Equatable with ValidationMixin {
  const SignupState({
    this.firstName = const FirstName(''),
    this.lastName = const LastName(''),
    this.email = const Email(''),
    this.password = const Password('', restrict: true),
    this.confirmPassword = const ConfirmPassword(value: '', password: ''),
    this.formStatus = FormStatus.init,
  });

  final FirstName firstName;
  final LastName lastName;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final FormStatus formStatus;

  @override
  List<FormItem> get inputs => [
        firstName,
        lastName,
        email,
        password,
        confirmPassword,
      ];

  @override
  List<Object> get props => [
        firstName,
        lastName,
        email,
        password,
        confirmPassword,
        formStatus,
      ];

  SignupState copyWith({
    FirstName? firstName,
    LastName? lastName,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    FormStatus? formStatus,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
