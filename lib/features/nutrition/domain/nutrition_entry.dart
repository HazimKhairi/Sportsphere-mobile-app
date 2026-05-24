class NutritionEntry {
  const NutritionEntry({
    required this.name,
    required this.estimatedGrams,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.fibreG,
  });

  final String name;
  final double estimatedGrams;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double fibreG;

  factory NutritionEntry.fromJson(Map<String, dynamic> j) => NutritionEntry(
    name: j['name'] as String? ?? '',
    estimatedGrams: (j['estimatedGrams'] as num?)?.toDouble() ?? 0,
    calories: (j['calories'] as num?)?.toDouble() ?? 0,
    proteinG: (j['protein_g'] as num?)?.toDouble() ?? 0,
    fatG: (j['fat_g'] as num?)?.toDouble() ?? 0,
    carbsG: (j['carbs_g'] as num?)?.toDouble() ?? 0,
    fibreG: (j['fibre_g'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'estimatedGrams': estimatedGrams,
    'calories': calories,
    'protein_g': proteinG,
    'fat_g': fatG,
    'carbs_g': carbsG,
    'fibre_g': fibreG,
  };
}
