import 'package:dio/dio.dart';
import '../repositories/repository_errors.dart';

Exception mapHttpError(int status, dynamic body) {
  final message = body is Map && body['message'] is String ? body['message'] as String : null;
  if (status == 422) {
    final errors = body is Map && body['errors'] is Map ? Map<String, dynamic>.from(body['errors'] as Map) : <String, dynamic>{};
    if (errors.isNotEmpty) {
      final e = errors.entries.first;
      return FieldValidationException(e.key, '${e.value}');
    }
    return const FieldValidationException('form', 'Ошибка валидации на сервере');
  }
  return switch (status) {
    401 => RepositoryUnauthorizedException(message ?? 'Требуется вход в систему.'),
    403 => RepositoryForbiddenException(message ?? 'Недостаточно прав для действия.'),
    404 => RepositoryNotFoundException(message ?? 'Запись не найдена.'),
    409 => RepositoryConflictException(message ?? 'Операция невозможна из-за связанных данных.'),
    _ => RepositoryNetworkException(message ?? 'Ошибка сервера, код $status.'),
  };
}

Exception mapDioError(DioException e) {
  final existing = e.error;
  if (existing is Exception && existing is! DioException) return existing;
  final status = e.response?.statusCode;
  if (status != null) return mapHttpError(status, e.response?.data);
  return switch (e.type) {
    DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout => const RepositoryNetworkException('Сервер не ответил вовремя.'),
    DioExceptionType.connectionError => const RepositoryNetworkException('Не удалось соединиться с сервером. Если сервер запущен, проверьте CORS в Console браузера.'),
    DioExceptionType.cancel => const RepositoryNetworkException('Запрос отменён.'),
    _ => const RepositoryNetworkException('Сетевая ошибка.'),
  };
}

Future<T> guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DioException catch (e) {
    throw mapDioError(e);
  }
}

Future<T> retryRead<T>(Future<T> Function() action) async {
  Object? last;
  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      return await action();
    } on RepositoryNetworkException catch (e) {
      last = e;
      if (e.message == 'Запрос отменён.') rethrow;
      if (attempt < 2) await Future<void>.delayed(Duration(milliseconds: 250 * (attempt + 1)));
    }
  }
  throw last ?? const RepositoryNetworkException('Не удалось выполнить запрос.');
}
