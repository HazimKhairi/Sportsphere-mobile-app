import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/exercise.dart';
import '../domain/personal_best.dart';
import '../domain/workout_log.dart';
import '../domain/workout_template.dart';

class StrengthRepository {
  StrengthRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<WorkoutTemplate>> assignedTemplatesStream({
    required String clubId,
    required String playerId,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('workoutTemplates')
        .where('assignedPlayerIds', arrayContains: playerId)
        .limit(20)
        .snapshots()
        .map((s) => s.docs
            .map((d) => WorkoutTemplate.fromDoc(d.id, d.data()))
            .toList());
  }

  Stream<List<Exercise>> exercisesStream() {
    return _db
        .collection('exercises')
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => Exercise.fromMap(d.id, d.data())).toList());
  }

  Future<Exercise?> exerciseById(String id) async {
    final doc = await _db.collection('exercises').doc(id).get();
    if (!doc.exists) return null;
    return Exercise.fromMap(doc.id, doc.data()!);
  }

  Future<String> saveWorkoutLog({
    required String userId,
    required String? templateId,
    required String clubId,
    required DateTime startedAt,
    required DateTime completedAt,
    required List<LoggedExercise> exercises,
  }) async {
    double totalVolume = 0;
    for (final ex in exercises) {
      for (final s in ex.sets) {
        totalVolume += s.reps * s.weightKg;
      }
    }

    final ref = _db.collection('users').doc(userId).collection('workoutLogs').doc();
    await ref.set({
      'templateId': templateId,
      'clubId': clubId,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'totalVolumeKg': totalVolume,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    });
    return ref.id;
  }

  Stream<PersonalBest?> personalBestStream({
    required String userId,
    required String exerciseId,
  }) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('personalBests')
        .doc(exerciseId)
        .snapshots()
        .map((d) => d.exists ? PersonalBest.fromDoc(d.id, d.data()!) : null);
  }
}
