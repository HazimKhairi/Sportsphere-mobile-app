import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/staff_next_session.dart';

class StaffHomeRepository {
  StaffHomeRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<int> pendingApprovalsCountStream({required String clubId}) {
    return _db
        .collection('stripe_payments')
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: 'PENDING_APPROVAL')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<StaffNextSession?> nextSessionStream({
    required String clubId,
    required DateTime after,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .where('startTime', isGreaterThan: Timestamp.fromDate(after))
        .orderBy('startTime')
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      final data = doc.data();
      final ts = data['startTime'];
      return StaffNextSession(
        id: doc.id,
        name: (data['name'] as String?) ?? 'Training',
        startTime: ts is Timestamp ? ts.toDate() : DateTime.now(),
        location: (data['location'] as String?) ?? '',
      );
    });
  }

  Stream<int> sessionsTodayCountStream({
    required String clubId,
    required DateTime today,
  }) {
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<int> rosterCountStream({required String clubId}) {
    return _db
        .collection('players')
        .where('clubId', isEqualTo: clubId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
