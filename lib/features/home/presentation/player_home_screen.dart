import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../player_card/presentation/_widgets/sphere_player_card_preview.dart';
import '../../player_card/presentation/player_card_providers.dart';
import '../../scout/presentation/scout_providers.dart';
import '_widgets/sphere_activity_timeline_item.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_skill_radar_card.dart';
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
    final displayName = ref.watch(userDisplayNameProvider).valueOrNull ?? 'Player';
    final firstName = displayName.split(' ').first;

    final streakAsync = ref.watch(playerStreakProvider);
    final scoutAsync = ref.watch(scoutProfileNotifierProvider);
    final activityAsync = ref.watch(activityTimelineProvider);
    final cardAsync = ref.watch(playerCardProvider);

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
                                    color: context.sc.onSurfaceMuted,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              firstName,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: context.sc.onSurface,
                                    height: 1.1,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/brand/sphere_wordmark.png',
                        height: 22,
                        fit: BoxFit.fitHeight,
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      _BellIconButton(onTap: () => context.push('/profile/notifications')),
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

                // Skill radar
                SphereEntrance(
                  delayMs: 140,
                  child: scoutAsync.when(
                    data: (profile) => SphereSkillRadarCard(
                      skills: profile?.skills ?? const {},
                      onTap: () => context.push('/scout'),
                    ),
                    loading: () => const SphereSkillRadarCard(
                      skills: {},
                      loading: true,
                    ),
                    error: (_, __) => SphereSkillRadarCard(
                      skills: const {},
                      onTap: () => context.push('/scout'),
                    ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x24),

                // My Player Card section
                SphereEntrance(
                  delayMs: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SphereSectionLabel('My Card'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.push('/player-card'),
                            child: Text(
                              'Full View',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.sc.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SphereSpacing.x12),
                      cardAsync.when(
                        data: (data) => SpherePlayerCardPreview(
                          card: data.card,
                          onTap: () => context.push('/player-card'),
                        ),
                        loading: () => _CardShimmer(),
                        error: (e, st) => _CardPlaceholder(
                          onTap: () => context.push('/player-card'),
                        ),
                      ),
                    ],
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
                                  color: context.sc.onSurfaceMuted,
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
                    loading: () => Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(context.sc.primary),
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
                                color: context.sc.onSurfaceMuted,
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

class _CardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(context.sc.primary),
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 360,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.idCard, size: 48, color: Colors.white12),
            const SizedBox(height: 12),
            Text(
              'No card yet',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white38,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Get rated by a coach to unlock',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white24,
                  ),
            ),
          ],
        ),
      ),
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
          color: context.sc.surfaceElev1,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(11),
              child: Icon(LucideIcons.bell, size: 20, color: context.sc.onSurface),
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
              color: context.sc.primary,
              border: Border.all(color: context.sc.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
