import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/auth/data/auth_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}
class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  late _MockFirebaseAuth auth;
  late AuthRepository repo;

  setUp(() {
    auth = _MockFirebaseAuth();
    repo = AuthRepository(auth: auth);
  });

  test('signInWithEmail calls FirebaseAuth.signInWithEmailAndPassword', () async {
    when(() => auth.signInWithEmailAndPassword(
          email: 'a@b.com',
          password: 'secret123',
        )).thenAnswer((_) async => _MockUserCredential());

    await repo.signInWithEmail(email: 'a@b.com', password: 'secret123');

    verify(() => auth.signInWithEmailAndPassword(
          email: 'a@b.com',
          password: 'secret123',
        )).called(1);
  });
}
