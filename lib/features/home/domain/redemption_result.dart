class RedemptionResult {
  const RedemptionResult({
    required this.code,
    required this.remainingPoints,
    this.expiresAt,
  });

  final String code;
  final int remainingPoints;
  final DateTime? expiresAt;
}

class RewardsException implements Exception {
  RewardsException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'RewardsException($statusCode): $message';
}
