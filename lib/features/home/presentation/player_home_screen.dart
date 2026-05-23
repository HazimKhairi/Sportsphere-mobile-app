import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../club/presentation/club_providers.dart';
import '../../player_card/presentation/player_card_providers.dart';
import '../../profile/presentation/_widgets/pro_photo_sheet.dart';
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
    return Container(
      height: 380,
      decoration: const BoxDecoration(color: Color(0xFF0F0F0F)),
      child: Stack(
        children: [
          // Subtle radial glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Avatar + text + upload button
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12, width: 1.5),
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                    child: const Icon(LucideIcons.user, size: 36, color: Colors.white24),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Player Card Yet',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get rated by a coach to unlock your official card',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white24,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => ProPhotoSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.upload, size: 15, color: Colors.white60),
                          SizedBox(width: 8),
                          Text(
                            'Upload Your Photo',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom divider line
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Divider(color: Color(0xFF1A1A1A), height: 1),
          ),
        ],
      ),
    );
  }
}

