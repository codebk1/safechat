import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  Dio init() {
    Dio _dio = Dio();
    _dio.interceptors.add(ApiInterceptors());

    _dio.options.baseUrl = "https://1c04-77-115-232-135.ngrok.io";
    return _dio;
  }
}

class ApiInterceptors extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<dynamic> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _storage.read(key: 'accessToken');

    if (accessToken != null) {
      options.headers["Authorization"] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }
}
