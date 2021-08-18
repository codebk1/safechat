import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/models/models.dart';
import 'package:safechat/user/user.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._userCubit, this._authRepository) : super(LoginState());

  final UserCubit _userCubit;
  final AuthRepository _authRepository;

  Future<void> submit() async {
    try {
      emit(state.copyWith(status: FormStatus.loading()));

      await _authRepository.login(state.email.value, state.password.value);
      await _userCubit.authenticate();

      emit(state.copyWith(status: FormStatus.success()));
    } on DioError catch (e) {
      print(e);
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.toString()),
      ));
    }
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
      status: FormStatus.init(),
    ));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: Password(value),
      status: FormStatus.init(),
    ));
  }
}
