import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/staff_home_repository.dart';

void main() {
  group('pendingApprovalsCountStream', () {
    test('counts stripe_payments where status=PENDING_APPROVAL and clubId matches', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('stripe_payments').add({
        'clubId': 'club_1',
        'status': 'PENDING_APPROVAL',
      });
      await firestore.collection('stripe_payments').add({
        'clubId': 'club_1',
        'status': 'PENDING_APPROVAL',
      });
      await firestore.collection('stripe_payments').add({
        'clubId': 'club_1',
        'status': 'cleared',
      });
      await firestore.collection('stripe_payments').add({
        'clubId': 'club_2',
        'status': 'PENDING_APPROVAL',
      });

      final repo = StaffHomeRepository(firestore: firestore);
      final count = await repo.pendingApprovalsCountStream(clubId: 'club_1').first;

      expect(count, 2);
    });

    test('returns 0 when no payments', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = StaffHomeRepository(firestore: firestore);
      final count = await repo.pendingApprovalsCountStream(clubId: 'club_1').first;
      expect(count, 0);
    });
  });

  group('nextSessionStream', () {
    test('returns the earliest future session', () async {
      final firestore = FakeFirebaseFirestore();
      final now = DateTime(2026, 5, 22, 12, 0);
      await firestore
          .collection('clubs')
          .doc('club_1')
          .collection('training_sessions')
          .doc('past')
          .set({
        'name': 'Yesterday',
        'startTime': Timestamp.fromDate(now.subtract(const Duration(hours: 24))),
        'location': 'Stadium A',
      });
      await firestore
          .collection('clubs')
          .doc('club_1')
          .collection('training_sessions')
          .doc('soon')
          .set({
        'name': 'U13 Training',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 2, minutes: 15))),
        'location': 'Stadium A',
      });
      await firestore
          .collection('clubs')
          .doc('club_1')
          .collection('training_sessions')
          .doc('later')
          .set({
        'name': 'U17 Training',
        'startTime': Timestamp.fromDate(now.add(const Duration(days: 2))),
        'location': 'Field B',
      });

      final repo = StaffHomeRepository(firestore: firestore);
      final session = await repo
          .nextSessionStream(clubId: 'club_1', after: now)
          .first;

      expect(session, isNotNull);
      expect(session!.name, 'U13 Training');
      expect(session.location, 'Stadium A');
    });

    test('returns null when no future sessions', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = StaffHomeRepository(firestore: firestore);
      final session = await repo
          .nextSessionStream(clubId: 'club_1', after: DateTime.now())
          .first;
      expect(session, isNull);
    });
  });

  group('sessionsTodayCountStream', () {
    test('counts sessions whose startTime is within today (local)', () async {
      final firestore = FakeFirebaseFirestore();
      final today = DateTime(2026, 5, 22, 9, 0);
      await firestore
          .collection('clubs')
          .doc('club_1')
          .collection('training_sessions')
          .doc('s1')
          .set({
        'startTime': Timestamp.fromDate(DateTime(2026, 5, 22, 9, 0)),
      });
      await firestore
          .collection('clubs')
          .doc('club_1')
          .collection('training_sessions')
          .doc('s2')
          .set({
        'startTime': Timestamp.fromDate(DateTime(2026, 5, 22, 18, 0)),
      });
      await firestore
          .collection('clubs')
          .doc('club_1')
          .collection('training_sessions')
          .doc('s3')
          .set({
        'startTime': Timestamp.fromDate(DateTime(2026, 5, 23, 9, 0)),
      });

      final repo = StaffHomeRepository(firestore: firestore);
      final count = await repo.sessionsTodayCountStream(
        clubId: 'club_1',
        today: today,
      ).first;

      expect(count, 2);
    });
  });

  group('rosterCountStream', () {
    test('counts players in given club', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('players').add({'clubId': 'club_1', 'name': 'A'});
      await firestore.collection('players').add({'clubId': 'club_1', 'name': 'B'});
      await firestore.collection('players').add({'clubId': 'club_2', 'name': 'C'});

      final repo = StaffHomeRepository(firestore: firestore);
      final count = await repo.rosterCountStream(clubId: 'club_1').first;
      expect(count, 2);
    });
  });
}
