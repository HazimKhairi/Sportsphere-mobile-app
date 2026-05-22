import 'package:dio/dio.dart';
import '../domain/drill_completion_result.dart';

class DrillCompletionRepository {
  DrillCompletionRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  /// Returns [DrillCompletionResult] on success.
  /// Throws [DrillAlreadyCompletedToday] if 409 (daily cap hit).
  /// Throws [DrillCompletionException] on other errors.
  Future<DrillCompletionResult> markComplete({required String drillId}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/player-app/drills/$drillId/complete',
      );
      final data = res.data ?? const <String, dynamic>{};
      return DrillCompletionResult(
        pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
        currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
        isNewBest: (data['isNewBest'] as bool?) ?? false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const DrillAlreadyCompletedToday();
      }
      throw DrillCompletionException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Mark complete failed'
            : 'Mark complete failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class DrillAlreadyCompletedToday implements Exception {
  const DrillAlreadyCompletedToday();
  @override
  String toString() => 'DrillAlreadyCompletedToday';
}

class DrillCompletionException implements Exception {
  DrillCompletionException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'DrillCompletionException($statusCode): $message';
}
