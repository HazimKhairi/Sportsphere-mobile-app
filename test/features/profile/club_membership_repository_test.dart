import 'package:dio/dio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/profile/data/club_membership_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('listMemberships', () {
    test('returns memberships joined with club names', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('club_users').doc('uid_1_club_a').set({
        'userId': 'uid_1',
        'clubId': 'club_a',
        'role': 'COACH',
      });
      await firestore.collection('club_users').doc('uid_1_club_b').set({
        'userId': 'uid_1',
        'clubId': 'club_b',
        'role': 'MEMBER',
      });
      await firestore.collection('club_users').doc('uid_2_club_a').set({
        'userId': 'uid_2',
        'clubId': 'club_a',
        'role': 'COACH',
      });
      await firestore.collection('clubs').doc('club_a').set({'name': 'Black Viper FC'});
      await firestore.collection('clubs').doc('club_b').set({'name': 'SK USK2'});

      final repo = ClubMembershipRepository(
        firestore: firestore,
        dio: _MockDio(),
      );
      final memberships = await repo.listMemberships(userId: 'uid_1');

      expect(memberships, hasLength(2));
      final map = {for (final m in memberships) m.clubId: m};
      expect(map['club_a']?.clubName, 'Black Viper FC');
      expect(map['club_a']?.role, 'COACH');
      expect(map['club_b']?.clubName, 'SK USK2');
      expect(map['club_b']?.role, 'MEMBER');
    });

    test('uses clubId as fallback name when club doc missing', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('club_users').doc('uid_1_club_x').set({
        'userId': 'uid_1',
        'clubId': 'club_x',
        'role': 'MEMBER',
      });

      final repo = ClubMembershipRepository(
        firestore: firestore,
        dio: _MockDio(),
      );
      final memberships = await repo.listMemberships(userId: 'uid_1');

      expect(memberships, hasLength(1));
      expect(memberships.first.clubName, 'club_x');
    });

    test('returns empty when no memberships', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = ClubMembershipRepository(
        firestore: firestore,
        dio: _MockDio(),
      );
      final memberships = await repo.listMemberships(userId: 'uid_none');
      expect(memberships, isEmpty);
    });
  });

  group('setActiveClub', () {
    test('PATCHes /api/users/me/active-club with clubId', () async {
      final dio = _MockDio();
      registerFallbackValue(Options());
      when(() => dio.patch<Map<String, dynamic>>(
            '/api/users/me/active-club',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/users/me/active-club'),
                statusCode: 200,
                data: {'status': 'ok'},
              ));

      final repo = ClubMembershipRepository(
        firestore: FakeFirebaseFirestore(),
        dio: dio,
      );
      await repo.setActiveClub(clubId: 'club_a');

      verify(() => dio.patch<Map<String, dynamic>>(
            '/api/users/me/active-club',
            data: {'clubId': 'club_a'},
          )).called(1);
    });
  });
}
