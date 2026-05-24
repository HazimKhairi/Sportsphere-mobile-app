import 'nutrition_log.dart';

class DailySummary {
  const DailySummary({
    required this.dateStr,
    required this.logs,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalFatG,
    required this.totalCarbsG,
    required this.totalFibreG,
    this.calorieTarget = 2500,
  });

  final String dateStr;
  final List<NutritionLog> logs;
  final double totalCalories;
  final double totalProteinG;
  final double totalFatG;
  final double totalCarbsG;
  final double totalFibreG;
  final double calorieTarget;

  double get calorieProgress => (totalCalories / calorieTarget).clamp(0.0, 1.0);

  factory DailySummary.fromLogs(String dateStr, List<NutritionLog> logs) {
    double cal = 0, pro = 0, fat = 0, carbs = 0, fibre = 0;
    for (final log in logs) {
      cal += log.totalCalories;
      pro += log.totalProteinG;
      fat += log.totalFatG;
      carbs += log.totalCarbsG;
      fibre += log.totalFibreG;
    }
    return DailySummary(
      dateStr: dateStr,
      logs: logs,
      totalCalories: cal,
      totalProteinG: pro,
      totalFatG: fat,
      totalCarbsG: carbs,
      totalFibreG: fibre,
    );
  }

  static DailySummary empty(String dateStr) => DailySummary(
    dateStr: dateStr,
    logs: const [],
    totalCalories: 0,
    totalProteinG: 0,
    totalFatG: 0,
    totalCarbsG: 0,
    totalFibreG: 0,
  );
}
