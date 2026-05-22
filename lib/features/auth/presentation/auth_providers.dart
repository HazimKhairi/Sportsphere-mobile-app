import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(auth: FirebaseAuth.instance);
}

@Riverpod(keepAlive: true)
Stream<AppUser?> currentUser(CurrentUserRef ref) {
  return ref.watch(authRepositoryProvider).userStream();
}
