import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

class ContactsRepository {
  ContactsRepository();

  final Dio _apiService = ApiService().init();
  final EncryptionService _encryptionService = EncryptionService();

  Future<List<ContactState>> getContacts() async {
    final res = await _apiService.get('/user/contacts');
    final contactsData = res.data as List;
    final directory = await getApplicationDocumentsDirectory();

    final contacts = contactsData.map((value) {
      if (value['sharedKey'] != null) {
        value['profile']['firstName'] = utf8.decode(
          _encryptionService.chachaDecrypt(
            value['profile']['firstName'],
            _encryptionService.rsaDecrypt(value['sharedKey']),
          ),
        );

        value['profile']['lastName'] = utf8.decode(
          _encryptionService.chachaDecrypt(
            value['profile']['lastName'],
            _encryptionService.rsaDecrypt(value['sharedKey']),
          ),
        );

        if (value['profile']['avatar'] != null) {
          final decryptedAvatar = _encryptionService.chachaDecrypt(
            value['profile']['avatar'],
            _encryptionService.rsaDecrypt(value['sharedKey']),
          );

          final avatar = File('${directory.path}/${value["id"]}.jpg')
            ..writeAsBytes(decryptedAvatar);

          value['profile']['avatar'] = avatar;
        }
      }

      return ContactState(
        contact: User.fromJson(value),
        currentState: CurrentState.values
            .firstWhere((e) => e.toString().split('.').last == value['state']!),
      );
    });

    return contacts.toList();
  }

  Future<ContactState> addContact(User user, String contactEmail) async {
    final encodedContactEmail = base64.encode(utf8.encode(contactEmail));

    final contactPublicKeyRes = await _apiService.get(
      '/user/key/public/$encodedContactEmail',
    );

    final decodedPublicKey = _encryptionService.parsePublicKeyFromPem(
      contactPublicKeyRes.data['publicKey'],
    );

    final sharedKey = _encryptionService.sharedKey;

    final encryptedSharedKey = _encryptionService.rsaEncrypt(
      sharedKey!,
      decodedPublicKey,
    );

    final res = await _apiService.post('/user/contacts/add', data: {
      'userId': user.id,
      'userSharedKey': encryptedSharedKey,
      'contactEmail': contactEmail,
    });

    return ContactState(
      contact: User(
        id: res.data['id'],
        email: res.data['email'],
        firstName: '',
        lastName: '',
      ),
      currentState: CurrentState.PENDING,
    );
  }

  Future<void> acceptInvitation(String contactId) async {
    final contactUser = await _apiService.get(
      '/user/contacts/$contactId/user/public-key',
    );

    final decodedPublicKey = _encryptionService.parsePublicKeyFromPem(
      contactUser.data['publicKey'],
    );

    final sharedKey = _encryptionService.sharedKey;
    final encryptedSharedKey = _encryptionService.rsaEncrypt(
      sharedKey!,
      decodedPublicKey,
    );

    await _apiService.post('/user/contacts/accept-invitation', data: {
      'contactId': contactId,
      'sharedKey': encryptedSharedKey,
    });
  }

  Future<void> cancelInvitation(String contactId) async {
    await _apiService.post('/user/contacts/cancel-invitation', data: {
      'contactId': contactId,
    });
  }
}
