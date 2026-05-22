class Reward {
  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.costPoints,
    this.iconName,
    this.stock,
    this.active = true,
  });

  final String id;
  final String name;
  final String description;
  final int costPoints;
  final String? iconName;

  /// Null = unlimited. 0 = sold out.
  final int? stock;
  final bool active;

  bool get inStock => stock == null || stock! > 0;
  bool get available => active && inStock;
}
