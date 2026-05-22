import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/active_club_repository.dart';

void main() {
  test('activeClubIdStream emits activeClubId from users/{uid}.activeClubId', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('uid_1').set({
      'activeClubId': 'club_abc',
    });

    final repo = ActiveClubRepository(firestore: firestore);
    final clubId = await repo.activeClubIdStream(userId: 'uid_1').first;
    expect(clubId, 'club_abc');
  });

  test('emits null when activeClubId field missing', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('uid_1').set({'name': 'X'});
    final repo = ActiveClubRepository(firestore: firestore);
    final clubId = await repo.activeClubIdStream(userId: 'uid_1').first;
    expect(clubId, isNull);
  });

  test('emits null when user document missing', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = ActiveClubRepository(firestore: firestore);
    final clubId = await repo.activeClubIdStream(userId: 'missing').first;
    expect(clubId, isNull);
  });
}
