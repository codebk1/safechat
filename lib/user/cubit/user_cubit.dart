import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/socket_service.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:safechat/user/user.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._authRepository, this._userRepository)
      : super(const UserState()) {
    print('INIT USER SOCKET');

    _wsService.socket.onConnectError((data) {
      print({'ERRRORRRRRRRR', data});
      //this.unauthenticate();
    });

    _wsService.socket.onConnect((_) {
      print('connected: ${state.user.id}');

      //emit(state.copyWith(user: state.user.copyWith(status: Status.online)));
      _wsService.socket.emit('online', state.user.id);
    });

    // _wsService.socket.onDisconnect((data) {
    //   //_wsService.socket.emit('offline', state.user.id);
    // });

    print('END SOCKET INIT');
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final SocketService _wsService = SocketService();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  Future<void> authenticate() async {
    try {
      final token = await _authRepository.getAccessToken();

      if (token != null) {
        final user = await _userRepository.getUser();

        emit(state.copyWith(authState: AuthState.authenticated, user: user));

        _wsService.socket.io.options['extraHeaders'] = {
          'authorization': 'Bearer $token',
        };

        _wsService.socket.connect();
      } else {
        emit(state.copyWith(authState: AuthState.unauthenticated));
      }
    } on DioError catch (_) {
      emit(state.copyWith(authState: AuthState.unauthenticated));
    } catch (error) {
      print('ERRROR $error');
      emit(state.copyWith(authState: AuthState.unauthenticated));
    }
  }

  Future<void> unauthenticate() async {
    //print('offline');
    //_wsService.socket.emit('offline', state.user.id);

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

    return await _cacheManager.putFile(name, avatar);
  }

  Future<void> updateProfile(String fN, String lN) async {
    await _userRepository.updateProfile(fN, lN);

    emit(state.copyWith(
      user: state.user.copyWith(firstName: fN, lastName: lN),
    ));
  }

  updateAvatar(Uint8List processedAvatar) async {
    final avatarName = '${state.user.id}.jpg';
    final avatar = await _cacheManager.putFile(avatarName, processedAvatar);

    await _userRepository.updateAvatar(state.user.id, avatar);

    emit(state.copyWith(user: state.user.copyWith(avatar: avatarName)));
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
    emit(state.copyWith(user: state.user.copyWith(avatar: null)));
  }
}
