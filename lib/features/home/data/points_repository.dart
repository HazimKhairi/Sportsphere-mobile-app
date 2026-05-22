import 'package:dio/dio.dart';

import '../domain/points_entry.dart';
import '../domain/points_summary.dart';

class PointsRepository {
  PointsRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<PointsSummary> fetchSummary() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/player-app/points');
      final data = res.data ?? const <String, dynamic>{};
      final rawHistory = data['history'] as List<dynamic>? ?? [];
      final history = rawHistory
          .whereType<Map<String, dynamic>>()
          .map((e) => PointsEntry(
                id: e['id'] as String? ?? '',
                action: e['action'] as String? ?? '',
                points: (e['points'] as num?)?.toInt() ?? 0,
                description: e['description'] as String? ?? '',
                balanceAfter: (e['balanceAfter'] as num?)?.toInt() ?? 0,
                createdAt: DateTime.tryParse(e['createdAt'] as String? ?? '') ??
                    DateTime(0),
              ))
          .toList();
      return PointsSummary(
        totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
        availablePoints: (data['availablePoints'] as num?)?.toInt() ?? 0,
        history: history,
      );
    } on DioException catch (e) {
      throw PointsException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Failed to load points'
            : 'Failed to load points',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class PointsException implements Exception {
  PointsException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'PointsException($statusCode): $message';
}
