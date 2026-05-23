import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'club_id_interceptor.dart';

Dio buildApiClient({
  required String baseUrl,
  ClubIdInterceptor? clubIdInterceptor,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
  ));
  dio.interceptors.add(AuthInterceptor());
  if (clubIdInterceptor != null) {
    dio.interceptors.add(clubIdInterceptor);
  }
  return dio;
}
