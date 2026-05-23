import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
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

/// Fetches the real display name from Firestore via /api/user/profile.
/// Falls back to Firebase Auth displayName if the call fails.
@riverpod
Future<String> userDisplayName(UserDisplayNameRef ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return '';
  try {
    final dio = buildApiClient(baseUrl: SphereConfig.apiBaseUrl);
    final res = await dio.get<Map<String, dynamic>>('/api/user/profile');
    final name = res.data?['displayName'] as String?;
    if (name != null && name.trim().isNotEmpty) return name.trim();
  } catch (_) {}
  return user.displayName;
}
