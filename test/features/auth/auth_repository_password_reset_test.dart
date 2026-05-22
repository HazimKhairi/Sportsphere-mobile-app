import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/auth/data/auth_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late _MockFirebaseAuth auth;
  late AuthRepository repo;

  setUp(() {
    auth = _MockFirebaseAuth();
    repo = AuthRepository(auth: auth);
  });

  test('sendPasswordReset calls sendPasswordResetEmail with the given email',
      () async {
    when(() => auth.sendPasswordResetEmail(email: 'foo@bar.com'))
        .thenAnswer((_) async {});

    await repo.sendPasswordReset(email: 'foo@bar.com');

    verify(() => auth.sendPasswordResetEmail(email: 'foo@bar.com')).called(1);
  });

  test('sendPasswordReset propagates FirebaseAuthException from auth',
      () async {
    when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
        .thenThrow(FirebaseAuthException(code: 'invalid-email'));

    expect(
      () => repo.sendPasswordReset(email: 'bad-email'),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}
