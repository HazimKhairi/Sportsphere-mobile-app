import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '_widgets/sphere_activity_timeline_item.dart';
import '_widgets/sphere_drill_of_day_card.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/session_live_banner.dart';
import '_widgets/sphere_section_label.dart';
import '_widgets/sphere_streak_card.dart';
import 'player_home_providers.dart';

class PlayerHomeScreen extends ConsumerWidget {
  const PlayerHomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 2) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${(diff.inDays / 7).floor()} w ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final firstName = (user?.displayName ?? 'Player').split(' ').first;

    final streakAsync = ref.watch(playerStreakProvider);
    final drillAsync = ref.watch(todayDrillProvider);
    final activityAsync = ref.watch(activityTimelineProvider);

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
                const SphereEntrance(
                  delayMs: 0,
                  child: SessionLiveBanner(),
                ),
                SphereEntrance(
                  delayMs: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: SphereColors.onSurfaceMuted,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              firstName,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: SphereColors.onSurface,
                                    height: 1.1,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _BellIconButton(onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                // Streak card
                SphereEntrance(
                  delayMs: 80,
                  child: streakAsync.when(
                    data: (streak) => SphereStreakCard(
                      streakDays: streak.days,
                      goal: streak.goal,
                      onTap: () {},
                    ),
                    loading: () => const SphereStreakCard(
                      streakDays: 0,
                      goal: 10,
                      loading: true,
                    ),
                    error: (e, st) {
                      debugPrint('[home] streak error: $e\n$st');
                      return const SphereStreakCard(streakDays: 0, goal: 10);
                    },
                  ),
                ),
                const SizedBox(height: SphereSpacing.x16),

                // Drill of day
                SphereEntrance(
                  delayMs: 140,
                  child: drillAsync.when(
                    data: (drill) => SphereDrillOfDayCard(
                      drillName: drill?.name ?? '',
                      drillSubtitle: drill == null
                          ? 'New drill drops tomorrow.'
                          : '5 min · level ${drill.difficulty} ball control',
                      onTap: () {},
                    ),
                    loading: () => const SphereDrillOfDayCard(
                      drillName: '',
                      drillSubtitle: '',
                      loading: true,
                    ),
                    error: (e, st) {
                      debugPrint('[home] drill error: $e\n$st');
                      return const SphereDrillOfDayCard(
                        drillName: 'Couldn\'t load drill',
                        drillSubtitle: 'Try again later.',
                      );
                    },
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                const SphereEntrance(
                  delayMs: 200,
                  child: SphereSectionLabel('Today'),
                ),
                const SizedBox(height: SphereSpacing.x16),

                // Activity timeline
                SphereEntrance(
                  delayMs: 260,
                  child: activityAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No activity yet. Train today to start your streak.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SphereColors.onSurfaceMuted,
                                ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            SphereActivityTimelineItem(
                              title: items[i].title,
                              timeAgo: _timeAgo(items[i].createdAt),
                              icon: items[i].icon,
                              isLast: i == items.length - 1,
                            ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(SphereColors.primary),
                          ),
                        ),
                      ),
                    ),
                    error: (e, st) {
                      debugPrint('[home] activity error: $e\n$st');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Couldn\'t load activity.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: SphereColors.onSurfaceMuted,
                              ),
                        ),
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

class _BellIconButton extends StatelessWidget {
  const _BellIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: SphereColors.surfaceElev1,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(11),
              child: Icon(LucideIcons.bell, size: 20, color: SphereColors.onSurface),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SphereColors.primary,
              border: Border.all(color: SphereColors.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
