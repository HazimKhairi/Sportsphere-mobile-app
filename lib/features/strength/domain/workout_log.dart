import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedSet {
  const LoggedSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.rpe,
  });

  final int setNumber;
  final int reps;
  final double weightKg;
  final int? rpe;

  Map<String, dynamic> toMap() => {
        'setNumber': setNumber,
        'reps': reps,
        'weightKg': weightKg,
        if (rpe != null) 'rpe': rpe,
        'completedAt': FieldValue.serverTimestamp(),
      };
}

class LoggedExercise {
  const LoggedExercise({required this.exerciseId, required this.sets});
  final String exerciseId;
  final List<LoggedSet> sets;

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'sets': sets.map((s) => s.toMap()).toList(),
      };
}

class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.templateId,
    required this.startedAt,
    required this.completedAt,
    required this.exercises,
    required this.totalVolumeKg,
  });

  final String id;
  final String? templateId;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<LoggedExercise> exercises;
  final double totalVolumeKg;
}
