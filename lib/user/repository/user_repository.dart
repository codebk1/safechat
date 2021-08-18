import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safechat/user/models/user.dart';
import 'package:safechat/utils/utils.dart';

class UserRepository {
  UserRepository();

  final Dio _apiService = ApiService().init();
  final EncryptionService _encryptionService = EncryptionService();

  Future<User> getUser() async {
    final res = await _apiService.get('/user/profile');

    if (res.data['profile']['avatar'] != null) {
      final decryptedAvatar = _encryptionService.chachaDecrypt(
        res.data['profile']['avatar'],
        _encryptionService.sharedKey!,
      );

      final directory = await getApplicationDocumentsDirectory();
      final avatar = File('${directory.path}/${res.data["id"]}.jpg')
        ..writeAsBytes(decryptedAvatar);

      res.data['profile']['avatar'] = avatar;
    }

    final user = User.fromJson(res.data);

    return User(
      id: user.id,
      email: user.email,
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
      ),
      avatar: user.avatar,
    );
  }

  Future<void> updateAvatar(String userId, File avatar) async {
    final encryptedAvatar = _encryptionService.chachaEncrypt(
      avatar.readAsBytesSync(),
      _encryptionService.sharedKey!,
    );

    final formData = FormData.fromMap(
      {
        'avatar': MultipartFile.fromBytes(
          encryptedAvatar,
          filename: '$userId.jpg',
        )
      },
    );

    await _apiService.post('/user/profile/avatar', data: formData);
  }

  Future<void> removeAvatar() async {
    await _apiService.patch('/user/profile', data: {'avatar': null});
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

    await _apiService.patch('/user/profile', data: {
      'firstName': base64.encode(encryptedFirstName),
      'lastName': base64.encode(encryptedLastName),
    });
  }
}
