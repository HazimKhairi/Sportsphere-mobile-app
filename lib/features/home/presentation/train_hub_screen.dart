import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '_widgets/sphere_drill_of_day_card.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_feature_grid_card.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_section_label.dart';
import '../domain/today_drill.dart';
import 'train_providers.dart';
import 'player_home_providers.dart';
import '../../strength/presentation/strength_providers.dart';
import '../../training_plans/presentation/training_plans_providers.dart';
import '../../recovery/presentation/recovery_providers.dart';

class TrainHubScreen extends ConsumerWidget {
  const TrainHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final allAsync = ref.watch(allDrillsProvider);
    final todayAsync = ref.watch(todayDrillProvider);
    final drillCount = allAsync.valueOrNull?.length ?? 0;

    final plansAsync = ref.watch(assignedPlansProvider);
    final workoutsAsync = ref.watch(assignedWorkoutsProvider);
    final todayLog = ref.watch(todayRecoveryLogProvider);

    final activePlan = plansAsync.valueOrNull?.isNotEmpty == true
        ? plansAsync.valueOrNull!.first
        : null;
    final workoutCount = workoutsAsync.valueOrNull?.length ?? 0;
    final wellnessScore = todayLog.valueOrNull?.wellnessScore;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/brand/field_bg.webp',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.82),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24,
              SphereSpacing.x16,
              SphereSpacing.x24,
              SphereSpacing.bottomNavSafe,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SphereEntrance(
                  delayMs: 0,
                  child: Text(
                    'Train',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: SphereSpacing.x8),
                SphereEntrance(
                  delayMs: 40,
                  child: Text(
                    l.yourPerformanceHub,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x24),

                // Row 1: Skills + Strength
                Row(
                  children: [
                    Expanded(
                      child: SphereEntrance(
                        delayMs: 80,
                        child: SizedBox(
                          height: 156,
                          child: SphereFeatureGridCard(
                            title: 'Skills',
                            subtitle: '$drillCount drills available',
                            icon: LucideIcons.target,
                            accentColor: const Color(0xFF37F513),
                            metricWidget: SphereGridProgressBar(
                              value: drillCount > 0 ? 1.0 : 0.0,
                              color: const Color(0xFF37F513),
                            ),
                            onTap: () => context.push('/train/skills'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SphereSpacing.x12),
                    Expanded(
                      child: SphereEntrance(
                        delayMs: 140,
                        child: SizedBox(
                          height: 156,
                          child: SphereFeatureGridCard(
                            title: 'Strength',
                            subtitle: workoutCount > 0 ? '$workoutCount workout${workoutCount == 1 ? '' : 's'} assigned' : 'No workouts yet',
                            icon: LucideIcons.dumbbell,
                            accentColor: const Color(0xFFF97316),
                            onTap: () => context.push('/train/strength'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x12),

                // Row 2: Plans + Recovery
                Row(
                  children: [
                    Expanded(
                      child: SphereEntrance(
                        delayMs: 200,
                        child: SizedBox(
                          height: 156,
                          child: SphereFeatureGridCard(
                            title: 'Plans',
                            subtitle: activePlan != null ? 'Week ${activePlan.currentWeek} of ${activePlan.totalWeeks}' : 'No active plan',
                            icon: LucideIcons.clipboardList,
                            accentColor: const Color(0xFF3B82F6),
                            onTap: () => context.push('/train/plans'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SphereSpacing.x12),
                    Expanded(
                      child: SphereEntrance(
                        delayMs: 260,
                        child: SizedBox(
                          height: 156,
                          child: SphereFeatureGridCard(
                            title: 'Recovery',
                            subtitle: wellnessScore != null ? 'Score: $wellnessScore%' : 'Tap to log wellness',
                            icon: LucideIcons.heartPulse,
                            accentColor: const Color(0xFF8B5CF6),
                            onTap: () => context.push('/train/recovery'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: SphereSpacing.x32),
                const SphereEntrance(
                  delayMs: 300,
                  child: SphereSectionLabel("Today's Drill"),
                ),
                const SizedBox(height: SphereSpacing.x16),
                SphereEntrance(
                  delayMs: 340,
                  child: todayAsync.when(
                    data: (TodayDrill? drill) => SphereDrillOfDayCard(
                      drillName: drill?.name ?? 'No drill assigned',
                      drillSubtitle: drill == null
                          ? 'Come back tomorrow.'
                          : '5 min · level ${drill.difficulty} ball control',
                      onTap: drill == null
                          ? null
                          : () => context.push('/train/drill/${drill.id}'),
                    ),
                    loading: () => const SphereDrillOfDayCard(
                      drillName: '',
                      drillSubtitle: '',
                      loading: true,
                    ),
                    error: (Object e, StackTrace st) {
                      debugPrint('[train_hub] todayDrill error: $e\n$st');
                      return const SphereDrillOfDayCard(
                        drillName: "Couldn't load drill",
                        drillSubtitle: 'Try again later.',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
