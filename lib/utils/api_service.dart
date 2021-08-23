import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  Dio init() {
    Dio _dio = new Dio();
    _dio.interceptors.add(new ApiInterceptors());

    _dio.options.baseUrl = "https://ecae-95-40-109-89.ngrok.io";
    return _dio;
  }
}

class ApiInterceptors extends Interceptor {
  final _storage = FlutterSecureStorage();

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
