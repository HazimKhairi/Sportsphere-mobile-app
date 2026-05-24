import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import 'staff_training_providers.dart';

class StaffTrainingHubScreen extends ConsumerWidget {
  const StaffTrainingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(staffWorkoutTemplatesProvider);
    final plansAsync = ref.watch(staffTrainingPlansProvider);

    final workoutSubtitle = workoutsAsync.when(
      data: (list) {
        final count = list.length;
        return '$count template${count == 1 ? '' : 's'}';
      },
      loading: () => AppLocalizations.of(context)!.loading,
      error: (e, st) => 'Tap to manage',
    );

    final planSubtitle = plansAsync.when(
      data: (list) {
        final count = list.length;
        return '$count plan${count == 1 ? '' : 's'}';
      },
      loading: () => AppLocalizations.of(context)!.loading,
      error: (e, st) => 'Tap to manage',
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Training'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24,
            SphereSpacing.x8,
            SphereSpacing.x24,
            SphereSpacing.bottomNavSafe,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SphereEntrance(
                delayMs: 0,
                child: SphereSectionLabel(
                    AppLocalizations.of(context)!.workoutTemplates),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SphereEntrance(
                delayMs: 80,
                child: _HubCard(
                  icon: LucideIcons.dumbbell,
                  accentColor: const Color(0xFFF97316),
                  title: AppLocalizations.of(context)!.workoutTemplates,
                  subtitle: workoutSubtitle,
                  onTap: () => context.push('/staff/training/workouts'),
                ),
              ),
              const SizedBox(height: SphereSpacing.x24),
              SphereEntrance(
                delayMs: 160,
                child: SphereSectionLabel(
                    AppLocalizations.of(context)!.trainingPlans),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SphereEntrance(
                delayMs: 240,
                child: _HubCard(
                  icon: LucideIcons.clipboardList,
                  accentColor: const Color(0xFF3B82F6),
                  title: AppLocalizations.of(context)!.trainingPlans,
                  subtitle: planSubtitle,
                  onTap: () => context.push('/staff/training/plans'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SphereSpacing.x20),
        margin: const EdgeInsets.only(bottom: SphereSpacing.x12),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(width: SphereSpacing.x16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.arrowRight, color: context.sc.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
