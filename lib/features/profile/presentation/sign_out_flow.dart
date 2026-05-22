import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../notifications/presentation/fcm_providers.dart';
import '../../role_pick/presentation/role_providers.dart';

/// Runs the full sign-out sequence:
/// 1. Best-effort FCM device unregister (won't throw)
/// 2. Clear selectedRole from SharedPreferences
/// 3. FirebaseAuth.signOut
///
/// The router's refreshListenable picks up both auth + role changes and
/// redirects the user back to onboarding.
Future<void> runSignOut(WidgetRef ref) async {
  final fcmCleanup = ref.read(fcmLogoutCleanupProvider);
  await fcmCleanup();

  await ref.read(selectedRoleProvider.notifier).clear();
  await ref.read(authRepositoryProvider).signOut();
}
