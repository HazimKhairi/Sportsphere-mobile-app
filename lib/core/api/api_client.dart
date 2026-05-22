import 'package:dio/dio.dart';

import 'auth_interceptor.dart';

Dio buildApiClient({required String baseUrl}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
  ));
  dio.interceptors.add(AuthInterceptor());
  return dio;
}
