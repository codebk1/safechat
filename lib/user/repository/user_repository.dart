import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';

class UserRepository {
  static final _singleton = UserRepository._internal();

  factory UserRepository() {
    return _singleton;
  }

  UserRepository._internal();

  final SRP _srpClient = SRP(
    N: PrimeGroups.prime_2048,
    g: PrimeGroups.g_2048,
  );

  final _apiService = ApiService().init();
  final _encryptionService = EncryptionService();
  final _cacheManager = DefaultCacheManager();
  final _storage = const FlutterSecureStorage();

  User user = User.empty;

  Future<User> getUser() async {
    final res = await _apiService.get('/user', queryParameters: {
      'id': true,
      'email': true,
      'fcmToken': true,
      'profile': true,
    });

    user = User.fromJson(res.data);

    if (user.avatar != null) {
      var cachedFile = await _cacheManager.getFileFromCache(user.avatar);

      if (cachedFile != null) {
        user = user.copyWith(avatar: () => cachedFile.file);
      } else {
        final avatar = await getAvatar(user.avatar);
        final cachedAvatar = await _cacheManager.putFile(
          user.avatar,
          avatar,
          eTag: user.avatar,
          maxAge: const Duration(days: 14),
        );

        user = user.copyWith(
          avatar: () => cachedAvatar,
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

  Future<void> updateAvatar(String userId, Uint8List avatar) async {
    final encryptedAvatar = _encryptionService.chachaEncrypt(
      avatar,
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
        'update': {
          'avatar': null,
        }
      }
    });
  }

  Future<void> updateProfile(String firstName, String lastName) async {
    final encryptedFirstName = _encryptionService.chachaEncrypt(
      Uint8List.fromList(utf8.encode(firstName.trim())),
      _encryptionService.sharedKey!,
    );

    final encryptedLastName = _encryptionService.chachaEncrypt(
      Uint8List.fromList(utf8.encode(lastName.trim())),
      _encryptionService.sharedKey!,
    );

    await _apiService.patch('/user', data: {
      'profile': {
        'update': {
          'firstName': base64.encode(encryptedFirstName),
          'lastName': base64.encode(encryptedLastName),
        }
      }
    });
  }

  Future<dynamic> updatePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final res = await _apiService.get('/user', queryParameters: {
      'privateKey': true,
      'salt': true,
    });

    final salt = base64.decode(res.data['salt']);

    _encryptionService.chachaDecrypt(
      res.data['privateKey'],
      _encryptionService.argon2DeriveKey(currentPassword, salt),
    );

    final x = await _srpClient.x(
      email,
      newPassword,
      _srpClient.bytesArrayToBigInt(salt),
    );

    final v = _srpClient.v(x);

    final currentPrivateKey = await _storage.read(key: 'privateKey');

    final encryptedPrivateKey = _encryptionService.chachaEncrypt(
      base64.decode(currentPrivateKey!),
      _encryptionService.argon2DeriveKey(newPassword, salt),
    );

    final privateKeyRes = await _apiService.patch('/user', data: {
      'privateKey': base64.encode(encryptedPrivateKey),
      'verifier': base64.encode(_srpClient.bigIntToBytesArray(v)),
    });

    await _storage.write(
      key: 'privateKey',
      value: privateKeyRes.data['privateKey'],
    );

    _encryptionService.init();
  }

  Future<void> updateStatus(Status status) async {
    await _apiService.patch('/user', data: {
      'profile': {
        'update': {
          'status': describeEnum(status),
        }
      }
    });
  }

  Future<void> deleteAccount() async {
    await _apiService.delete('/user');
  }
}
