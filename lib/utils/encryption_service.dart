import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {
  RSAPublicKey? publicKey;
  RSAPrivateKey? privateKey;
  Uint8List? sharedKey;

  Future<void> init() async {
    print('ENCRYPTION SERVICE INIT');
    final storage = FlutterSecureStorage();

    final publicKey = await storage.read(key: 'publicKey');
    final privateKey = await storage.read(key: 'privateKey');
    final sharedKey = await storage.read(key: 'sharedKey');

    if (publicKey != null && privateKey != null && sharedKey != null) {
      this.publicKey = parsePublicKeyFromPem(publicKey);
      this.privateKey = parsePrivateKeyFromPem(privateKey);
      this.sharedKey = base64.decode(sharedKey);
    }

    print('END INIT');
  }

  String rsaEncrypt(Uint8List data, [RSAPublicKey? key]) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(
        true,
        PublicKeyParameter<RSAPublicKey>(key ?? this.publicKey as RSAPublicKey),
      );

    final encryptedData = _processInBlocks(encryptor, data);

    return base64.encode(encryptedData);
  }

  Uint8List rsaDecrypt(String data) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false,
          PrivateKeyParameter<RSAPrivateKey>(privateKey as RSAPrivateKey));

    final decryptedData = _processInBlocks(decryptor, base64.decode(data));
    print(decryptedData);

    return decryptedData;
  }

  Uint8List argon2DeriveKey(String data, Uint8List salt) {
    final argon2 = Argon2BytesGenerator()
      ..init(Argon2Parameters(
        Argon2Parameters.ARGON2_id,
        salt,
        desiredKeyLength: 32,
      ));

    return argon2.process(Uint8List.fromList(data.codeUnits));
  }

  Uint8List chachaEncrypt(
    Uint8List data,
    Uint8List secretKey,
  ) {
    final nonce = genereateSecureRandom().nextBytes(12);
    final parameters = AEADParameters(
      KeyParameter(secretKey),
      128,
      nonce,
      Uint8List(0),
    );

    final encryptor = ChaCha20Poly1305(ChaCha7539Engine(), Poly1305())
      ..init(true, parameters);

    final encryptedData = Uint8List(
      encryptor.getOutputSize(data.length),
    );

    final len = encryptor.processBytes(
      data,
      0,
      data.length,
      encryptedData,
      0,
    );

    encryptor.doFinal(encryptedData, len);
    final encryptedDataWithNonce = BytesBuilder()
      ..add(nonce)
      ..add(encryptedData);

    return encryptedDataWithNonce.takeBytes();
  }

  Uint8List chachaDecrypt(
    String data,
    Uint8List secretKey,
  ) {
    Uint8List decodedData = base64.decode(data);

    final nonce = decodedData.sublist(0, 12);
    final encryptedData = decodedData.sublist(12, decodedData.length);

    final parameters = AEADParameters(
      KeyParameter(secretKey),
      128,
      nonce,
      Uint8List(0),
    );

    var decryptor = ChaCha20Poly1305(ChaCha7539Engine(), Poly1305())
      ..init(false, parameters);

    final decryptedData = Uint8List(
      decryptor.getOutputSize(data.length),
    );

    final len = decryptor.processBytes(
      encryptedData,
      0,
      encryptedData.length,
      decryptedData,
      0,
    );

    decryptor.doFinal(decryptedData, len);

    return decryptedData;
  }

  SecureRandom genereateSecureRandom() {
    final random = Random.secure();
    final bytes = Uint8List(32);

    for (int i = 0; i < 32; i++) {
      bytes[i] = random.nextInt(255);
    }

    return SecureRandom('Fortuna')..seed(KeyParameter(bytes));
  }

  RSAPublicKey parsePublicKeyFromPem(pemString) {
    Uint8List publicKeyDER = base64.decode(pemString);

    var parser = ASN1Parser(publicKeyDER);
    var sequence = parser.nextObject() as ASN1Sequence;

    var modulus, exponent;

    modulus = sequence.elements![0] as ASN1Integer;
    exponent = sequence.elements![1] as ASN1Integer;

    RSAPublicKey rsaPublicKey = RSAPublicKey(modulus.integer, exponent.integer);

    return rsaPublicKey;
  }

  RSAPrivateKey parsePrivateKeyFromPem(pemString) {
    Uint8List privateKeyDER = base64.decode(pemString);
    var asn1Parser = new ASN1Parser(privateKeyDER);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    var modulus, privateExponent, p, q;

    modulus = topLevelSeq.elements![0] as ASN1Integer;
    privateExponent = topLevelSeq.elements![1] as ASN1Integer;
    p = topLevelSeq.elements![2] as ASN1Integer;
    q = topLevelSeq.elements![3] as ASN1Integer;

    RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
      modulus.integer,
      privateExponent.integer,
      p.integer,
      q.integer,
    );

    return rsaPrivateKey;
  }

  Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }
}
