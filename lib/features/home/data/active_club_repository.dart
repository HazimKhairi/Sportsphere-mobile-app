import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveClubRepository {
  ActiveClubRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<String?> activeClubIdStream({required String userId}) {
    return _db.collection('users').doc(userId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return data['activeClubId'] as String?;
    });
  }
}
