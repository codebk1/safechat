import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/user/user.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(
    this._authRepository,
  ) : super(const SignupState());

  final AuthRepository _authRepository;

  Future<void> submit() async {
    emit(state.copyWith(formStatus: FormStatus.submiting));

    if (state.validate.isValid) {
      try {
        emit(state.copyWith(formStatus: FormStatus.loading));

        await _authRepository.signup(
          state.firstName.value,
          state.lastName.value,
          state.email.value,
          state.password.value,
        );

        emit(state.copyWith(formStatus: const FormStatus.success()));
      } on DioError catch (e) {
        emit(state.copyWith(
          formStatus: FormStatus.failure(e.response!.data['message']),
        ));
      }
    }
  }

  void firstNameChanged(String value) {
    emit(state.copyWith(
      firstName: FirstName(value),
    ));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(
      lastName: LastName(value),
    ));
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
    ));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: Password(value, restrict: true),
    ));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(
      confirmPassword: ConfirmPassword(
        value: value,
        password: state.password.value,
      ),
    ));
  }
}
