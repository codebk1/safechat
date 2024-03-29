import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

import 'package:safechat/utils/utils.dart';

AsymmetricKeyPair<PublicKey, PrivateKey> getRsaKeyPair(
  SecureRandom secureRandom,
) {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.from(65537), 4096, 64),
      secureRandom,
    ));

  return keyGen.generateKeyPair();
}

class AuthRepository {
  final SRP _srpClient = SRP(
    N: PrimeGroups.prime_2048,
    g: PrimeGroups.g_2048,
  );

  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService().init();
  final _encryptionService = EncryptionService()..init();

  Future<void> login(String email, String password) async {
    final a = _srpClient.a();
    final A = _srpClient.A(a);

    final res = await _apiService.post('/auth/challenge', data: {
      'email': email,
      'A': A.toString(),
    });

    final B = BigInt.parse(res.data['B']);
    final s = _srpClient.bytesArrayToBigInt(base64.decode(
      res.data['s'],
    ));

    if (B % _srpClient.N == BigInt.zero) {
      throw 'Błąd autoryzacji.';
    }

    final x = await _srpClient.x(email, password, s);
    final k = await _srpClient.k();
    final u = await _srpClient.u(A, B);
    final S = _srpClient.S(k, u, x, B, a);
    final K = await _srpClient.K(S);
    final m1 = _srpClient.m1(A, B, K);

    final proof = await _apiService.post('/auth/proof', data: {
      'email': email,
      'M1': m1.toString(),
    });

    final m2 = BigInt.parse(proof.data['M2']);
    final proofM2 = _srpClient.proofServerM2(A, m1, K);

    if (m2 != proofM2) {
      throw 'Błąd autoryzacji.';
    }

    await _storage.write(
      key: 'accessToken',
      value: proof.data['tokens']['accessToken'],
    );

    await _storage.write(
      key: 'refreshToken',
      value: proof.data['tokens']['refreshToken'],
    );

    await _storage.write(
      key: 'publicKey',
      value: proof.data['keys']['publicKey'],
    );

    final secretKey = _encryptionService.argon2DeriveKey(
      password,
      _srpClient.bigIntToBytesArray(s),
    );

    final decryptedPrivateKey = _encryptionService.chachaDecrypt(
      proof.data['keys']['privateKey'],
      secretKey,
    );

    await _storage.write(
      key: 'privateKey',
      value: base64.encode(decryptedPrivateKey),
    );

    final parsedPrivateKey = _encryptionService.parsePrivateKeyFromPem(
      base64.encode(decryptedPrivateKey),
    );

    final decryptedSharedKey = _encryptionService.rsaDecrypt(
      proof.data['keys']['sharedKey'],
      parsedPrivateKey,
    );

    _encryptionService.rsaDecrypt(
      proof.data['keys']['sharedKey'],
      parsedPrivateKey,
    );

    await _storage.write(
      key: 'sharedKey',
      value: base64.encode(decryptedSharedKey),
    );

    _encryptionService.init();

    await _apiService.patch('/user', data: {
      'fcmToken': await FirebaseMessaging.instance.getToken(),
    });
  }

  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> computeRSAKeyPair(
    SecureRandom secureRandom,
  ) async {
    return await compute(
      getRsaKeyPair,
      secureRandom,
    );
  }

  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final s = _srpClient.s(64);
    final x = await _srpClient.x(email, password, s);
    final v = _srpClient.v(x);

    final pair = await computeRSAKeyPair(
      _encryptionService.genereateSecureRandom(),
    );

    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    final asn1PublicKey = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus))
      ..add(ASN1Integer(publicKey.exponent));

    final asn1PrivateKey = ASN1Sequence()
      ..add(ASN1Integer(privateKey.modulus))
      ..add(ASN1Integer(privateKey.privateExponent))
      ..add(ASN1Integer(privateKey.p))
      ..add(ASN1Integer(privateKey.q));

    final secretKey = _encryptionService.argon2DeriveKey(
      password,
      _srpClient.bigIntToBytesArray(s),
    );

    final encryptedPrivateKey = _encryptionService.chachaEncrypt(
      asn1PrivateKey.encode(),
      secretKey,
    );

    final sharedKey = _encryptionService.genereateSecureRandom().nextBytes(32);

    final encryptedSharedKey = _encryptionService.rsaEncrypt(
      sharedKey,
      publicKey,
    );

    final encryptedFirstName = _encryptionService.chachaEncrypt(
      Uint8List.fromList(utf8.encode(firstName.trim())),
      sharedKey,
    );

    final encryptedLastName = _encryptionService.chachaEncrypt(
      Uint8List.fromList(utf8.encode(lastName.trim())),
      sharedKey,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();

    await _apiService.post('/auth/signup', data: {
      'profile': {
        'firstName': base64.encode(encryptedFirstName),
        'lastName': base64.encode(encryptedLastName),
      },
      'user': {
        'email': email,
        'salt': base64.encode(_srpClient.bigIntToBytesArray(s)),
        'verifier': base64.encode(_srpClient.bigIntToBytesArray(v)),
        'publicKey': base64.encode(asn1PublicKey.encode()),
        'privateKey': base64.encode(encryptedPrivateKey),
        'sharedKey': encryptedSharedKey,
        'fcmToken': fcmToken,
      }
    });
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }
}
