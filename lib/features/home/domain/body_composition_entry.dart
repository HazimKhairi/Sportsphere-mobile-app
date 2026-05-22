class BodyCompositionEntry {
  const BodyCompositionEntry({
    required this.id,
    required this.recordedAt,
    this.weightKg,
    this.heightCm,
    this.bodyFatPct,
    this.muscleMassKg,
  });

  final String id;
  final DateTime recordedAt;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPct;
  final double? muscleMassKg;

  /// BMI from weight + height when both present, otherwise null.
  double? get bmi {
    final w = weightKg;
    final h = heightCm;
    if (w == null || h == null || h <= 0) return null;
    final meters = h / 100;
    return w / (meters * meters);
  }
}
