import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safechat/contacts/models/contact.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

class ContactsRepository {
  final Dio _apiService = ApiService().init();
  final EncryptionService _encryptionService = EncryptionService();

  Future<List<ContactState>> getContacts() async {
    final res = await _apiService.get('/user/contacts');
    final contactsData = res.data as List;
    final directory = await getApplicationDocumentsDirectory();

    final contacts = contactsData.map((contactData) {
      final sharedKey = _encryptionService.rsaDecrypt(contactData['sharedKey']);
      return getContactState(contactData, directory, sharedKey);
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
      contact: Contact(
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
      '/user/key/public/id/$contactId',
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

  ContactState getContactState(
      contactData, Directory avatarsDirectory, Uint8List? sharedKey) {
    if (sharedKey != null) {
      contactData['profile']['firstName'] = utf8.decode(
        _encryptionService.chachaDecrypt(
          contactData['profile']['firstName'],
          sharedKey,
        ),
      );

      contactData['profile']['lastName'] = utf8.decode(
        _encryptionService.chachaDecrypt(
          contactData['profile']['lastName'],
          sharedKey,
        ),
      );

      if (contactData['profile']['avatar'] != null) {
        final decryptedAvatar = _encryptionService.chachaDecrypt(
          contactData['profile']['avatar'],
          sharedKey,
        );

        final avatar = File('${avatarsDirectory.path}/${contactData["id"]}.jpg')
          ..writeAsBytes(decryptedAvatar);

        contactData['profile']['avatar'] = avatar;
      }
    }

    return ContactState(
      contact: Contact.fromJson(contactData),
      currentState: CurrentState.values.firstWhere(
        (e) => e.toString().split('.').last == contactData['state']!,
      ),
    );
  }
}
