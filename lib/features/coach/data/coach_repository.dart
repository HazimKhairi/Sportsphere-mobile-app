import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/coach_profile.dart';

part 'coach_repository.g.dart';

class CoachRepository {
  CoachRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static const _staffRoles = ['OWNER', 'ADMIN', 'COACH', 'STAFF'];

  Future<List<CoachProfile>> fetchMyCoaches() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final userDoc = await _db.collection('users').doc(uid).get();
    final clubId = userDoc.data()?['activeClubId'] as String?;
    if (clubId == null || clubId.isEmpty) return [];

    final snap = await _db
        .collection('club_users')
        .where('clubId', isEqualTo: clubId)
        .where('role', whereIn: _staffRoles)
        .limit(20)
        .get();

    if (snap.docs.isEmpty) return [];

    final coaches = await Future.wait(
      snap.docs.map((doc) async {
        final data = doc.data();
        final coachUid = data['userId'] as String? ?? '';
        if (coachUid.isEmpty) return null;

        final role = data['role'] as String? ?? 'STAFF';

        final profileDoc = await _db.collection('users').doc(coachUid).get();
        final profile = profileDoc.data() ?? {};

        return CoachProfile(
          id: coachUid,
          name: profile['displayName'] as String? ?? 'Coach',
          role: role,
          email: profile['email'] as String?,
          photoUrl: profile['photoURL'] as String?,
          bio: profile['bio'] as String?,
          yearsExperience: (profile['yearsExperience'] as num?)?.toInt(),
          specialties:
              _strings(profile['specialties']),
          ageGroups: _strings(profile['ageGroups']),
          languages: _strings(profile['languages']),
          previousClubs: _strings(profile['previousClubs']),
          philosophy: profile['philosophy'] as String?,
          achievements: _strings(profile['achievements']),
          certificationsCount:
              (profile['certificationsCount'] as num?)?.toInt() ?? 0,
          teamIds: _strings(profile['teamIds']),
        );
      }),
    );

    return coaches.whereType<CoachProfile>().toList();
  }

  static List<String> _strings(dynamic raw) {
    if (raw is List) return raw.whereType<String>().toList();
    return const [];
  }
}

@Riverpod(keepAlive: true)
CoachRepository coachRepository(Ref ref) => CoachRepository();
