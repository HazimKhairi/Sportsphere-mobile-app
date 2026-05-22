import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/home/presentation/player_home_screen.dart';
import '../features/home/presentation/staff_home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/role_pick/presentation/role_pick_screen.dart';
import '../features/role_pick/presentation/role_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final user = ref.read(currentUserProvider).valueOrNull;
      final role = ref.read(selectedRoleProvider);
      final loc = state.matchedLocation;

      final atOnboarding = loc == '/onboarding';
      final atRolePick = loc == '/role-pick';
      final atLogin = loc.startsWith('/auth');

      if (role == null && !atOnboarding && !atRolePick) {
        return '/onboarding';
      }
      if (role != null && user == null && !atLogin && !atRolePick) {
        return '/auth/login';
      }
      if (user != null && (atOnboarding || atLogin || atRolePick)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/role-pick', builder: (_, _) => const RolePickScreen()),
      GoRoute(path: '/auth/login', builder: (_, _) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) {
              return Consumer(
                builder: (context, ref, _) {
                  final role = ref.watch(selectedRoleProvider);
                  return role == AppRole.staff
                      ? const StaffHomeScreen()
                      : const PlayerHomeScreen();
                },
              );
            },
          ),
        ],
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(currentUserProvider, (_, _) => notifyListeners());
    _ref.listen(selectedRoleProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}
