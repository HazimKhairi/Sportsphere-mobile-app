import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/achievements_repository.dart';
import 'package:sportsphere_mobile/features/home/domain/achievement.dart';

Future<FakeFirebaseFirestore> seedCatalog(
  List<Map<String, dynamic>> catalog,
) async {
  final fs = FakeFirebaseFirestore();
  for (final a in catalog) {
    await fs.collection('achievements').doc(a['id'] as String).set(a);
  }
  return fs;
}

Future<void> seedUnlocked(
  FakeFirebaseFirestore fs, {
  required String playerId,
  required Map<String, DateTime> unlocked,
}) async {
  for (final entry in unlocked.entries) {
    await fs
        .collection('players')
        .doc(playerId)
        .collection('unlocked_achievements')
        .doc(entry.key)
        .set({'unlockedAt': Timestamp.fromDate(entry.value)});
  }
}

void main() {
  group('streamForPlayer', () {
    test('returns catalog merged with unlocked status', () async {
      final fs = await seedCatalog([
        {
          'id': 'first_drill',
          'name': 'First Drill',
          'description': 'Complete your first drill.',
          'tier': 'bronze',
          'points': 10,
        },
        {
          'id': 'streak_10',
          'name': '10-day Streak',
          'description': 'Train 10 days in a row.',
          'tier': 'gold',
          'points': 100,
        },
      ]);
      await seedUnlocked(
        fs,
        playerId: 'p1',
        unlocked: {'first_drill': DateTime(2026, 5, 20)},
      );

      final repo = AchievementsRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list, hasLength(2));
      final byId = {for (final a in list) a.id: a};
      expect(byId['first_drill']!.unlocked, true);
      expect(byId['first_drill']!.unlockedAt, DateTime(2026, 5, 20));
      expect(byId['streak_10']!.unlocked, false);
      expect(byId['streak_10']!.unlockedAt, isNull);
    });

    test('returns empty when no catalog entries', () async {
      final fs = FakeFirebaseFirestore();
      final repo = AchievementsRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list, isEmpty);
    });

    test('handles missing fields with safe defaults', () async {
      final fs = await seedCatalog([
        {'id': 'minimal'},
      ]);
      final repo = AchievementsRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list.first.name, 'Untitled');
      expect(list.first.description, '');
      expect(list.first.tier, AchievementTier.unknown);
      expect(list.first.points, 0);
      expect(list.first.unlocked, false);
    });

    test('sorts unlocked first, then by tier descending (gold > bronze)', () async {
      final fs = await seedCatalog([
        {'id': 'a', 'name': 'A', 'tier': 'bronze', 'points': 10},
        {'id': 'b', 'name': 'B', 'tier': 'gold', 'points': 50},
        {'id': 'c', 'name': 'C', 'tier': 'silver', 'points': 20},
        {'id': 'd', 'name': 'D', 'tier': 'gold', 'points': 50},
      ]);
      await seedUnlocked(
        fs,
        playerId: 'p1',
        unlocked: {'a': DateTime.now()},
      );
      final repo = AchievementsRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list.first.id, 'a'); // unlocked first (bronze)
      expect(list[1].id, anyOf('b', 'd')); // gold tier next
      expect(list[2].id, anyOf('b', 'd')); // other gold tier
      expect(list.last.id, 'c'); // silver locked falls through last
    });
  });

  group('totalUnlockedCount', () {
    test('counts unlocked from the snapshot', () async {
      final fs = await seedCatalog([
        {'id': 'a'},
        {'id': 'b'},
        {'id': 'c'},
      ]);
      await seedUnlocked(
        fs,
        playerId: 'p1',
        unlocked: {
          'a': DateTime.now(),
          'b': DateTime.now(),
        },
      );
      final repo = AchievementsRepository(firestore: fs);
      final count = await repo.totalUnlockedCount(playerId: 'p1');
      expect(count, 2);
    });
  });
}
