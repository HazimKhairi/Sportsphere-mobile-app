import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerAttendanceRecord {
  const PlayerAttendanceRecord({
    required this.playerId,
    required this.displayName,
    required this.isPresent,
    required this.isMember,
  });

  final String playerId;
  final String displayName;
  final bool isPresent;
  final bool isMember;

  PlayerAttendanceRecord copyWith({bool? isPresent}) {
    return PlayerAttendanceRecord(
      playerId: playerId,
      displayName: displayName,
      isPresent: isPresent ?? this.isPresent,
      isMember: isMember,
    );
  }
}

class AttendanceRepository {
  AttendanceRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<List<PlayerAttendanceRecord>> getRoster({
    required String clubId,
    required String sessionId,
  }) async {
    final playersSnap = await _db
        .collection('players')
        .where('clubId', isEqualTo: clubId)
        .limit(100)
        .get();

    final sessionDoc = await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .doc(sessionId)
        .get();

    final attendees = List<String>.from(
        (sessionDoc.data()?['attendees'] as List<dynamic>?) ?? []);

    final records = await Future.wait(
      playersSnap.docs.map((doc) async {
        final data = doc.data();
        final userId = (data['userId'] as String?) ?? doc.id;
        final displayName = (data['displayName'] as String?) ?? '';
        final isPresent = attendees.contains(userId);

        final memberDoc = await _db
            .collection('club_users')
            .doc('${userId}_$clubId')
            .get()
            .then((d) => d.exists);

        return PlayerAttendanceRecord(
          playerId: userId,
          displayName: displayName,
          isPresent: isPresent,
          isMember: memberDoc,
        );
      }),
    );

    records.sort((a, b) {
      if (a.isPresent && !b.isPresent) return -1;
      if (!a.isPresent && b.isPresent) return 1;
      return a.displayName.compareTo(b.displayName);
    });

    return records;
  }

  Stream<Set<String>> attendeesStream({
    required String clubId,
    required String sessionId,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .doc(sessionId)
        .snapshots()
        .map((doc) {
      final raw = (doc.data()?['attendees'] as List<dynamic>?) ?? [];
      return raw.map((e) => e.toString()).toSet();
    });
  }

  Future<void> toggleAttendance({
    required String clubId,
    required String sessionId,
    required String playerId,
    required bool markPresent,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_sessions')
        .doc(sessionId)
        .update({
      'attendees': markPresent
          ? FieldValue.arrayUnion([playerId])
          : FieldValue.arrayRemove([playerId]),
    });
  }
}
