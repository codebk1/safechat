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
    final data = I + ':' + P;
    var out = Uint8List(digest.digestSize);

    digest.update(Uint8List.fromList(data.codeUnits), 0, data.length);
    digest.doFinal(out, 0);

    final _s = bigIntToBytesArray(s);
    digest.update(_s, 0, _s.length);
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

    final _bytesN = bigIntToBytesArray(N);
    final _padgN = _pad(g, N);

    digest.update(_bytesN, 0, _bytesN.length);
    digest.update(_padgN, 0, _padgN.length);
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

//   // SERVER
//   Future<BigInt> b() async {
//     final algorithm = AesGcm.with256bits();
//     final secretKey = await algorithm.newSecretKey();

//     final b = await secretKey.extractBytes();
//     return bytesArrayToBigInt(b);
//   }

//   BigInt B(BigInt b, BigInt k, BigInt v) {
//     return k * v + g.modPow(b, N); //B = k*v + g^b % N
//   }
// }

// void main() async {
//   SRPClient srpClient = SRPClient(
//     N: PrimeGroups.prime_1024,
//     g: PrimeGroups.g_1024,
//   );

//   var s = srpClient.s(64);
//   print({'s', s});
//   String I = 'janusz@gmail.com';
//   String p = 'password123';

//   var x = await srpClient.x(I, p, s);
//   print({'x', x});

//   var v = srpClient.v(x);
//   print({'v', v});
//   var k = await srpClient.k();
//   print({'k', k});

//   final a = await srpClient.a();
//   final A = srpClient.A(a);
//   print({'a', a});
//   print({'A', A});

//   // server
//   final b = await srpClient.b();
//   final B = srpClient.B(b, k, v);
//   print({'b', b});
//   print({'B', B});

//   final u = await srpClient.u(A, B);
//   print({'u', u});

//   final S = srpClient.S(k, u, x, B, a);
//   print({'clientS', S});

//   // server session key
//   final serverSessionKey = (v.modPow(u, srpClient.N) * A)
//       .modPow(b, srpClient.N); // (A * v^u) ^ b % N

//   print({'serverS', serverSessionKey});

//   final M1 = await srpClient.m1(A, B, S);

//   print({'M1', M1});

//   final M2 = await srpClient.proofM2(A, M1, S);

//   print({'M2', M2});

}
