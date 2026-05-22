import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/home/presentation/player_home_screen.dart';
import '../features/home/presentation/staff_home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/payments/presentation/cash_pay_screen.dart';
import '../features/payments/presentation/payment_detail_screen.dart';
import '../features/payments/presentation/payment_failure_screen.dart';
import '../features/payments/presentation/payment_history_screen.dart';
import '../features/payments/presentation/payment_success_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/programs/presentation/program_detail_screen.dart';
import '../features/programs/presentation/programs_list_screen.dart';
import '../features/role_pick/presentation/role_pick_screen.dart';
import '../features/role_pick/presentation/role_providers.dart';
import '../features/schedule/presentation/qr_scan_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';
import '../features/schedule/presentation/session_detail_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/splash' ||
          loc.startsWith('/qr-scan') ||
          loc.startsWith('/payment/')) {
        return null;
      }

      final user = ref.read(currentUserProvider).valueOrNull;
      final role = ref.read(selectedRoleProvider);

      final atOnboarding = loc == '/onboarding';
      final atRolePick = loc == '/role-pick';
      final atLogin = loc.startsWith('/auth');

      // No role: route through onboarding then role pick.
      if (role == null) {
        if (atOnboarding || atRolePick) return null;
        return '/onboarding';
      }

      // Role chosen, not authenticated yet: force login.
      if (user == null) {
        if (atLogin || atRolePick) return null;
        return '/auth/login';
      }

      // Fully ready: leaving pre-home surfaces lands on home.
      if (atOnboarding || atLogin || atRolePick) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/role-pick', builder: (_, _) => const RolePickScreen()),
      GoRoute(path: '/auth/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/qr-scan/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return QrScanScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/payment/cash/:programId',
        builder: (_, state) {
          final id = state.pathParameters['programId']!;
          return CashPayScreen(programId: id);
        },
      ),
      GoRoute(
        path: '/payment/success/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return PaymentSuccessScreen(registrationId: id);
        },
      ),
      GoRoute(
        path: '/payment/failure',
        builder: (_, state) {
          final reason = state.uri.queryParameters['reason'];
          return PaymentFailureScreen(reason: reason);
        },
      ),
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
          GoRoute(
            path: '/schedule',
            builder: (_, _) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/schedule/session/:id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return SessionDetailScreen(sessionId: id);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (_, _) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/payments',
            builder: (_, _) => const PaymentHistoryScreen(),
          ),
          GoRoute(
            path: '/profile/payments/:id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return PaymentDetailScreen(paymentId: id);
            },
          ),
          GoRoute(
            path: '/programs',
            builder: (_, _) => const ProgramsListScreen(),
          ),
          GoRoute(
            path: '/programs/:id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return ProgramDetailScreen(programId: id);
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
