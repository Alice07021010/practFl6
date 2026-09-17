import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';
import '../models/loan.dart';

class RoleApi {
  final Dio _dio;

  RoleApi(this._dio);

  Future<List<Loan>> myLoans() => _loans('/loans/mine');
  Future<List<Loan>> allLoans() => _loans('/loans');

  Future<void> renew(int id) => _guard(() async {
        await _dio.post('/loans/$id/renew');
      });

  Future<void> issue({required int bookId, required int readerId}) =>
      _guard(() async {
        await _dio.post('/loans', data: {'bookId': bookId, 'readerId': readerId});
      });

  Future<void> closeLoan(int id) => _guard(() async {
        await _dio.post('/loans/$id/close');
      });

  Future<List<AppUser>> users() => _guard(() async {
        final response = await _dio.get('/admin/users');
        return (response.data as List)
            .whereType<Map>()
            .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  Future<void> changeRole(int userId, Role role) => _guard(() async {
        await _dio.put('/admin/users/$userId/role', data: {'role': role.code});
      });

  Future<Map<String, dynamic>> stats() => _guard(() async {
        final response = await _dio.get('/admin/stats');
        return Map<String, dynamic>.from(response.data as Map);
      });

  Future<List<Loan>> _loans(String path) => _guard(() async {
        final response = await _dio.get(path);
        return (response.data as List)
            .whereType<Map>()
            .map((e) => Loan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
