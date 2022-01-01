import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/contacts/contacts.dart';

class ContactsRepository {
  final Dio _apiService = ApiService().init();
  final EncryptionService _encryptionService = EncryptionService();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  Future<List<Contact>> getContacts() async {
    final res = await _apiService.get('/user/contacts');

    return await getDecryptedContactsList(res.data as List);
  }

  Future<Contact> addContact(String contactEmail) async {
    var publicKeyRes = await _apiService.get(
      '/user/key/public/${base64.encode(utf8.encode(contactEmail))}',
    );

    final encryptedSharedKey = _encryptionService.rsaEncrypt(
      _encryptionService.sharedKey!,
      _encryptionService.parsePublicKeyFromPem(
        publicKeyRes.data['publicKey'],
      ),
    );

    final addedContactRes = await _apiService.post('/user/contacts', data: {
      'userSharedKey': encryptedSharedKey,
      'contactEmail': contactEmail,
    });

    return Contact(
      id: addedContactRes.data['id'],
      email: addedContactRes.data['email'],
      status: Status.visible,
      currentState: CurrentState.pending,
    );
  }

  Future<Uint8List> getAvatar(String name, Uint8List sharedKey) async {
    final res = await _apiService.get('/user/profile/avatar/$name');

    return _encryptionService.chachaDecrypt(
      res.data,
      sharedKey,
    );
  }

  Future<dynamic> acceptInvitation(String contactId) async {
    final contactUser = await _apiService.get(
      '/user/key/public/id/$contactId',
    );

    final encryptedSharedKey = _encryptionService.rsaEncrypt(
      _encryptionService.sharedKey!,
      _encryptionService.parsePublicKeyFromPem(
        contactUser.data['publicKey'],
      ),
    );

    final res =
        await _apiService.post('/user/contacts/accept-invitation', data: {
      'contactId': contactId,
      'sharedKey': encryptedSharedKey,
    });

    return res.data;
  }

  Future<void> cancelInvitation(String contactId) async {
    await _apiService.post('/user/contacts/cancel-invitation', data: {
      'contactId': contactId,
    });
  }

  Future<void> deleteContact(String id) async {
    await _apiService.delete('/user/contacts/$id');
  }

  Future<List<Contact>> getDecryptedContactsList(List<dynamic> contactsData,
      [Uint8List? sharedKey]) async {
    final List<Contact> contacts = [];

    for (var i = 0; i < contactsData.length; i++) {
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

      var contact = Contact.fromJson(contactsData[i]);

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
          var cachedFile = await _cacheManager.getFileFromCache(contact.avatar);

          if (cachedFile != null) {
            contact = contact.copyWith(avatar: cachedFile.file);
          } else {
            final avatar = await getAvatar(contact.avatar, contact.sharedKey!);

            contact = contact.copyWith(
              avatar: await _cacheManager.putFile(
                contact.avatar,
                avatar,
                eTag: contact.avatar,
                maxAge: const Duration(days: 14),
              ),
            );
          }
        }
      }

      contacts.add(contact);
    }

    return contacts;
  }
}
