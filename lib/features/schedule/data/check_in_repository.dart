import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CheckInResult { success, alreadyCheckedIn, notMember, sessionNotFound, failure }

class CheckInRepository {
  CheckInRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<CheckInResult> checkIn({
    required String sessionId,
    required String qrPayload,
  }) async {
    try {
      // QR payload must match the session being checked into
      if (qrPayload.trim() != sessionId.trim()) {
        return CheckInResult.sessionNotFound;
      }

      final uid = _auth.currentUser?.uid;
      if (uid == null) return CheckInResult.failure;

      // Get user's active club
      final userDoc = await _db.collection('users').doc(uid).get();
      final clubId = userDoc.data()?['activeClubId'] as String?;
      if (clubId == null) return CheckInResult.failure;

      // Membership gate — must have club_users doc
      final memberDoc =
          await _db.collection('club_users').doc('${uid}_$clubId').get();
      if (!memberDoc.exists) return CheckInResult.notMember;

      // Check session exists
      final sessionRef = _db
          .collection('clubs')
          .doc(clubId)
          .collection('training_sessions')
          .doc(sessionId);
      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) return CheckInResult.sessionNotFound;

      // Duplicate check
      final attendees =
          List<String>.from(sessionDoc.data()?['attendees'] as List? ?? []);
      if (attendees.contains(uid)) return CheckInResult.alreadyCheckedIn;

      // Mark present
      await sessionRef.update({
        'attendees': FieldValue.arrayUnion([uid]),
      });

      return CheckInResult.success;
    } catch (_) {
      return CheckInResult.failure;
    }
  }
}
