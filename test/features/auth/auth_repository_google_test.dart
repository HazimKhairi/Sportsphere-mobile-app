import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/auth/data/auth_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  // Phase 1 smoke test only: we verify the method exists and is callable.
  //
  // The google_sign_in 7.x flow uses a singleton platform channel
  // (GoogleSignIn.instance.initialize() + authenticate()) which cannot be
  // mocked without a custom GoogleSignInPlatform implementation. A proper
  // integration test that exercises the full Google → Firebase credential
  // exchange is queued for Phase 2 once we have device-runner CI on
  // Codemagic.
  test('AuthRepository exposes signInWithGoogle method', () {
    final repo = AuthRepository(auth: _MockFirebaseAuth());
    expect(repo.signInWithGoogle, isA<Function>());
  });
}
