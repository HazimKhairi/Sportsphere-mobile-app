import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/achievement.dart';

class AchievementsRepository {
  AchievementsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  /// Streams the catalog merged with the player's unlocked status.
  /// Sorted: unlocked first, then by tier descending.
  Stream<List<Achievement>> streamForPlayer({required String playerId}) {
    return _db.collection('achievements').snapshots().asyncMap((catalogSnap) async {
      final unlockedSnap = await _db
          .collection('players')
          .doc(playerId)
          .collection('unlocked_achievements')
          .get();
      final unlocked = <String, DateTime>{};
      for (final doc in unlockedSnap.docs) {
        final ts = doc.data()['unlockedAt'];
        unlocked[doc.id] = ts is Timestamp ? ts.toDate() : DateTime.now();
      }
      final list = catalogSnap.docs.map((doc) {
        final data = doc.data();
        return Achievement(
          id: doc.id,
          name: (data['name'] as String?)?.isNotEmpty == true
              ? data['name'] as String
              : 'Untitled',
          description: (data['description'] as String?) ?? '',
          tier: tierFromString(data['tier'] as String?),
          points: (data['points'] as int?) ?? 0,
          iconName: data['iconName'] as String?,
          category: (data['category'] as String?) ?? '',
          requirement: (data['requirement'] as String?) ?? '',
          unlocked: unlocked.containsKey(doc.id),
          unlockedAt: unlocked[doc.id],
        );
      }).toList();
      list.sort((a, b) {
        if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
        return _tierRank(b.tier).compareTo(_tierRank(a.tier));
      });
      return list;
    });
  }

  Future<int> totalUnlockedCount({required String playerId}) async {
    final snap = await _db
        .collection('players')
        .doc(playerId)
        .collection('unlocked_achievements')
        .get();
    return snap.docs.length;
  }

  int _tierRank(AchievementTier t) {
    switch (t) {
      case AchievementTier.platinum:
        return 4;
      case AchievementTier.gold:
        return 3;
      case AchievementTier.silver:
        return 2;
      case AchievementTier.bronze:
        return 1;
      case AchievementTier.unknown:
        return 0;
    }
  }
}
