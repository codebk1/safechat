import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safechat/user/repository/user_repository.dart';

import 'package:safechat/user/user.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._authRepository, this._userRepository) : super(UserState());

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<void> init() async {
    try {
      final token = await _authRepository.getAccessToken();

      if (token != null) {
        final user = await _userRepository.getUser();

        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> authenticate() async {
    final user = await _userRepository.getUser();

    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  Future<void> unauthenticate() async {
    await _authRepository.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: User.empty));
  }

  Future<void> updateProfile(String fN, String lN) async {
    await _userRepository.updateProfile(fN, lN);

    emit(state.copyWith(
      user: state.user.copyWith(firstName: fN, lastName: lN),
    ));
  }

  updateAvatar(List<int> processedAvatar) async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarFile = File('${directory.path}/${state.user.id}.jpg');

    imageCache!.evict(FileImage(avatarFile));
    final avatar = await avatarFile.writeAsBytes(processedAvatar);

    await _userRepository.updateAvatar(state.user.id, avatar);

    emit(state.copyWith(user: state.user.copyWith(avatar: avatar)));
  }

  removeAvatar() async {
    await _userRepository.removeAvatar();
    emit(state.copyWith(user: state.user.copyWith(avatar: null)));
  }
}
