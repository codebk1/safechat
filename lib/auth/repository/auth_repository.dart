import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/export.dart';
import 'package:safechat/auth/models/user.dart';
import 'package:safechat/utils/encryption_service.dart';

import 'package:safechat/utils/srp/srp.dart';
import 'package:safechat/utils/srp/utils.dart';

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
  AuthRepository(this._apiService, this._encryptionService);

  final SRP _srpClient = SRP(
    N: PrimeGroups.prime_1024,
    g: PrimeGroups.g_1024,
  );

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Dio _apiService;
  final EncryptionService _encryptionService;

  Future<void> login(String email, String password) async {
    final res = await _apiService.post('/auth/challenge', data: {
      'email': email,
    });

    final B = BigInt.parse(res.data['B']);
    final s = _srpClient.bytesArrayToBigInt(base64.decode(res.data['s']));

    final a = await _srpClient.a();
    final A = _srpClient.A(a);
    final x = await _srpClient.x(email, password, s);
    final k = await _srpClient.k();
    final u = await _srpClient.u(A, B);
    final S = _srpClient.S(k, u, x, B, a);
    final m1 = await _srpClient.m1(A, B, S);

    //print({'S', S});
    //print({'m1', m1});

    final proof = await _apiService.post('/auth/proof', data: {
      'email': email,
      'A': A.toString(),
      'M1': m1.toString(),
    });

    final m2 = BigInt.parse(proof.data['M2']);
    final proofM2 = await _srpClient.proofServerM2(A, m1, S);

    //print({'server M2', proof.data['M2']});
    //print({'proof M2', proofM2});

    if (m2 != proofM2) {
      throw 'Błąd autoryzacji.';
    }

    // print(proof.data);

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

    Uint8List decodedKey = base64.decode(proof.data['keys']['privateKey']);

    final nonce = decodedKey.sublist(0, 12);
    final encryptedPrivateKey = decodedKey.sublist(12, decodedKey.length);

    // final parameters = AEADParameters(
    //   KeyParameter(secretKey),
    //   128,
    //   nonce,
    //   Uint8List(0),
    // );

    // var chaChaEngineDecrypt = ChaCha20Poly1305(ChaCha7539Engine(), Poly1305())
    //   ..init(false, parameters);

    // final dec = Uint8List(
    //     chaChaEngineDecrypt.getOutputSize(encryptedPrivateKey.length));
    // final len = chaChaEngineDecrypt.processBytes(
    //     encryptedPrivateKey, 0, encryptedPrivateKey.length, dec, 0);
    // chaChaEngineDecrypt.doFinal(dec, len);

    final decryptedPrivateKey = _encryptionService.chachaDecrypt(
      encryptedPrivateKey,
      secretKey,
      nonce,
    );

    await _storage.write(
      key: 'privateKey',
      value: base64.encode(decryptedPrivateKey),
    );

    _encryptionService.init();
  }

  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> computeRSAKeyPair(
    SecureRandom secureRandom,
  ) async {
    return await compute(getRsaKeyPair, secureRandom);
  }

  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final s = _srpClient.s(64);
    print(s);
    final x = await _srpClient.x(email, password, s);
    final v = _srpClient.v(x);

    final pair = await computeRSAKeyPair(_srpClient.genereateSecureRandom());
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final encryptedFirstName = encryptor.process(
      Uint8List.fromList(firstName.codeUnits),
    );

    final encryptedLastName = encryptor.process(
      Uint8List.fromList(lastName.codeUnits),
    );

    final asn1PublicKey = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus))
      ..add(ASN1Integer(publicKey.exponent));

    final asn1PrivateKey = ASN1Sequence()
      ..add(ASN1Integer(privateKey.modulus))
      ..add(ASN1Integer(privateKey.privateExponent))
      ..add(ASN1Integer(privateKey.p))
      ..add(ASN1Integer(privateKey.q));

    final encodedPrivateKey = asn1PrivateKey.encode();

    final secretKey = _encryptionService.argon2DeriveKey(
      password,
      _srpClient.bigIntToBytesArray(s),
    );

    final nonce = _srpClient.genereateSecureRandom().nextBytes(12);

    final encryptedPrivateKey = _encryptionService.chachaEncrypt(
      encodedPrivateKey,
      secretKey,
      nonce,
    );

    final bb = BytesBuilder()..add(nonce)..add(encryptedPrivateKey);
    final encryptedPrivateKeyWithNonce = bb.takeBytes();

    await _apiService.post('/auth/signup', data: {
      'firstName': base64.encode(encryptedFirstName),
      'lastName': base64.encode(encryptedLastName),
      'email': email,
      'salt': base64.encode(_srpClient.bigIntToBytesArray(s)),
      'verifier': base64.encode(_srpClient.bigIntToBytesArray(v)),
      'publicKey': base64.encode(asn1PublicKey.encode()),
      'privateKey': base64.encode(encryptedPrivateKeyWithNonce),
    });
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<dynamic> getUser() async {
    final res = await _apiService.get('/auth/profile');
    final user = User.fromJson(res.data);

    return User(
      firstName: _encryptionService.decrypt(user.firstName),
      lastName: _encryptionService.decrypt(user.lastName),
      email: user.email,
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }
}
