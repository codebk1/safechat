import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  Dio init() {
    Dio dio = Dio();

    dio.interceptors.add(
      ApiInterceptors(),
    );

    dio.options.baseUrl = dotenv.env['BASE_URL']!;

    return dio;
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
