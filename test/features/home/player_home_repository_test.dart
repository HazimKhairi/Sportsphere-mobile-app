import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/player_home_repository.dart';

void main() {
  test('streakStream emits current streak from players/{uid}.currentStreak', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('players').doc('uid_1').set({
      'currentStreak': 7,
      'streakGoal': 10,
    });

    final repo = PlayerHomeRepository(firestore: firestore);
    final streak = await repo.streakStream(playerId: 'uid_1').first;

    expect(streak.days, 7);
    expect(streak.goal, 10);
  });

  test('streakStream emits 0/10 default when document missing', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = PlayerHomeRepository(firestore: firestore);
    final streak = await repo.streakStream(playerId: 'missing').first;
    expect(streak.days, 0);
    expect(streak.goal, 10);
  });

  test('streakStream emits 0/10 when fields missing (only doc exists)', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('players').doc('uid_2').set({
      'name': 'Danial',
    });
    final repo = PlayerHomeRepository(firestore: firestore);
    final streak = await repo.streakStream(playerId: 'uid_2').first;
    expect(streak.days, 0);
    expect(streak.goal, 10);
  });
}
