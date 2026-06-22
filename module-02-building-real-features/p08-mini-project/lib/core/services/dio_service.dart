// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/core/services/dio_service.dart
//
// Centralised Dio HTTP client with interceptors.
// Slide reference: P05 "Dio Setup & Interceptors"
// Key quote: "Interceptors add auth tokens to every request
//             automatically without touching your call sites."
// ============================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Base URLs — switch easily between environments
class ApiConfig {
  static const baseUrl = 'https://jsonplaceholder.typicode.com';
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 10);
}

// Provider — gives a configured Dio instance to anything that needs it
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // --------------------------------------------------------
  // INTERCEPTORS — middleware that runs on every request/response
  // --------------------------------------------------------

  // 1. Auth Interceptor — adds Bearer token automatically
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // In production: read token from secure storage
        // final token = await secureStorage.read(key: 'access_token');
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }

        // For this demo (JSONPlaceholder doesn't need auth):
        handler.next(options); // continue with the request
      },

      onError: (DioException error, handler) async {
        // Handle 401 Unauthorized — token expired
        if (error.response?.statusCode == 401) {
          // Try to refresh the token, then retry the request
          // In production: call your refresh endpoint
          handler.reject(error); // for now, just reject
          return;
        }
        handler.next(error);
      },
    ),
  );

  // 2. Logging Interceptor — see every request in debug console
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: false, // don't log headers (may contain tokens)
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[HTTP] $obj'),
    ),
  );

  return dio;
});

// Helper: convert DioException to a user-friendly message
String dioErrorMessage(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout =>
      'Connection timed out. Check your internet.',
    DioExceptionType.receiveTimeout =>
      'Server took too long to respond.',
    DioExceptionType.connectionError =>
      'No internet connection.',
    DioExceptionType.badResponse => () {
        final code = e.response?.statusCode;
        return switch (code) {
          400 => 'Bad request — check your input.',
          401 => 'Not authorised. Please log in again.',
          403 => 'You don\'t have permission for this.',
          404 => 'Resource not found.',
          500 => 'Server error — try again later.',
          _ => 'Request failed (code: $code)',
        };
      }(),
    _ => e.message ?? 'An unknown error occurred.',
  };
}
