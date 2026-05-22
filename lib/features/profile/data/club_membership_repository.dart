import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../domain/club_membership.dart';

class ClubMembershipRepository {
  ClubMembershipRepository({
    FirebaseFirestore? firestore,
    required Dio dio,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _dio = dio;

  final FirebaseFirestore _db;
  final Dio _dio;

  Future<List<ClubMembership>> listMemberships({required String userId}) async {
    final snap = await _db
        .collection('club_users')
        .where('userId', isEqualTo: userId)
        .get();
    if (snap.docs.isEmpty) return const [];

    final clubIds = snap.docs
        .map((d) => (d.data()['clubId'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final clubDocs = <String, String>{};
    for (final id in clubIds) {
      final doc = await _db.collection('clubs').doc(id).get();
      final name = doc.data()?['name'] as String?;
      clubDocs[id] = (name != null && name.isNotEmpty) ? name : id;
    }

    return snap.docs.map((d) {
      final data = d.data();
      final clubId = (data['clubId'] as String?) ?? '';
      return ClubMembership(
        clubId: clubId,
        clubName: clubDocs[clubId] ?? clubId,
        role: (data['role'] as String?) ?? 'MEMBER',
      );
    }).toList();
  }

  Future<void> setActiveClub({required String clubId}) async {
    await _dio.patch<Map<String, dynamic>>(
      '/api/users/me/active-club',
      data: {'clubId': clubId},
    );
  }
}
