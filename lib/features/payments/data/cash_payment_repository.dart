import 'package:dio/dio.dart';

class CashDeclarationResult {
  const CashDeclarationResult({
    required this.paymentId,
    required this.status,
  });
  final String paymentId;
  final String status;
}

class CashDeclarationException implements Exception {
  CashDeclarationException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'CashDeclarationException($statusCode): $message';
}

class CashPaymentRepository {
  CashPaymentRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<CashDeclarationResult> declarePayment({
    required String programId,
    required int amountCents,
    String currency = 'MYR',
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/payments/cash/declare',
        data: {
          'programId': programId,
          'amount': amountCents,
          'currency': currency,
        },
      );
      final data = res.data ?? const <String, dynamic>{};
      return CashDeclarationResult(
        paymentId: data['paymentId'] as String,
        status: data['status'] as String,
      );
    } on DioException catch (e) {
      throw CashDeclarationException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Cash declare failed'
            : 'Cash declare failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
