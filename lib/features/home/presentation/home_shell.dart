import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/sphere_floating_nav_bar.dart';
import '../../role_pick/presentation/role_providers.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _playerTabs = [
    SphereNavTab(icon: LucideIcons.house, label: 'Home'),
    SphereNavTab(icon: LucideIcons.dumbbell, label: 'Train'),
    SphereNavTab(icon: LucideIcons.calendar, label: 'Schedule'),
    SphereNavTab(icon: LucideIcons.sparkles, label: 'Sphere AI'),
    SphereNavTab(icon: LucideIcons.user, label: 'Profile'),
  ];

  static const _staffTabs = [
    SphereNavTab(icon: LucideIcons.house, label: 'Home'),
    SphereNavTab(icon: LucideIcons.users, label: 'Roster'),
    SphereNavTab(icon: LucideIcons.calendar, label: 'Schedule'),
    SphereNavTab(icon: LucideIcons.checkCheck, label: 'Approvals'),
    SphereNavTab(icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(selectedRoleProvider);
    final tabs = role == AppRole.staff ? _staffTabs : _playerTabs;
    final loc = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (loc.startsWith('/schedule')) currentIndex = 2;
    if (loc.startsWith('/profile')) currentIndex = 4;
    // T11 adds /qr-scan but that hides the navbar, so no index needed.
    // Tasks for Train (1), Sphere AI (3) wired later.

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: child,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SphereFloatingNavBar(
              tabs: tabs,
              currentIndex: currentIndex,
              onTap: (i) {
                if (i == 0) context.go('/home');
                if (i == 2) context.go('/schedule');
                if (i == 4) context.go('/profile');
              },
            ),
          ),
        ],
      ),
    );
  }
}
