part of 'signup_cubit.dart';

class SignupState extends Equatable {
  const SignupState({
    this.firstName = const FirstName(''),
    this.lastName = const LastName(''),
    this.email = const Email(''),
    this.password = const Password(''),
    this.confirmPassword = const Password(''),
    this.status = const FormStatus.init(),
  });

  final FirstName firstName;
  final LastName lastName;
  final Email email;
  final Password password;
  final Password confirmPassword;
  final FormStatus status;

  SignupState copyWith({
    FirstName? firstName,
    LastName? lastName,
    Email? email,
    Password? password,
    Password? confirmPassword,
    FormStatus? status,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [
        firstName,
        lastName,
        email,
        password,
        confirmPassword,
        status,
      ];
}
