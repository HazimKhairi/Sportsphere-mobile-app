import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../domain/nutrition_log.dart';

export '../domain/daily_summary.dart';
export '../domain/nutrition_log.dart';

class NutritionRepository {
  NutritionRepository({required Dio dio, FirebaseFirestore? firestore})
      : _dio = dio,
        _db = firestore ?? FirebaseFirestore.instance;

  final Dio _dio;
  final FirebaseFirestore _db;

  Stream<List<NutritionLog>> todayLogsStream(String userId) {
    final today = _todayStr();
    return logsForDateStream(userId, today);
  }

  Stream<List<NutritionLog>> logsForDateStream(String userId, String dateStr) {
    final parts = dateStr.split('-');
    final startOfDay = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _db
        .collection('users')
        .doc(userId)
        .collection('nutritionLogs')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: false)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => NutritionLog.fromDoc(d.id, d.data()))
            .toList());
  }

  Stream<List<NutritionLog>> recentLogsStream(String userId, {int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection('users')
        .doc(userId)
        .collection('nutritionLogs')
        .where('date', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('date', descending: false)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => NutritionLog.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<NutritionLog> analyzePhoto({
    required String base64Image,
    required String mimeType,
    required MealType mealType,
    required String authToken,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/nutrition/analyze-photo',
        data: {
          'image': base64Image,
          'mimeType': mimeType,
          'mealType': mealType.name,
        },
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );
      final data = res.data ?? const <String, dynamic>{};
      final log = data['log'] as Map<String, dynamic>;
      final id = log['id'] as String? ?? '';
      return NutritionLog.fromDoc(id, log);
    } on DioException catch (e) {
      throw NutritionException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Photo analysis failed'
            : 'Photo analysis failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<NutritionLog> logMeal({
    required String description,
    required MealType mealType,
    required String authToken,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/nutrition/log-text',
        data: {
          'description': description,
          'mealType': mealType.name,
        },
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );
      final data = res.data ?? const <String, dynamic>{};
      final log = data['log'] as Map<String, dynamic>;
      final id = log['id'] as String? ?? '';
      return NutritionLog.fromDoc(id, log);
    } on DioException catch (e) {
      throw NutritionException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Failed to log meal'
            : 'Failed to log meal',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteLog(String logId, String authToken) async {
    try {
      await _dio.delete<void>(
        '/api/nutrition/logs',
        queryParameters: {'id': logId},
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );
    } on DioException catch (e) {
      throw NutritionException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Delete log failed'
            : 'Delete log failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class NutritionException implements Exception {
  NutritionException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'NutritionException($statusCode): $message';
}
