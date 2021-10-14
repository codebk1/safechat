import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';

class UserRepository {
  static final _singleton = UserRepository._internal();

  factory UserRepository() {
    return _singleton;
  }

  UserRepository._internal();

  final _apiService = ApiService().init();
  final _encryptionService = EncryptionService();
  final _cacheManager = DefaultCacheManager();

  User user = User.empty;

  Future<User> getUser() async {
    final res = await _apiService.get('/user/profile');

    user = User.fromJson(res.data);

    if (user.avatar != null) {
      var cachedFile = await _cacheManager.getFileFromCache(user.avatar);

      if (cachedFile != null) {
        user = user.copyWith(avatar: cachedFile.file);
      } else {
        final avatar = await getAvatar(user.avatar);

        user = user.copyWith(
          avatar: await _cacheManager.putFile(user.avatar, avatar),
        );
      }
    }

    user = user.copyWith(
        firstName: utf8.decode(
          _encryptionService.chachaDecrypt(
            user.firstName,
            _encryptionService.sharedKey!,
          ),
        ),
        lastName: utf8.decode(
          _encryptionService.chachaDecrypt(
            user.lastName,
            _encryptionService.sharedKey!,
          ),
        ));

    return user;
  }

  Future<Uint8List> getAvatar(String name) async {
    final res = await _apiService.get('/user/profile/avatar/$name');

    return _encryptionService.chachaDecrypt(
      res.data,
      _encryptionService.sharedKey!,
    );
  }

  Future<void> updateAvatar(String userId, File avatar) async {
    final encryptedAvatar = _encryptionService.chachaEncrypt(
      avatar.readAsBytesSync(),
      _encryptionService.sharedKey!,
    );

    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(
        encryptedAvatar,
        filename: '$userId.jpg',
      )
    });

    await _apiService.post('/user/profile/avatar', data: formData);
  }

  Future<void> removeAvatar() async {
    await _apiService.patch('/user', data: {
      'profile': {
        'avatar': null,
      }
    });
  }

  Future<void> updateProfile(String fN, String lN) async {
    final encryptedFirstName = _encryptionService.chachaEncrypt(
      Uint8List.fromList(utf8.encode(fN.trim())),
      _encryptionService.sharedKey!,
    );

    final encryptedLastName = _encryptionService.chachaEncrypt(
      Uint8List.fromList(utf8.encode(lN.trim())),
      _encryptionService.sharedKey!,
    );

    await _apiService.patch('/user', data: {
      'profile': {
        'firstName': base64.encode(encryptedFirstName),
        'lastName': base64.encode(encryptedLastName),
      }
    });
  }

  Future<void> updateStatus(Status status) async {
    await _apiService.patch('/user', data: {
      'profile': {
        'status': describeEnum(status),
      }
    });
  }
}
