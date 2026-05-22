import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/player_streak.dart';

class PlayerHomeRepository {
  PlayerHomeRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<PlayerStreak> streakStream({required String playerId}) {
    return _db.collection('players').doc(playerId).snapshots().map((snap) {
      final data = snap.data() ?? <String, dynamic>{};
      return PlayerStreak(
        days: (data['currentStreak'] as int?) ?? 0,
        goal: (data['streakGoal'] as int?) ?? 10,
      );
    });
  }
}
