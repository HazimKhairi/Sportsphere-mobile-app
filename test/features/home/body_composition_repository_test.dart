import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/body_composition_repository.dart';

Future<FakeFirebaseFirestore> seed(
  String playerId,
  List<Map<String, dynamic>> entries,
) async {
  final fs = FakeFirebaseFirestore();
  for (final e in entries) {
    await fs
        .collection('players')
        .doc(playerId)
        .collection('body_composition')
        .doc(e['id'] as String)
        .set(e);
  }
  return fs;
}

void main() {
  group('streamForPlayer', () {
    test('returns entries sorted by recordedAt desc', () async {
      final fs = await seed('p1', [
        {
          'id': 'a',
          'weightKg': 70.0,
          'heightCm': 175.0,
          'recordedAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        },
        {
          'id': 'b',
          'weightKg': 71.5,
          'recordedAt': Timestamp.fromDate(DateTime(2026, 5, 15)),
        },
      ]);
      final repo = BodyCompositionRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list.map((e) => e.id).toList(), ['b', 'a']);
      expect(list.first.weightKg, 71.5);
    });

    test('returns empty when no entries', () async {
      final fs = await seed('p1', const []);
      final repo = BodyCompositionRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list, isEmpty);
    });

    test('handles missing recordedAt with epoch fallback', () async {
      final fs = await seed('p1', [
        {'id': 'a', 'weightKg': 70.0},
      ]);
      final repo = BodyCompositionRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list, hasLength(1));
      expect(list.first.recordedAt.millisecondsSinceEpoch, 0);
    });

    test('parses int and double weight values', () async {
      final fs = await seed('p1', [
        {
          'id': 'a',
          'weightKg': 70, // int
          'heightCm': 175.5, // double
          'recordedAt': Timestamp.fromDate(DateTime.now()),
        },
      ]);
      final repo = BodyCompositionRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list.first.weightKg, 70.0);
      expect(list.first.heightCm, 175.5);
    });
  });

  group('addEntry', () {
    test('writes a new doc with the supplied fields', () async {
      final fs = FakeFirebaseFirestore();
      final repo = BodyCompositionRepository(firestore: fs);
      await repo.addEntry(
        playerId: 'p1',
        weightKg: 72.5,
        heightCm: 178.0,
        bodyFatPct: 14.5,
        muscleMassKg: 58.0,
      );
      final snap = await fs
          .collection('players')
          .doc('p1')
          .collection('body_composition')
          .get();
      expect(snap.docs, hasLength(1));
      final data = snap.docs.first.data();
      expect(data['weightKg'], 72.5);
      expect(data['heightCm'], 178.0);
      expect(data['bodyFatPct'], 14.5);
      expect(data['muscleMassKg'], 58.0);
      expect(data.containsKey('recordedAt'), true);
    });

    test('skips null fields', () async {
      final fs = FakeFirebaseFirestore();
      final repo = BodyCompositionRepository(firestore: fs);
      await repo.addEntry(playerId: 'p1', weightKg: 70.0);
      final snap = await fs
          .collection('players')
          .doc('p1')
          .collection('body_composition')
          .get();
      final data = snap.docs.first.data();
      expect(data.containsKey('weightKg'), true);
      expect(data.containsKey('heightCm'), false);
      expect(data.containsKey('bodyFatPct'), false);
      expect(data.containsKey('muscleMassKg'), false);
    });
  });
}
