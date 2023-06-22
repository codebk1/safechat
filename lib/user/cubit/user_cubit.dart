import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(
    this._authRepository,
    this._userRepository,
  ) : super(const UserState()) {
    _wsService.socket.onConnectError((data) {
      unauthenticate();
    });

    _wsService.socket.onConnect((_) {
      _wsService.socket.emit('online', state.user.id);
    });
  }

  final _wsService = SocketService();
  final _cacheManager = DefaultCacheManager();

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<void> authenticate() async {
    try {
      final token = await _authRepository.getAccessToken();

      if (token != null) {
        final user = await _userRepository.getUser();

        emit(state.copyWith(
          authState: AuthState.authenticated,
          user: user,
        ));

        _wsService.socket.io.options['extraHeaders'] = {
          'authorization': 'Bearer $token',
        };

        _wsService.socket.connect();
      } else {
        emit(state.copyWith(
          authState: AuthState.unauthenticated,
        ));
      }
    } on DioException catch (_) {
      emit(state.copyWith(
        authState: AuthState.unauthenticated,
      ));
    }
  }

  Future<void> unauthenticate() async {
    await _authRepository.logout();
    _wsService.socket.disconnect();

    emit(state.copyWith(
      authState: AuthState.unauthenticated,
      user: User.empty,
    ));
  }

  Future<File> getAvatar(String name) async {
    var cachedFile = await _cacheManager.getFileFromCache(name);

    if (cachedFile != null) {
      return cachedFile.file;
    }

    final avatar = await _userRepository.getAvatar(name);

    return await _cacheManager.putFile(
      name,
      avatar,
      eTag: name,
      maxAge: const Duration(days: 14),
    );
  }

  Future<void> updateProfile(String firstName, String lastName) async {
    await _userRepository.updateProfile(firstName, lastName);

    emit(state.copyWith(
      user: state.user.copyWith(
        firstName: firstName,
        lastName: lastName,
      ),
    ));
  }

  updateAvatar(Uint8List processedAvatar) async {
    final avatarName = '${state.user.id}.jpg';

    await _cacheManager.removeFile(avatarName);
    final avatar = await _cacheManager.putFile(
      avatarName,
      processedAvatar,
      key: 'avatar',
      eTag: avatarName,
      maxAge: const Duration(days: 14),
    );

    await _userRepository.updateAvatar(state.user.id, processedAvatar);

    emit(state.copyWith(
      user: state.user.copyWith(avatar: () => avatar),
    ));
  }

  updateStatus(Status status) async {
    emit(state.copyWith(
      user: state.user.copyWith(status: status),
    ));

    _wsService.socket.emit(
      'status',
      describeEnum(status),
    );

    await _userRepository.updateStatus(status);
  }

  removeAvatar() async {
    await _userRepository.removeAvatar();

    emit(state.copyWith(
      user: state.user.copyWith(avatar: () => null),
    ));
  }

  deleteAccount() async {
    emit(state.copyWith(formStatus: FormStatus.loading));

    await _userRepository.deleteAccount();
  }
}
