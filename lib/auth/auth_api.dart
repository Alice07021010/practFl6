import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResult> login(String username, String password) async {
    final data = await _post('/auth/login', {
      'username': username,
      'password': password,
    });
    return AuthResult.fromJson(data);
  }

  Future<AuthResult> register({
    required String username,
    required String displayName,
    required String password,
  }) async {
    final data = await _post('/auth/register', {
      'username': username,
      'displayName': displayName,
      'password': password,
    });
    return AuthResult.fromJson(data);
  }

  Future<AuthResult> refresh(String refreshToken) async {
    final data = await _post('/auth/refresh', {'refreshToken': refreshToken});
    return AuthResult.fromJson(data);
  }

  Future<AppUser> me(String accessToken) async {
    try {
      final response = await _dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return AppUser.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(path, data: data);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
