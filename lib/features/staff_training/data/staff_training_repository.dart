import 'package:cloud_firestore/cloud_firestore.dart';

import '../../strength/domain/workout_template.dart';
import '../../training_plans/domain/training_plan.dart';

class StaffTrainingRepository {
  StaffTrainingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  // ── Workout Templates ─────────────────────────────────────────────────────

  Stream<List<WorkoutTemplate>> workoutTemplatesStream(String clubId) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('workoutTemplates')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => WorkoutTemplate.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<String> createWorkoutTemplate({
    required String clubId,
    required String title,
    required int estimatedMinutes,
    required List<TemplateExercise> exercises,
  }) async {
    final ref = _db
        .collection('clubs')
        .doc(clubId)
        .collection('workoutTemplates')
        .doc();
    await ref.set({
      'title': title,
      'estimatedMinutes': estimatedMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'assignedPlayerIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> assignWorkoutTemplate({
    required String clubId,
    required String templateId,
    required List<String> playerIds,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('workoutTemplates')
        .doc(templateId)
        .update({'assignedPlayerIds': FieldValue.arrayUnion(playerIds)});
  }

  Future<void> unassignWorkoutTemplate({
    required String clubId,
    required String templateId,
    required List<String> playerIds,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('workoutTemplates')
        .doc(templateId)
        .update({'assignedPlayerIds': FieldValue.arrayRemove(playerIds)});
  }

  Future<void> deleteWorkoutTemplate({
    required String clubId,
    required String templateId,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('workoutTemplates')
        .doc(templateId)
        .delete();
  }

  // ── Training Plans ────────────────────────────────────────────────────────

  Stream<List<TrainingPlan>> trainingPlansStream(String clubId) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => TrainingPlan.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<String> createTrainingPlan({
    required String clubId,
    required String title,
    required String phase,
    required int totalWeeks,
  }) async {
    final ref = _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc();
    await ref.set({
      'title': title,
      'phase': phase,
      'totalWeeks': totalWeeks,
      'currentWeek': 1,
      'status': 'active',
      'assignedPlayerIds': <String>[],
      'description': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> assignTrainingPlan({
    required String clubId,
    required String planId,
    required List<String> playerIds,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc(planId)
        .update({'assignedPlayerIds': FieldValue.arrayUnion(playerIds)});
  }

  Future<void> unassignTrainingPlan({
    required String clubId,
    required String planId,
    required List<String> playerIds,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc(planId)
        .update({'assignedPlayerIds': FieldValue.arrayRemove(playerIds)});
  }

  Future<void> deleteTrainingPlan({
    required String clubId,
    required String planId,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc(planId)
        .delete();
  }

  // ── Assigned players helper ───────────────────────────────────────────────

  Stream<List<String>> assignedPlayerIdsStream({
    required String clubId,
    required String collection,
    required String docId,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection(collection)
        .doc(docId)
        .snapshots()
        .map((d) {
      if (!d.exists) return [];
      return ((d.data()?['assignedPlayerIds'] as List?)?.cast<String>()) ?? [];
    });
  }
}
