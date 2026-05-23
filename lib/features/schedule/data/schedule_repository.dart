import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/training_session.dart';

class ScheduleRepository {
  ScheduleRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<TrainingSession>> clubSessionsStream({
    required String clubId,
    required DateTime from,
    required DateTime to,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('startTime', isLessThan: Timestamp.fromDate(to))
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Stream<List<TrainingSession>> playerSessionsStream({
    required String clubId,
    required String playerId,
    required DateTime from,
    required DateTime to,
  }) {
    // arrayContains + range filter needs a composite index — filter attendees
    // client-side instead to reuse the existing startTime single-field index.
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('startTime', isLessThan: Timestamp.fromDate(to))
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs
            .map(_fromDoc)
            .where((s) => s.attendees.contains(playerId))
            .toList());
  }

  Future<TrainingSession?> sessionById({
    required String clubId,
    required String sessionId,
  }) async {
    final snap = await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .doc(sessionId)
        .get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return _fromMap(snap.id, data);
  }

  TrainingSession _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _fromMap(doc.id, doc.data());
  }

  TrainingSession _fromMap(String id, Map<String, dynamic> data) {
    final ts = data['startTime'];
    final attendeesRaw = (data['attendees'] as List?) ?? const [];
    return TrainingSession(
      id: id,
      name: (data['name'] as String?) ?? 'Training',
      startTime: ts is Timestamp ? ts.toDate() : DateTime.now(),
      location: (data['location'] as String?) ?? '',
      attendees: attendeesRaw.cast<String>().toList(),
    );
  }
}
