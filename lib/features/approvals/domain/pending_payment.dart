class PendingPayment {
  const PendingPayment({
    required this.id,
    required this.payerName,
    required this.payerEmail,
    required this.description,
    required this.amountMinor,
    required this.currency,
    required this.paymentMethod,
    required this.createdAt,
  });

  final String id;
  final String payerName;
  final String payerEmail;
  final String description;
  final int amountMinor; // e.g. 10000 = MYR 100.00
  final String currency;
  final String paymentMethod; // 'cash' | 'fpx_manual'
  final DateTime createdAt;

  String get formattedAmount {
    final rm = amountMinor / 100.0;
    return 'MYR ${rm.toStringAsFixed(2)}';
  }
}
