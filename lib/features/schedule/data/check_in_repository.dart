import 'package:dio/dio.dart';

enum CheckInResult { success, mismatch, failure }

class CheckInRepository {
  CheckInRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<CheckInResult> checkIn({
    required String sessionId,
    required String qrPayload,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/attendance/check-in',
        data: {
          'sessionId': sessionId,
          'qrPayload': qrPayload,
        },
      );
      return CheckInResult.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        return CheckInResult.mismatch;
      }
      return CheckInResult.failure;
    }
  }
}
