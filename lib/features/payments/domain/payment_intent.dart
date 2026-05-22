class PaymentIntent {
  const PaymentIntent({
    required this.clientSecret,
    required this.paymentIntentId,
  });
  final String clientSecret;
  final String paymentIntentId;
}

class PaymentIntentException implements Exception {
  PaymentIntentException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'PaymentIntentException($statusCode): $message';
}
