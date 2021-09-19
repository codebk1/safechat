import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/models/models.dart';
import 'package:safechat/user/user.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepository _authRepository;

  SignupCubit(this._authRepository) : super(const SignupState());

  Future<void> submit() async {
    try {
      emit(state.copyWith(status: const FormStatus.loading()));

      await _authRepository.signup(
        state.firstName.value,
        state.lastName.value,
        state.email.value,
        state.password.value,
      );

      emit(state.copyWith(status: const FormStatus.success()));
    } on DioError catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  void firstNameChanged(String value) {
    emit(state.copyWith(
      firstName: FirstName(value),
      status: const FormStatus.init(),
    ));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(
      lastName: LastName(value),
      status: const FormStatus.init(),
    ));
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
      status: const FormStatus.init(),
    ));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: Password(value),
      status: const FormStatus.init(),
    ));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(
      confirmPassword: Password(value),
      status: const FormStatus.init(),
    ));
  }
}
