import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../repositories/repository_errors.dart';
import 'api_exceptions.dart';
import 'config.dart';

Dio buildAuthDio() {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}

Dio buildDio({
  required String? Function() tokenProvider,
  required Future<void> Function() refreshTokens,
  required Future<void> Function() onAuthFailed,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokenProvider();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('[API] -> ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            '[API] <- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
          );
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final isAuthRequest = error.requestOptions.path.contains('/auth/');
        final alreadyRetried = error.requestOptions.extra['authRetried'] == true;

        if (status == 401 && !isAuthRequest && !alreadyRetried) {
          try {
            await refreshTokens();
            final options = error.requestOptions;
            options.extra['authRetried'] = true;
            options.headers['Authorization'] = 'Bearer ${tokenProvider()}';
            final response = await dio.fetch(options);
            handler.resolve(response);
            return;
          } catch (_) {
            await onAuthFailed();
          }
        }

        if (kDebugMode) {
          debugPrint(
            '[API] !! ${error.type} ${error.requestOptions.method} ${error.requestOptions.uri}',
          );
        }

        if (status != null) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, error.response?.data),
            ),
          );
          return;
        }
        handler.reject(error);
      },
    ),
  );

  return dio;
}
