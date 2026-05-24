import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/registration_status.dart';

class RegistrationRepository {
  RegistrationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<bool> isRegistered({
    required String clubId,
    required String programId,
    required String playerId,
  }) async {
    final doc = await _db
        .collection('clubs')
        .doc(clubId)
        .collection('programs')
        .doc(programId)
        .collection('registrants')
        .doc(playerId)
        .get();
    if (!doc.exists) return false;
    final status = doc.data()?['status'] as String?;
    final kind = RegistrationStatusKind.fromString(status);
    return kind == RegistrationStatusKind.active ||
        kind == RegistrationStatusKind.pending;
  }

  Future<RegistrationResult> confirmRegistration({
    required String programId,
    required String paymentIntentId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw RegistrationException('Not signed in');

    // Resolve club from user doc
    final userDoc = await _db.collection('users').doc(uid).get();
    final clubId = userDoc.data()?['activeClubId'] as String?;
    if (clubId == null || clubId.isEmpty) {
      throw RegistrationException('No active club found');
    }

    // Write registrant doc with uid as key — Firestore rule allows
    // create when doc ID == request.auth.uid (isOwner check).
    final registrantRef = _db
        .collection('clubs')
        .doc(clubId)
        .collection('programs')
        .doc(programId)
        .collection('registrants')
        .doc(uid);

    await registrantRef.set({
      'playerId': uid,
      'registeredBy': uid,
      'paymentIntentId': paymentIntentId,
      'status': 'pending',
      'paymentStatus': 'Pending',
      'registrationDate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return RegistrationResult(
      registrationId: uid,
      status: RegistrationStatusKind.pending,
    );
  }
}
