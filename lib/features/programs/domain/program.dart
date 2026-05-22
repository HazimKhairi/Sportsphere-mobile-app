class Program {
  const Program({
    required this.id,
    required this.name,
    required this.description,
    required this.basePriceCents,
    required this.currency,
    this.coverImageUrl,
    this.capacity,
    this.currentRegistrants = 0,
    this.registrationStart,
    this.registrationEnd,
  });

  final String id;
  final String name;
  final String description;

  /// Price in cents (sen for MYR). Display divides by 100.
  final int basePriceCents;
  final String currency;
  final String? coverImageUrl;
  final int? capacity;
  final int currentRegistrants;
  final DateTime? registrationStart;
  final DateTime? registrationEnd;

  /// Display amount as `RM 150.50` etc.
  String get displayPrice {
    if (basePriceCents == 0) return 'Free';
    final amount = basePriceCents / 100;
    final prefix = currency == 'MYR' ? 'RM' : currency;
    return '$prefix ${amount.toStringAsFixed(2)}';
  }
}
