import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:safechat/utils/srp/srp.dart';
import 'package:safechat/utils/srp/utils.dart';

class AuthRepository {
  AuthRepository(this._apiService);

  final SRPClient _srpClient = SRPClient(
    N: PrimeGroups.prime_1024,
    g: PrimeGroups.g_1024,
  );
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Dio _apiService;

  Future<void> login(String email, String password) async {
    final res = await _apiService.post('/auth/challenge', data: {
      'email': email,
    });

    final B = BigInt.parse(res.data['B']);
    final s = BigInt.parse(res.data['s']);

    final a = await _srpClient.a();
    final A = _srpClient.A(a);
    final x = await _srpClient.x(email, password, s);
    final k = await _srpClient.k();
    final u = await _srpClient.u(A, B);
    final S = _srpClient.S(k, u, x, B, a);
    final m1 = await _srpClient.m1(A, B, S);

    final proof = await _apiService.post('/auth/proof', data: {
      'email': email,
      'A': A.toString(),
      'M1': m1.toString(),
    });

    final m2 = BigInt.parse(proof.data['M2']);
    final proofM2 = await _srpClient.proofServerM2(A, m1, S);

    if (m2 != proofM2) {
      throw 'Błąd autoryzacji.';
    }

    print({'S', S});
    print({'m1', m1});
    print({'server M2', proof.data['M2']});
    print({'proof M2', proofM2});

    print(proof.data);
    await _storage.write(
      key: 'JWT_TOKEN',
      value: proof.data['tokens']['accessToken'],
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

    await _apiService.post('/auth/signup', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'salt': s.toString(),
      'verifier': v.toString(),
    });
  }

  Future<void> logout() async {
    await _storage.delete(key: 'JWT_TOKEN');
  }

  Future<dynamic> getUser() async {
    final res = await _apiService.get('/auth/profile');
    return res.data;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'JWT_TOKEN');
  }
}
