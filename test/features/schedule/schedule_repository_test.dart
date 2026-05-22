import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/schedule/data/schedule_repository.dart';

Future<FakeFirebaseFirestore> seedSessions(
  List<Map<String, dynamic>> sessions, {
  String clubId = 'club_1',
}) async {
  final firestore = FakeFirebaseFirestore();
  for (final s in sessions) {
    await firestore
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .doc(s['id'] as String)
        .set(s);
  }
  return firestore;
}

void main() {
  group('clubSessionsStream (staff view)', () {
    test('returns sessions within date range', () async {
      final firestore = await seedSessions([
        {
          'id': 'a',
          'name': 'Morning',
          'startTime': Timestamp.fromDate(DateTime(2026, 5, 22, 9)),
          'location': 'Field A',
          'attendees': ['p1'],
        },
        {
          'id': 'b',
          'name': 'Evening',
          'startTime': Timestamp.fromDate(DateTime(2026, 5, 22, 18)),
          'location': 'Field B',
          'attendees': ['p2'],
        },
        {
          'id': 'c',
          'name': 'Next week',
          'startTime': Timestamp.fromDate(DateTime(2026, 5, 30, 9)),
          'location': 'Field A',
          'attendees': ['p1'],
        },
      ]);

      final repo = ScheduleRepository(firestore: firestore);
      final result = await repo.clubSessionsStream(
        clubId: 'club_1',
        from: DateTime(2026, 5, 22),
        to: DateTime(2026, 5, 23),
      ).first;

      expect(result.map((s) => s.id).toList(), ['a', 'b']);
    });

    test('returns empty when no sessions in range', () async {
      final firestore = await seedSessions([]);
      final repo = ScheduleRepository(firestore: firestore);
      final result = await repo.clubSessionsStream(
        clubId: 'club_1',
        from: DateTime(2026, 5, 22),
        to: DateTime(2026, 5, 23),
      ).first;
      expect(result, isEmpty);
    });
  });

  group('playerSessionsStream (player view)', () {
    test('filters by attendee + date range', () async {
      final firestore = await seedSessions([
        {
          'id': 'a',
          'name': 'Mine',
          'startTime': Timestamp.fromDate(DateTime(2026, 5, 22, 9)),
          'location': 'Field A',
          'attendees': ['p1', 'p2'],
        },
        {
          'id': 'b',
          'name': 'Not mine',
          'startTime': Timestamp.fromDate(DateTime(2026, 5, 22, 18)),
          'location': 'Field B',
          'attendees': ['p2'],
        },
      ]);

      final repo = ScheduleRepository(firestore: firestore);
      final result = await repo.playerSessionsStream(
        clubId: 'club_1',
        playerId: 'p1',
        from: DateTime(2026, 5, 22),
        to: DateTime(2026, 5, 23),
      ).first;

      expect(result, hasLength(1));
      expect(result.first.id, 'a');
      expect(result.first.name, 'Mine');
    });
  });

  group('sessionById', () {
    test('returns session when exists', () async {
      final firestore = await seedSessions([
        {
          'id': 'a',
          'name': 'Session A',
          'startTime': Timestamp.fromDate(DateTime(2026, 5, 22, 9)),
          'location': 'Field A',
          'attendees': ['p1'],
        },
      ]);
      final repo = ScheduleRepository(firestore: firestore);
      final session = await repo.sessionById(clubId: 'club_1', sessionId: 'a');
      expect(session, isNotNull);
      expect(session!.name, 'Session A');
      expect(session.attendees, contains('p1'));
    });

    test('returns null when missing', () async {
      final firestore = await seedSessions([]);
      final repo = ScheduleRepository(firestore: firestore);
      final session = await repo.sessionById(clubId: 'club_1', sessionId: 'missing');
      expect(session, isNull);
    });
  });
}
