import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/auth/data/auth_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockFirebaseAuth auth;
  late AuthRepository repo;

  setUp(() {
    auth = _MockFirebaseAuth();
    repo = AuthRepository(auth: auth);
  });

  test('signUpWithEmail creates user + updates displayName', () async {
    final user = _MockUser();
    when(() => user.updateDisplayName('Danial')).thenAnswer((_) async {});
    final cred = _MockUserCredential();
    when(() => cred.user).thenReturn(user);
    when(
      () => auth.createUserWithEmailAndPassword(
        email: 'a@b.com',
        password: 'secret123',
      ),
    ).thenAnswer((_) async => cred);

    await repo.signUpWithEmail(
      email: 'a@b.com',
      password: 'secret123',
      displayName: 'Danial',
    );

    verify(
      () => auth.createUserWithEmailAndPassword(
        email: 'a@b.com',
        password: 'secret123',
      ),
    ).called(1);
    verify(() => user.updateDisplayName('Danial')).called(1);
  });

  test('signUpWithEmail rethrows FirebaseAuthException', () async {
    when(
      () => auth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    expect(
      () => repo.signUpWithEmail(
        email: 'a@b.com',
        password: 'x',
        displayName: 'Y',
      ),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('signUpWithEmail skips updateDisplayName when displayName empty',
      () async {
    final user = _MockUser();
    final cred = _MockUserCredential();
    when(() => cred.user).thenReturn(user);
    when(
      () => auth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => cred);

    await repo.signUpWithEmail(
      email: 'a@b.com',
      password: 'x',
      displayName: '',
    );

    verifyNever(() => user.updateDisplayName(any()));
  });
}
