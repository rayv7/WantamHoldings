import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class TokenStore {
  static const _key = 'wantam_access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<String?> read() => _storage.read(key: _key);
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  Future<void> clear() => _storage.delete(key: _key);
}

class ApiClient {
  ApiClient(this._tokens) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokens.read();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) {
          handler.reject(error);
        },
      ),
    );
  }
  final TokenStore _tokens;
  late final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _run(() => _dio.get(path, queryParameters: query));
  Future<dynamic> post(String path, {Object? data}) =>
      _run(() => _dio.post(path, data: data));
  Future<dynamic> patch(String path, {Object? data}) =>
      _run(() => _dio.patch(path, data: data));

  Future<dynamic> _run(Future<Response<dynamic>> Function() request) async {
    try {
      return (await request()).data;
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map && data['message'] != null
          ? (data['message'] is List
                ? data['message'].join('\n')
                : data['message'].toString())
          : error.type == DioExceptionType.connectionError
          ? 'Cannot reach the banking server. Check the API URL and connection.'
          : 'Request failed. Please try again.';
      throw ApiException(message, statusCode: error.response?.statusCode);
    }
  }
}
