/*
 The following is a description of SRP-6 and 6a, the latest versions of SRP:

  N    A large safe prime (N = 2q+1, where q is prime)
       All arithmetic is done modulo N.
  g    A generator modulo N
  k    Multiplier parameter (k = H(N, g) in SRP-6a, k = 3 for legacy SRP-6)
  s    User's salt
  I    Username
  p    Cleartext Password
  H()  One-way hash function
  ^    (Modular) Exponentiation
  u    Random scrambling parameter
  a,b  Secret ephemeral values
  A,B  Public ephemeral values
  x    Private key (derived from p and s)
  v    Password verifier
*/

import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:safechat/utils/utils.dart';

class SRP {
  SRP({
    required this.N,
    required this.g,
  });

  final BigInt N;
  final BigInt g;

  final _encryptionService = EncryptionService();

  BigInt s(int length) {
    return _encryptionService.genereateSecureRandom().nextBigInteger(length);
  }

  Future<BigInt> x(String I, String P, BigInt s) async {
    final digest = SHA512Digest();
    final data = '$I:$P';
    var out = Uint8List(digest.digestSize);

    digest.update(Uint8List.fromList(data.codeUnits), 0, data.length);
    digest.doFinal(out, 0);

    final s0 = bigIntToBytesArray(s);
    digest.update(s0, 0, s0.length);
    digest.update(out, 0, out.length);
    digest.doFinal(out, 0);

    return bytesArrayToBigInt(out);
  }

  BigInt S(BigInt k, BigInt u, BigInt x, BigInt B, BigInt a) {
    return (B - (k * g.modPow(x, N))).modPow(a + (u * x), N);
  }

  Future<BigInt> K(BigInt S) async {
    final digest = SHA512Digest();
    final data = bigIntToBytesArray(S);
    var out = Uint8List(digest.digestSize);

    digest.update(data, 0, data.length);
    digest.doFinal(out, 0);

    return bytesArrayToBigInt(out);
  }

  Future<BigInt> u(BigInt A, BigInt B) async {
    final digest = SHA512Digest();
    var out = Uint8List(digest.digestSize);

    final paddedA = _pad(A, N);
    final paddedB = _pad(B, N);

    digest.update(paddedA, 0, paddedA.length);
    digest.update(paddedB, 0, paddedB.length);
    digest.doFinal(out, 0);

    return bytesArrayToBigInt(out);
  }

  Future<BigInt> k() async {
    final digest = SHA512Digest();
    var out = Uint8List(digest.digestSize);

    final bytesN = bigIntToBytesArray(N);
    final padgN = _pad(g, N);

    digest.update(bytesN, 0, bytesN.length);
    digest.update(padgN, 0, padgN.length);
    digest.doFinal(out, 0);

    return bytesArrayToBigInt(out);
  }

  BigInt v(BigInt x) {
    return g.modPow(x, N);
  }

  BigInt a() {
    BigInt a;

    do {
      a = _encryptionService.genereateSecureRandom().nextBigInteger(32) % N;
    } while (a == BigInt.zero);

    return a;
  }

  BigInt A(BigInt a) {
    return g.modPow(a, N); // A = g^a % N
  }

  BigInt proofServerM2(BigInt A, BigInt m1, BigInt K) {
    final digest = SHA512Digest();
    var out = Uint8List(digest.digestSize);

    final paddedA = _pad(A, N);
    final paddedM1 = _pad(m1, N);
    final paddedS = _pad(K, N);

    digest.update(paddedA, 0, paddedA.length);
    digest.update(paddedM1, 0, paddedM1.length);
    digest.update(paddedS, 0, paddedS.length);
    digest.doFinal(out, 0);

    return bytesArrayToBigInt(out);
  }

  BigInt m1(BigInt A, BigInt B, BigInt K) {
    final digest = SHA512Digest();
    var out = Uint8List(digest.digestSize);

    final paddedA = _pad(A, N);
    final paddedB = _pad(B, N);
    final paddedS = _pad(K, N);

    digest.update(paddedA, 0, paddedA.length);
    digest.update(paddedB, 0, paddedB.length);
    digest.update(paddedS, 0, paddedS.length);
    digest.doFinal(out, 0);

    return bytesArrayToBigInt(out);
  }

  // utils
  Uint8List _pad(BigInt num, BigInt N) {
    final targetLength = ((N.bitLength + 7) / 8).truncate();
    final bytes = bigIntToBytesArray(num);

    if (bytes.length < targetLength) {
      final tmp = Uint8List(targetLength);
      tmp.fillRange(0, targetLength - bytes.length, 0);
      tmp.setAll(targetLength - bytes.length, bytes);

      return tmp;
    }

    return bytes;
  }

  Uint8List bigIntToBytesArray(BigInt number) {
    final size = (number.bitLength + 7) >> 3;
    var result = Uint8List(size);

    for (var i = 0; i < size; i++) {
      result[size - i - 1] = (number & BigInt.from(0xff)).toInt();
      number = number >> 8;
    }

    return result;
  }

  BigInt bytesArrayToBigInt(Uint8List bytes) {
    var result = BigInt.from(0);

    for (var i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }

    return result;
  }
}
