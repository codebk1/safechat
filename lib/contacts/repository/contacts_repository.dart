import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/utils/utils.dart';

class ContactsRepository {
  final Dio _apiService = ApiService().init();
  final EncryptionService _encryptionService = EncryptionService();

  Future<List<ContactState>> getContacts() async {
    final res = await _apiService.get('/user/contacts');

    return await getDecryptedContactsList(res.data as List)
      ..toList();
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
      id: res.data['id'],
      email: res.data['email'],
      firstName: '',
      lastName: '',
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

  Future<List<ContactState>> getDecryptedContactsList(
      List<dynamic> contactsData,
      [Uint8List? sharedKey]) async {
    //final directory = await getApplicationDocumentsDirectory();

    final List<ContactState> contacts = [];

    for (var i = 0; i < contactsData.length; i++) {
      //print(contactsData[i]);

      if (sharedKey != null) {
        contactsData[i]['sharedKey'] = _encryptionService.chachaDecrypt(
          contactsData[i]['sharedKey'],
          sharedKey,
        );
      } else {
        contactsData[i]['sharedKey'] = contactsData[i]['sharedKey'] != null
            ? _encryptionService.rsaDecrypt(contactsData[i]['sharedKey'])
            : null;
      }

      var contact = ContactState.fromJson(contactsData[i]);
      //print(contact);

      if (contact.sharedKey != null) {
        contact = contact.copyWith(
          firstName: utf8.decode(
            _encryptionService.chachaDecrypt(
              contact.firstName,
              contact.sharedKey!,
            ),
          ),
          lastName: utf8.decode(
            _encryptionService.chachaDecrypt(
              contact.lastName,
              contact.sharedKey!,
            ),
          ),
        );

        if (contact.avatar != null) {
          final decryptedAvatar = _encryptionService.chachaDecrypt(
            base64.encode(contact.avatar!),
            contact.sharedKey!,
          );

          //final avatar = ;
          //print(contact.avatar);

          contact = contact.copyWith(avatar: decryptedAvatar);
        }
      }

      contacts.add(contact);
    }

    return contacts;
  }
}
