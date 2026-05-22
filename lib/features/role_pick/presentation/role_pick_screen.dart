import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_spacing.dart';
import '../../../core/widgets/role_switcher_card.dart';
import 'role_providers.dart';

class RolePickScreen extends ConsumerWidget {
  const RolePickScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SphereSpacing.x16),
              Text(
                'Pilih role kau',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: SphereSpacing.x8),
              Text(
                'Boleh tukar nanti dalam Settings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: SphereSpacing.x32),
              RoleSwitcherCard(
                icon: LucideIcons.user,
                title: 'Player',
                subtitle: 'Training, drills, schedule, AI coach.',
                onTap: () async {
                  await ref.read(selectedRoleProvider.notifier).set(AppRole.player);
                  if (context.mounted) context.go('/auth/login');
                },
              ),
              const SizedBox(height: SphereSpacing.x12),
              RoleSwitcherCard(
                icon: LucideIcons.userCog,
                title: 'Staff',
                subtitle: 'Attendance, roster, approvals.',
                onTap: () async {
                  await ref.read(selectedRoleProvider.notifier).set(AppRole.staff);
                  if (context.mounted) context.go('/auth/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
