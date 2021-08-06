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

import 'package:cryptography/cryptography.dart';

class SRPClient {
  SRPClient({required this.N, required this.g});

  final BigInt N;
  final BigInt g;

  BigInt s(int length) {
    return bytesArrayToBigInt(SecretKeyData.random(length: length).bytes);
  }

  Future<BigInt> x(String I, String p, BigInt s) async {
    var sink = Sha512().newHashSink();

    sink.add(Uint8List.fromList((I + ':' + p).codeUnits));
    sink.close();

    var hash = await sink.hash();

    sink = Sha512().newHashSink();

    sink.add(bigIntToBytesArray(s));
    sink.add(hash.bytes);
    sink.close();

    hash = await sink.hash();

    return bytesArrayToBigInt(hash.bytes);
  }

  BigInt S(
    BigInt k,
    BigInt u,
    BigInt x,
    BigInt B,
    BigInt a,
  ) {
    return (B - (k * g.modPow(x, N)))
        .modPow(a + (u * x), N); // (B - (k * g^x)) ^ (a + (u * x)) % N
  }

  Future<BigInt> u(BigInt A, BigInt B) async {
    final paddedA = _pad(A, N);
    final paddedB = _pad(B, N);

    final sink = Sha512().newHashSink();

    sink.add(paddedA);
    sink.add(paddedB);
    sink.close();

    final hash = await sink.hash();

    return bytesArrayToBigInt(hash.bytes);
  }

  Future<BigInt> k() async {
    final sink = Sha512().newHashSink();

    sink.add(bigIntToBytesArray(N));
    sink.add(_pad(g, N));
    sink.close();

    final hash = await sink.hash();

    return bytesArrayToBigInt(hash.bytes);
  }

  BigInt v(BigInt x) {
    return g.modPow(x, N);
  }

  Future<BigInt> a() async {
    // final algorithm = AesGcm.with256bits();
    // final secretKey = await algorithm.newSecretKey();

    // final a = await secretKey.extractBytes();
    // return bytesArrayToBigInt(a);

    //var minBits = math.min(256, N.bitLength ~/ 2);
    // var min = BigInt.one << (minBits - 1);
    // var max = N - BigInt.one;
    BigInt bi;

    do {
      bi = bytesArrayToBigInt(SecretKeyData.random(length: 32).bytes) % N;
    } while (bi == BigInt.zero);

    return bi;
  }

  BigInt A(BigInt a) {
    return g.modPow(a, N); // A = g^a % N
  }

  Future<BigInt> proofServerM2(BigInt A, BigInt m1, BigInt S) async {
    final paddedA = _pad(A, N);
    final paddedM1 = _pad(m1, N);
    final paddedS = _pad(S, N);

    final sink = Sha512().newHashSink();

    sink.add(paddedA);
    sink.add(paddedM1);
    sink.add(paddedS);
    sink.close();

    final hash = await sink.hash();

    return bytesArrayToBigInt(hash.bytes);
  }

  Future<BigInt> m1(BigInt A, BigInt B, BigInt S) async {
    final paddedA = _pad(A, N);
    final paddedB = _pad(B, N);
    final paddedS = _pad(S, N);

    final sink = Sha512().newHashSink();

    sink.add(paddedA);
    sink.add(paddedB);
    sink.add(paddedS);
    sink.close();

    final hash = await sink.hash();

    return bytesArrayToBigInt(hash.bytes);
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
    // Not handling negative numbers. Decide how you want to do that.
    int bytes = (number.bitLength + 7) >> 3;
    var b256 = new BigInt.from(256);
    var result = new Uint8List(bytes);
    for (int i = 0; i < bytes; i++) {
      result[i] = number.remainder(b256).toInt();
      number = number >> 8;
    }
    return result;
  }

  BigInt bytesArrayToBigInt(List<int> bytes) {
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
