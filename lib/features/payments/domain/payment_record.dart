enum PaymentMethodKind {
  card,
  fpx,
  cash,
  unknown;

  static PaymentMethodKind fromString(String? raw) {
    switch (raw) {
      case 'card':
        return PaymentMethodKind.card;
      case 'fpx':
        return PaymentMethodKind.fpx;
      case 'cash':
        return PaymentMethodKind.cash;
      default:
        return PaymentMethodKind.unknown;
    }
  }

  String get label {
    switch (this) {
      case PaymentMethodKind.card:
        return 'Card';
      case PaymentMethodKind.fpx:
        return 'FPX';
      case PaymentMethodKind.cash:
        return 'Cash';
      case PaymentMethodKind.unknown:
        return 'Unknown';
    }
  }
}

enum PaymentStatusKind {
  cleared,
  pendingApproval,
  refunded,
  failed,
  unknown;

  static PaymentStatusKind fromString(String? raw) {
    switch (raw) {
      case 'cleared':
      case 'succeeded':
        return PaymentStatusKind.cleared;
      case 'PENDING_APPROVAL':
      case 'pending':
        return PaymentStatusKind.pendingApproval;
      case 'refunded':
        return PaymentStatusKind.refunded;
      case 'failed':
        return PaymentStatusKind.failed;
      default:
        return PaymentStatusKind.unknown;
    }
  }

  String get label {
    switch (this) {
      case PaymentStatusKind.cleared:
        return 'Paid';
      case PaymentStatusKind.pendingApproval:
        return 'Pending';
      case PaymentStatusKind.refunded:
        return 'Refunded';
      case PaymentStatusKind.failed:
        return 'Failed';
      case PaymentStatusKind.unknown:
        return 'Unknown';
    }
  }
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.amountCents,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
    this.programId,
    this.programName,
  });

  final String id;
  final int amountCents;
  final String currency;
  final PaymentMethodKind method;
  final PaymentStatusKind status;
  final DateTime createdAt;
  final String? programId;
  final String? programName;

  String get displayAmount {
    final amount = amountCents / 100;
    final prefix = currency == 'MYR' ? 'RM' : currency;
    return '$prefix ${amount.toStringAsFixed(2)}';
  }
}
