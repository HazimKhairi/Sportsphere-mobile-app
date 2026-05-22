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
import '_widgets/sphere_section_label.dart';
import '_widgets/sphere_streak_card.dart';

class PlayerHomeScreen extends ConsumerWidget {
  const PlayerHomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final firstName = (user?.displayName ?? 'Player').split(' ').first;

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

                SphereEntrance(
                  delayMs: 80,
                  child: SphereStreakCard(streakDays: 7, onTap: () {}),
                ),
                const SizedBox(height: SphereSpacing.x16),

                SphereEntrance(
                  delayMs: 140,
                  child: SphereDrillOfDayCard(onTap: () {}),
                ),
                const SizedBox(height: SphereSpacing.x32),

                const SphereEntrance(
                  delayMs: 200,
                  child: SphereSectionLabel('Today'),
                ),
                const SizedBox(height: SphereSpacing.x16),

                const SphereEntrance(
                  delayMs: 260,
                  child: Column(
                    children: [
                      SphereActivityTimelineItem(
                        title: 'Checked in to Training 7pm',
                        timeAgo: '12 min ago',
                        icon: LucideIcons.check,
                      ),
                      SphereActivityTimelineItem(
                        title: 'Match scheduled tomorrow',
                        timeAgo: '2 h ago',
                        icon: LucideIcons.calendar,
                      ),
                      SphereActivityTimelineItem(
                        title: 'Earned badge: First Drill',
                        timeAgo: 'Yesterday',
                        icon: LucideIcons.award,
                        isLast: true,
                      ),
                    ],
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
