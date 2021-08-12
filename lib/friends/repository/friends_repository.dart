import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:safechat/auth/models/user.dart';
import 'package:safechat/friends/models/friend.dart';
import 'package:safechat/utils/utils.dart';

class FriendsRepository {
  FriendsRepository(this._apiService, this._encryptionService);

  final Dio _apiService;
  final EncryptionService _encryptionService;

  Future<List<Friend>> getFriends() async {
    final res = await _apiService.get('/user/friends');
    final friendsData = res.data['friends'] as List;

    final friends = friendsData.map((value) {
      value['friend']['profile']['firstName'] = utf8.decode(
        _encryptionService.chachaDecrypt(
          value['friend']['profile']['firstName'],
          _encryptionService.rsaDecrypt(value['sharedKey']),
        ),
      );

      value['friend']['profile']['lastName'] = utf8.decode(
        _encryptionService.chachaDecrypt(
          value['friend']['profile']['lastName'],
          _encryptionService.rsaDecrypt(value['sharedKey']),
        ),
      );

      return Friend.fromJson(value);
    });

    return friends.toList();
  }

  Future<void> addFriend(User user, String friendEmail) async {
    final encodedFriendEmail = base64.encode(utf8.encode(friendEmail));

    final friendPublicKeyRes = await _apiService.get(
      '/user/key/public/$encodedFriendEmail',
    );

    final decodedPublicKey = _encryptionService.parsePublicKeyFromPem(
      friendPublicKeyRes.data['publicKey'],
    );

    final sharedKey = _encryptionService.sharedKey;

    print(sharedKey);

    final encryptedSharedKey =
        _encryptionService.rsaEncrypt(sharedKey!, decodedPublicKey);

    final res = await _apiService.post('/user/friends/add', data: {
      'userId': user.id,
      'friendEmail': friendEmail,
      'sharedKey': encryptedSharedKey,
    });

    print(res.data);
  }
}
