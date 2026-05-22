enum RegistrationStatusKind {
  active,
  pending,
  cancelled,
  unknown;

  static RegistrationStatusKind fromString(String? raw) {
    switch (raw) {
      case 'active':
        return RegistrationStatusKind.active;
      case 'pending':
      case 'PENDING_APPROVAL':
        return RegistrationStatusKind.pending;
      case 'cancelled':
        return RegistrationStatusKind.cancelled;
      default:
        return RegistrationStatusKind.unknown;
    }
  }
}

class RegistrationResult {
  const RegistrationResult({
    required this.registrationId,
    required this.status,
  });
  final String registrationId;
  final RegistrationStatusKind status;
}

class RegistrationException implements Exception {
  RegistrationException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'RegistrationException($statusCode): $message';
}
