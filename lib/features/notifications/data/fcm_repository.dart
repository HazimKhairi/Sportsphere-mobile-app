import 'package:dio/dio.dart';

class FcmRepository {
  FcmRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<String> registerDevice({
    required String token,
    required String platform,
    required String appVersion,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/users/devices',
      data: {
        'token': token,
        'platform': platform,
        'appVersion': appVersion,
      },
    );
    return res.data!['deviceId'] as String;
  }

  Future<void> unregisterDevice(String deviceId) async {
    await _dio.delete<void>('/api/users/devices/$deviceId');
  }
}
