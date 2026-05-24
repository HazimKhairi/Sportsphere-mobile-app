import 'package:dio/dio.dart';

import '../domain/payment_intent.dart';

export '../domain/payment_intent.dart';

class PaymentIntentRepository {
  PaymentIntentRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<PaymentIntent> createPaymentIntent({
    required String programId,
    required String clubId,
    required int amountCents,
    String currency = 'MYR',
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/payments/mobile/payment-intent',
        data: {'programId': programId, 'clubId': clubId},
      );
      final data = res.data ?? const <String, dynamic>{};
      return PaymentIntent(
        clientSecret: data['clientSecret'] as String,
        paymentIntentId: data['paymentIntentId'] as String,
      );
    } on DioException catch (e) {
      throw PaymentIntentException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Payment intent failed'
            : 'Payment intent failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
