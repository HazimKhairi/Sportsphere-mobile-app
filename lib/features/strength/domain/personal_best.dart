import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalBest {
  const PersonalBest({
    required this.exerciseId,
    required this.bestWeightKg,
    required this.bestReps,
    required this.bestVolumeKg,
    required this.achievedAt,
  });

  final String exerciseId;
  final double bestWeightKg;
  final int bestReps;
  final double bestVolumeKg;
  final DateTime achievedAt;

  factory PersonalBest.fromDoc(String id, Map<String, dynamic> d) => PersonalBest(
        exerciseId: id,
        bestWeightKg: (d['bestWeightKg'] as num?)?.toDouble() ?? 0,
        bestReps: (d['bestReps'] as int?) ?? 0,
        bestVolumeKg: (d['bestVolumeKg'] as num?)?.toDouble() ?? 0,
        achievedAt: (d['achievedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
