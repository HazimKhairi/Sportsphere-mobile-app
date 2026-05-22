import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/auth/data/auth_repository.dart';
import 'package:sportsphere_mobile/features/auth/domain/app_user.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}
class _MockUser extends Mock implements User {}

void main() {
  late _MockFirebaseAuth auth;
  late AuthRepository repo;

  setUp(() {
    auth = _MockFirebaseAuth();
    repo = AuthRepository(auth: auth);
  });

  test('userStream emits AppUser when FirebaseAuth has a user', () async {
    final user = _MockUser();
    when(() => user.uid).thenReturn('uid_123');
    when(() => user.email).thenReturn('player@test.sportsphere.my');
    when(() => user.displayName).thenReturn('Danial Hakim');
    when(() => user.photoURL).thenReturn(null);
    when(() => auth.authStateChanges()).thenAnswer(
      (_) => Stream.value(user),
    );

    final first = await repo.userStream().first;
    expect(first, isA<AppUser>());
    expect(first!.uid, 'uid_123');
    expect(first.email, 'player@test.sportsphere.my');
    expect(first.displayName, 'Danial Hakim');
  });

  test('userStream emits null when signed out', () async {
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    final first = await repo.userStream().first;
    expect(first, isNull);
  });
}
