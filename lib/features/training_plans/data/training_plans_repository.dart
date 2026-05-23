import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/training_plan.dart';

class TrainingPlansRepository {
  TrainingPlansRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<TrainingPlan>> assignedPlansStream({
    required String clubId,
    required String playerId,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .where('assignedPlayerIds', arrayContains: playerId)
        .where('status', isEqualTo: 'active')
        .limit(10)
        .snapshots()
        .map((s) => s.docs
            .map((d) => TrainingPlan.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<List<PlanWeek>> weeksForPlan({
    required String clubId,
    required String planId,
  }) async {
    final snap = await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc(planId)
        .collection('weeks')
        .orderBy('weekNumber')
        .get();

    final weeks = <PlanWeek>[];
    for (final weekDoc in snap.docs) {
      final sessionsSnap = await weekDoc.reference
          .collection('sessions')
          .orderBy('dayOfWeek')
          .get();
      final sessions = sessionsSnap.docs
          .map((d) => PlanSession.fromDoc(d.id, d.data()))
          .toList();
      final data = weekDoc.data();
      weeks.add(PlanWeek(
        id: weekDoc.id,
        weekNumber: (data['weekNumber'] as int?) ?? 1,
        title: (data['title'] as String?) ?? '',
        theme: (data['theme'] as String?) ?? '',
        sessions: sessions,
      ));
    }
    return weeks;
  }

  Future<void> markSessionComplete({
    required String clubId,
    required String planId,
    required String weekId,
    required String sessionId,
    required String playerId,
    int selfRating = 3,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc(planId)
        .collection('weeks')
        .doc(weekId)
        .collection('sessions')
        .doc(sessionId)
        .collection('completions')
        .doc(playerId)
        .set({
      'completedAt': FieldValue.serverTimestamp(),
      'selfRating': selfRating,
    });
  }
}
