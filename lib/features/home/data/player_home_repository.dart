import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/player_streak.dart';

class PlayerHomeRepository {
  PlayerHomeRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<PlayerStreak> streakStream({required String playerId}) {
    // Query by userId field — players use auto-generated Firestore IDs.
    // The allow list rule permits this when resource.data.userId == auth.uid.
    return _db
        .collection('players')
        .where('userId', isEqualTo: playerId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return const PlayerStreak(days: 0, goal: 10);
      final data = snap.docs.first.data();
      final days = data['currentStreak'];
      final goal = data['streakGoal'];
      return PlayerStreak(
        days: (days is num) ? days.toInt() : int.tryParse(days?.toString() ?? '') ?? 0,
        goal: (goal is num) ? goal.toInt() : int.tryParse(goal?.toString() ?? '') ?? 10,
      );
    });
  }
}
