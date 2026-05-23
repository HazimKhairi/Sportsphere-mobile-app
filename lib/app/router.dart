import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/home/presentation/achievements_screen.dart';
import '../features/home/presentation/body_composition_screen.dart';
import '../features/home/presentation/drill_complete_screen.dart';
import '../features/home/presentation/drill_detail_screen.dart';
import '../features/home/presentation/drill_player_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/home/presentation/player_home_screen.dart';
import '../features/home/presentation/points_screen.dart';
import '../features/home/presentation/rewards_screen.dart';
import '../features/home/presentation/staff_home_screen.dart';
import '../features/home/presentation/train_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/payments/presentation/cash_pay_screen.dart';
import '../features/payments/presentation/payment_detail_screen.dart';
import '../features/payments/presentation/payment_failure_screen.dart';
import '../features/payments/presentation/payment_history_screen.dart';
import '../features/payments/presentation/payment_success_screen.dart';
import '../features/profile/presentation/about_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/help_faq_screen.dart';
import '../features/profile/presentation/language_picker_screen.dart';
import '../features/profile/presentation/notification_settings_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/theme_picker_screen.dart';
import '../features/programs/presentation/program_detail_screen.dart';
import '../features/programs/presentation/programs_list_screen.dart';
import '../features/role_pick/presentation/role_pick_screen.dart';
import '../features/role_pick/presentation/role_providers.dart';
import '../features/schedule/presentation/qr_scan_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';
import '../features/schedule/presentation/session_detail_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/approvals/presentation/approvals_screen.dart';
import '../features/roster/presentation/player_detail_screen.dart';
import '../features/roster/presentation/roster_screen.dart';
import '../features/sphere_ai/presentation/sphere_ai_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/splash' ||
          loc.startsWith('/qr-scan') ||
          loc.startsWith('/payment/') ||
          loc.endsWith('/play') ||
          loc.endsWith('/complete')) {
        return null;
      }

      final user = ref.read(currentUserProvider).valueOrNull;
      final role = ref.read(selectedRoleProvider);

      final atOnboarding = loc == '/onboarding';
      final atRolePick = loc == '/role-pick';
      final atLogin = loc.startsWith('/auth');

      // No role selected yet.
      // Allow onboarding (first-launch flow from splash) and role-pick through.
      // All other locations (including post-logout) go straight to role-pick.
      if (role == null) {
        if (atOnboarding || atRolePick) return null;
        return '/role-pick';
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

      // Block players from accessing staff-only routes.
      if (role == AppRole.player && loc.startsWith('/staff/')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/role-pick', builder: (_, _) => const RolePickScreen()),
      GoRoute(path: '/auth/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/auth/signup', builder: (_, _) => const SignupScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
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
        path: '/train/drill/:id/play',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return DrillPlayerScreen(drillId: id);
        },
      ),
      GoRoute(
        path: '/train/drill/:id/complete',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final reps = int.tryParse(state.uri.queryParameters['reps'] ?? '') ?? 0;
          final streak = int.tryParse(state.uri.queryParameters['streak'] ?? '') ?? 0;
          return DrillCompleteScreen(
            drillId: id,
            reps: reps,
            streakDays: streak,
          );
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
            path: '/train',
            builder: (_, _) => const TrainScreen(),
          ),
          GoRoute(
            path: '/train/drill/:id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return DrillDetailScreen(drillId: id);
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
            path: '/profile/edit',
            builder: (_, _) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/profile/notifications',
            builder: (_, _) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: '/profile/theme',
            builder: (_, _) => const ThemePickerScreen(),
          ),
          GoRoute(
            path: '/profile/language',
            builder: (_, _) => const LanguagePickerScreen(),
          ),
          GoRoute(
            path: '/profile/help',
            builder: (_, _) => const HelpFaqScreen(),
          ),
          GoRoute(
            path: '/profile/about',
            builder: (_, _) => const AboutScreen(),
          ),
          GoRoute(
            path: '/profile/achievements',
            builder: (_, _) => const AchievementsScreen(),
          ),
          GoRoute(
            path: '/profile/body-composition',
            builder: (_, _) => const BodyCompositionScreen(),
          ),
          GoRoute(
            path: '/profile/rewards',
            builder: (_, _) => const RewardsScreen(),
          ),
          GoRoute(
            path: '/profile/points',
            builder: (_, _) => const PointsScreen(),
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
          GoRoute(
            path: '/sphere-ai',
            builder: (_, _) => const SphereAiScreen(),
          ),
          GoRoute(
            path: '/staff/roster',
            builder: (_, _) => const RosterScreen(),
          ),
          GoRoute(
            path: '/staff/roster/:id',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              return PlayerDetailScreen(playerId: id);
            },
          ),
          GoRoute(
            path: '/staff/approvals',
            builder: (_, _) => const ApprovalsScreen(),
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
