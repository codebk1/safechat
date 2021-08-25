import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:safechat/utils/socket_service.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

import 'package:safechat/user/user.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._authRepository, this._userRepository) : super(UserState()) {
    print('INIT USER SOCKET');

    _wsService.socket.onConnectError((data) {
      print({'ERRRORRRRRRRR', data});
      //this.unauthenticate();
    });

    _wsService.socket.onConnect((_) {
      print('connected: ${state.user.id}');

      //emit(state.copyWith(user: state.user.copyWith(status: Status.ONLINE)));
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
