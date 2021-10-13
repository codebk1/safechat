import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import 'package:safechat/common/models/models.dart';
import 'package:safechat/utils/utils.dart';
import 'package:safechat/user/user.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._userCubit, this._authRepository) : super(const LoginState());

  final UserCubit _userCubit;
  final AuthRepository _authRepository;

  Future<void> submit() async {
    emit(state.copyWith(formStatus: FormStatus.submiting));

    if (state.validate.isValid) {
      try {
        emit(state.copyWith(formStatus: FormStatus.loading));

        await _authRepository.login(state.email.value, state.password.value);
        await _userCubit.authenticate();

        emit(state.copyWith(formStatus: FormStatus.success));
      } on DioError catch (e) {
        emit(state.copyWith(
          formStatus: FormStatus.failure(e.response?.data['message']),
        ));
      } catch (e) {
        emit(state.copyWith(
          formStatus: FormStatus.failure(e.toString()),
        ));
      }
    }
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
    ));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: Password(value),
    ));
  }
}
