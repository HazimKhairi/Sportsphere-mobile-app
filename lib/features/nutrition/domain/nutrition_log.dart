import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrition_entry.dart';

enum MealType { breakfast, lunch, dinner, snack }

class NutritionLog {
  const NutritionLog({
    required this.id,
    required this.mealType,
    required this.dateStr,
    required this.date,
    required this.foods,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalFatG,
    required this.totalCarbsG,
    required this.totalFibreG,
    this.recommendation,
    this.photoAnalysed = false,
  });

  final String id;
  final MealType mealType;
  final String dateStr;
  final DateTime date;
  final List<NutritionEntry> foods;
  final double totalCalories;
  final double totalProteinG;
  final double totalFatG;
  final double totalCarbsG;
  final double totalFibreG;
  final String? recommendation;
  final bool photoAnalysed;

  factory NutritionLog.fromDoc(String id, Map<String, dynamic> d) {
    final rawMeal = d['mealType'] as String? ?? '';
    final mealType = switch (rawMeal) {
      'breakfast' => MealType.breakfast,
      'lunch' => MealType.lunch,
      'dinner' => MealType.dinner,
      _ => MealType.snack,
    };

    final rawFoods = d['foods'] as List<dynamic>? ?? [];
    final foods = rawFoods
        .map((f) => NutritionEntry.fromJson(f as Map<String, dynamic>))
        .toList();

    final ts = d['date'];
    final date = ts is Timestamp ? ts.toDate() : DateTime.now();

    return NutritionLog(
      id: id,
      mealType: mealType,
      dateStr: d['dateStr'] as String? ?? '',
      date: date,
      foods: foods,
      totalCalories: (d['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProteinG: ((d['totalProteinG'] ?? d['totalProtein_g']) as num?)?.toDouble() ?? 0,
      totalFatG: ((d['totalFatG'] ?? d['totalFat_g']) as num?)?.toDouble() ?? 0,
      totalCarbsG: ((d['totalCarbsG'] ?? d['totalCarbs_g']) as num?)?.toDouble() ?? 0,
      totalFibreG: ((d['totalFibreG'] ?? d['totalFibre_g']) as num?)?.toDouble() ?? 0,
      recommendation: d['recommendation'] as String?,
      photoAnalysed: d['photoAnalysed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'mealType': mealType.name,
    'dateStr': dateStr,
    'date': Timestamp.fromDate(date),
    'foods': foods.map((f) => f.toJson()).toList(),
    'totalCalories': totalCalories,
    'totalProteinG': totalProteinG,
    'totalFatG': totalFatG,
    'totalCarbsG': totalCarbsG,
    'totalFibreG': totalFibreG,
    if (recommendation != null) 'recommendation': recommendation,
    'photoAnalysed': photoAnalysed,
  };
}
