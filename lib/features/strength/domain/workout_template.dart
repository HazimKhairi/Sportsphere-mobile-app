import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateExercise {
  const TemplateExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSeconds = 90,
    this.notes,
  });

  final String exerciseId;
  final int sets;
  final int reps;
  final double? weightKg;
  final int restSeconds;
  final String? notes;

  factory TemplateExercise.fromMap(Map<String, dynamic> d) => TemplateExercise(
        exerciseId: d['exerciseId'] as String,
        sets: (d['sets'] as int?) ?? 3,
        reps: (d['reps'] as int?) ?? 8,
        weightKg: (d['weightKg'] as num?)?.toDouble(),
        restSeconds: (d['restSeconds'] as int?) ?? 90,
        notes: d['notes'] as String?,
      );
}

class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.title,
    required this.estimatedMinutes,
    required this.exercises,
    this.dueDate,
    this.notes,
  });

  final String id;
  final String title;
  final int estimatedMinutes;
  final List<TemplateExercise> exercises;
  final DateTime? dueDate;
  final String? notes;

  factory WorkoutTemplate.fromDoc(String id, Map<String, dynamic> d) {
    final rawExercises = (d['exercises'] as List?) ?? [];
    return WorkoutTemplate(
      id: id,
      title: (d['title'] as String?) ?? 'Workout',
      estimatedMinutes: (d['estimatedMinutes'] as int?) ?? 45,
      exercises: rawExercises
          .cast<Map<String, dynamic>>()
          .map(TemplateExercise.fromMap)
          .toList(),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      notes: d['notes'] as String?,
    );
  }
}
