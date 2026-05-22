class Voucher {
  const Voucher({
    required this.id,
    required this.code,
    required this.rewardName,
    required this.discountValue,
    required this.expiresAt,
    required this.status,
  });

  final String id;
  final String code;
  final String rewardName;
  final String discountValue;
  final DateTime expiresAt;
  final String status; // 'active', 'used', 'expired'

  bool get isActive => status == 'active';
}
