import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/drill_repository.dart';

void main() {
  Future<FakeFirebaseFirestore> seedDrills(List<Map<String, dynamic>> drills) async {
    final firestore = FakeFirebaseFirestore();
    for (final d in drills) {
      await firestore.collection('drills').doc(d['id'] as String).set(d);
    }
    return firestore;
  }

  test('returns null when drill collection empty', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = DrillRepository(firestore: firestore);
    final drill = await repo.todayDrillFor(
      playerId: 'uid_1',
      date: DateTime(2026, 5, 22),
    );
    expect(drill, isNull);
  });

  test('same player + same day = same drill (idempotent)', () async {
    final firestore = await seedDrills([
      {'id': 'd1', 'name': 'Juggle', 'difficulty': 1},
      {'id': 'd2', 'name': 'Toe Taps', 'difficulty': 2},
      {'id': 'd3', 'name': 'Tic Toc', 'difficulty': 2},
    ]);
    final repo = DrillRepository(firestore: firestore);
    final a = await repo.todayDrillFor(
      playerId: 'uid_1',
      date: DateTime(2026, 5, 22),
    );
    final b = await repo.todayDrillFor(
      playerId: 'uid_1',
      date: DateTime(2026, 5, 22),
    );
    expect(a, isNotNull);
    expect(b, isNotNull);
    expect(a!.id, equals(b!.id));
    expect(a.name, equals(b.name));
  });

  test('drill name comes from Firestore document', () async {
    final firestore = await seedDrills([
      {'id': 'd1', 'name': 'Juggle', 'difficulty': 1},
    ]);
    final repo = DrillRepository(firestore: firestore);
    final drill = await repo.todayDrillFor(
      playerId: 'uid_1',
      date: DateTime(2026, 5, 22),
    );
    expect(drill!.name, 'Juggle');
    expect(drill.id, 'd1');
  });
}
