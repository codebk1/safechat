import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:safechat/auth/auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(AuthState());

  final AuthRepository _authRepository;

  Future<void> init() async {
    try {
      final token = await _authRepository.getToken();

      if (token != null) {
        final data = await _authRepository.getUser();
        final user = User.fromJson(data);

        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> authenticate() async {
    final data = await _authRepository.getUser();
    final user = User.fromJson(data);

    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  Future<void> unauthenticate() async {
    await _authRepository.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: User.empty));
  }
}
