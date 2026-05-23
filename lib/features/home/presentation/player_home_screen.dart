import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../club/presentation/club_providers.dart';
import '../../player_card/presentation/player_card_providers.dart';
import '_widgets/sphere_activity_timeline_item.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_player_hero_card.dart';
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
    final activityAsync = ref.watch(activityTimelineProvider);
    final cardAsync = ref.watch(playerCardProvider);
    final clubLogoUrl = ref.watch(myClubProvider).valueOrNull?.logoUrl;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Player hero (full-bleed) — greeting + logo overlaid inside ──
            SphereEntrance(
              delayMs: 0,
              child: cardAsync.when(
                data: (data) => SpherePlayerHeroCard(
                  card: data.card,
                  greeting: _greeting(),
                  firstName: firstName,
                  clubLogoUrl: clubLogoUrl,
                  onTap: () => context.push('/player-card'),
                ),
                loading: () => _CardShimmer(
                  greeting: _greeting(),
                  firstName: firstName,
                ),
                error: (e, st) => _CardPlaceholder(
                  onTap: () => context.push('/player-card'),
                ),
              ),
            ),

            // ── Below-hero content ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: SphereSpacing.x16),

                  // Streak card
                  SphereEntrance(
                    delayMs: 140,
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
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
          ],
        ),
      ),
    );
  }
}

class _CardShimmer extends StatelessWidget {
  const _CardShimmer({this.greeting, this.firstName});
  final String? greeting;
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      color: const Color(0xFF141414),
      child: Stack(
        children: [
          const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)),
          if (greeting != null || firstName != null)
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (greeting != null)
                    Text(greeting!, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  if (firstName != null)
                    Text(firstName!, style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    )),
                ],
              ),
            ),
        ],
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

