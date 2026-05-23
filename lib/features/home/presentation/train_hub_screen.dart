import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_spacing.dart';
import '_widgets/sphere_drill_of_day_card.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_feature_grid_card.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_section_label.dart';
import 'train_providers.dart';

class TrainHubScreen extends ConsumerWidget {
  const TrainHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allDrillsProvider);
    final todayAsync = ref.watch(todayDrillProvider);
    final drillCount = allAsync.valueOrNull?.length ?? 0;

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24,
              SphereSpacing.x16,
              SphereSpacing.x24,
              90,
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
                    'Your performance hub.',
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
                            subtitle: 'Gym & conditioning',
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
                            subtitle: 'Coach-assigned programs',
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
                            subtitle: 'Wellness & nutrition',
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
                SphereEntrance(
                  delayMs: 300,
                  child: const SphereSectionLabel("Today's Drill"),
                ),
                const SizedBox(height: SphereSpacing.x16),
                SphereEntrance(
                  delayMs: 340,
                  child: todayAsync.when(
                    data: (drill) => SphereDrillOfDayCard(
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
                    error: (e, st) {
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
