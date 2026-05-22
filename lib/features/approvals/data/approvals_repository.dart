import 'package:dio/dio.dart';

import '../domain/pending_payment.dart';

class ApprovalsRepository {
  ApprovalsRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<List<PendingPayment>> fetchPending({required String clubId}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/admin/payments/pending',
        options: Options(headers: {'X-Club-Id': clubId}),
      );
      final data = res.data ?? const <String, dynamic>{};
      final rawList = data['pendingApproval'] as List<dynamic>? ?? [];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApprovalsException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Failed to load approvals'
            : 'Failed to load approvals',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> approve(
      {required String paymentId, required String clubId}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/admin/payments/$paymentId/approve',
        data: <String, dynamic>{},
        options: Options(headers: {'X-Club-Id': clubId}),
      );
    } on DioException catch (e) {
      throw ApprovalsException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ?? 'Approve failed'
            : 'Approve failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> reject({
    required String paymentId,
    required String clubId,
    required String reason,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/admin/payments/$paymentId/reject',
        data: {'reason': reason},
        options: Options(headers: {'X-Club-Id': clubId}),
      );
    } on DioException catch (e) {
      throw ApprovalsException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ?? 'Reject failed'
            : 'Reject failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  PendingPayment _fromJson(Map<String, dynamic> e) {
    DateTime createdAt = DateTime.now();
    final rawTs = e['createdAt'];
    if (rawTs is Map) {
      final seconds = (rawTs['_seconds'] as num?)?.toInt();
      if (seconds != null) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    } else if (rawTs is String) {
      createdAt = DateTime.tryParse(rawTs) ?? createdAt;
    }
    return PendingPayment(
      id: e['id'] as String? ?? '',
      payerName: e['payerName'] as String? ?? 'Unknown',
      payerEmail: e['payerEmail'] as String? ?? '',
      description: e['description'] as String? ?? '',
      amountMinor: (e['customerTotal'] as num?)?.toInt() ??
          (e['base'] as num?)?.toInt() ??
          0,
      currency: e['currency'] as String? ?? 'MYR',
      paymentMethod: e['paymentMethod'] as String? ?? 'cash',
      createdAt: createdAt,
    );
  }
}

class ApprovalsException implements Exception {
  ApprovalsException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApprovalsException($statusCode): $message';
}
