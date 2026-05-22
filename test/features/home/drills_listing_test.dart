import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/drill_repository.dart';

Future<FakeFirebaseFirestore> seed(List<Map<String, dynamic>> drills) async {
  final fs = FakeFirebaseFirestore();
  for (final d in drills) {
    await fs.collection('drills').doc(d['id'] as String).set(d);
  }
  return fs;
}

void main() {
  group('listDrillsStream', () {
    test('returns drills sorted by difficulty asc', () async {
      final fs = await seed([
        {'id': 'a', 'name': 'Hard', 'category': 'juggle', 'difficulty': 3},
        {'id': 'b', 'name': 'Easy', 'category': 'toe_taps', 'difficulty': 1},
        {'id': 'c', 'name': 'Medium', 'category': 'tic_toc', 'difficulty': 2},
      ]);
      final repo = DrillRepository(firestore: fs);
      final drills = await repo.listDrillsStream().first;
      expect(drills.map((d) => d.id).toList(), ['b', 'c', 'a']);
    });

    test('returns empty when no drills', () async {
      final fs = await seed([]);
      final repo = DrillRepository(firestore: fs);
      final drills = await repo.listDrillsStream().first;
      expect(drills, isEmpty);
    });

    test('defaults missing fields gracefully', () async {
      final fs = await seed([
        {'id': 'a'},
      ]);
      final repo = DrillRepository(firestore: fs);
      final drills = await repo.listDrillsStream().first;
      expect(drills, hasLength(1));
      expect(drills.first.name, 'Untitled drill');
      expect(drills.first.category, '');
      expect(drills.first.difficulty, 1);
      expect(drills.first.targetAttributes, isEmpty);
    });

    test('reads targetAttributes list', () async {
      final fs = await seed([
        {
          'id': 'a',
          'name': 'A',
          'category': 'juggle',
          'difficulty': 1,
          'targetAttributes': ['ball_control', 'first_touch'],
        },
      ]);
      final repo = DrillRepository(firestore: fs);
      final drills = await repo.listDrillsStream().first;
      expect(drills.first.targetAttributes, ['ball_control', 'first_touch']);
    });
  });

  group('drillById', () {
    test('returns drill when exists', () async {
      final fs = await seed([
        {
          'id': 'a',
          'name': 'Juggle',
          'category': 'juggle',
          'difficulty': 2,
          'youtubeUrl': 'https://youtu.be/abc',
          'description': 'Keep the ball up.',
        },
      ]);
      final repo = DrillRepository(firestore: fs);
      final d = await repo.drillById('a');
      expect(d, isNotNull);
      expect(d!.name, 'Juggle');
      expect(d.youtubeUrl, 'https://youtu.be/abc');
      expect(d.description, 'Keep the ball up.');
    });

    test('returns null when missing', () async {
      final fs = await seed([]);
      final repo = DrillRepository(firestore: fs);
      final d = await repo.drillById('nope');
      expect(d, isNull);
    });
  });
}
