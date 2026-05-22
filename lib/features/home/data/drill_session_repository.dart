import 'package:dio/dio.dart';

class DrillSessionResult {
  const DrillSessionResult({
    required this.sessionId,
    required this.streakDays,
  });
  final String sessionId;
  final int streakDays;
}

class DrillSessionException implements Exception {
  DrillSessionException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'DrillSessionException($statusCode): $message';
}

class DrillSessionRepository {
  DrillSessionRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<DrillSessionResult> recordSession({
    required String drillId,
    required int reps,
    required int durationMs,
    required String mode,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/player-app/drill-sessions',
        data: {
          'drillId': drillId,
          'reps': reps,
          'durationMs': durationMs,
          'mode': mode,
        },
      );
      final data = res.data ?? const <String, dynamic>{};
      return DrillSessionResult(
        sessionId: data['sessionId'] as String,
        streakDays: (data['streakDays'] as int?) ?? 0,
      );
    } on DioException catch (e) {
      throw DrillSessionException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Drill session save failed'
            : 'Drill session save failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
