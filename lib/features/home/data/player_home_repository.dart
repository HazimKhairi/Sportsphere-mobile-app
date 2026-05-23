import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/player_streak.dart';

class PlayerHomeRepository {
  PlayerHomeRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<PlayerStreak> streakStream({required String playerId}) {
    return _db
        .collection('players')
        .where('userId', isEqualTo: playerId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return const PlayerStreak(days: 0, goal: 10);
      final data = snap.docs.first.data();
      return PlayerStreak(
        days: (data['currentStreak'] as num?)?.toInt() ?? 0,
        goal: (data['streakGoal'] as num?)?.toInt() ?? 10,
      );
    });
  }
}
