import 'package:dio/dio.dart';

class FcmRepository {
  FcmRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<void> registerToken(String token) async {
    await _dio.post<void>(
      '/api/notifications/fcm-token',
      data: {'token': token},
    );
  }

  Future<void> unregisterToken(String token) async {
    await _dio.delete<void>(
      '/api/notifications/fcm-token',
      data: {'token': token},
    );
  }
}
