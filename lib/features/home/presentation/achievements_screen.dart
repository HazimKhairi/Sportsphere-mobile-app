import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/achievement.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_section_label.dart';
import 'achievements_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  Color _tierColor(BuildContext context, AchievementTier t) {
    switch (t) {
      case AchievementTier.platinum:
        return const Color(0xFFB9D7FF);
      case AchievementTier.gold:
        return const Color(0xFFFFC83C);
      case AchievementTier.silver:
        return const Color(0xFFD0D0D0);
      case AchievementTier.bronze:
        return const Color(0xFFC9824B);
      case AchievementTier.unknown:
        return context.sc.onSurfaceMuted;
    }
  }

  IconData _iconFor(Achievement a) {
    switch (a.iconName) {
      case 'flame':
        return LucideIcons.flame;
      case 'dumbbell':
        return LucideIcons.dumbbell;
      case 'target':
        return LucideIcons.target;
      case 'crown':
        return LucideIcons.crown;
      case 'medal':
        return LucideIcons.medal;
      case 'star':
        return LucideIcons.star;
      default:
        return LucideIcons.award;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(myAchievementsProvider);

    return SphereFieldBackground(
      child: Stack(
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
                Row(
                  children: [
                    Material(
                      color: context.sc.surfaceElev1,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/profile');
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            LucideIcons.chevronLeft,
                            size: 20,
                            color: context.sc.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SphereSpacing.x12),
                    Expanded(
                      child: Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x8),
                Text(
                  l.earnBadges,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                async.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(SphereSpacing.x20),
                        decoration: BoxDecoration(
                          color: context.sc.surfaceElev1,
                          borderRadius: SphereRadius.cardRect,
                          border: Border.all(color: context.sc.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.noBadgesYet,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.sc.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your coach can publish achievements from the dashboard.',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: context.sc.onSurfaceMuted,
                                      ),
                            ),
                          ],
                        ),
                      );
                    }
                    final unlockedCount = list.where((a) => a.unlocked).length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(SphereSpacing.x20),
                          decoration: BoxDecoration(
                            color: context.sc.surfaceElev1,
                            borderRadius: SphereRadius.cardRect,
                            border: Border.all(color: context.sc.borderSubtle),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.sc.surfaceElev1,
                                context.sc.primary.withValues(alpha: 0.04),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.sc.primary.withValues(alpha: 0.18),
                                  border: Border.all(
                                    color: context.sc.primary.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  '$unlockedCount',
                                  style: TextStyle(
                                    color: context.sc.primary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: SphereSpacing.x16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.badgesUnlocked,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: context.sc.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'out of ${list.length} total',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: context.sc.onSurfaceMuted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: SphereSpacing.x24),
                        const SphereSectionLabel('Collection'),
                        const SizedBox(height: SphereSpacing.x16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: SphereSpacing.x12,
                            crossAxisSpacing: SphereSpacing.x12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            final a = list[i];
                            return _BadgeCard(
                              achievement: a,
                              icon: _iconFor(a),
                              tierColor: _tierColor(context, a.tier),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(context.sc.primary),
                        ),
                      ),
                    ),
                  ),
                  error: (_, _) => Text(
                    'Couldn\'t load achievements.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.achievement,
    required this.icon,
    required this.tierColor,
  });

  final Achievement achievement;
  final IconData icon;
  final Color tierColor;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(
          color: unlocked
              ? tierColor.withValues(alpha: 0.5)
              : context.sc.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? tierColor.withValues(alpha: 0.2)
                  : context.sc.surfaceElev2,
              border: Border.all(
                color: unlocked
                    ? tierColor
                    : context.sc.borderSubtle,
                width: 1.5,
              ),
            ),
            child: Icon(
              unlocked ? icon : LucideIcons.lock,
              size: 26,
              color: unlocked ? tierColor : context.sc.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            achievement.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: unlocked
                      ? context.sc.onSurface
                      : context.sc.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              achievement.description.isEmpty
                  ? achievement.requirement
                  : achievement.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                    fontSize: 11,
                    height: 1.35,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (achievement.points > 0) ...[
            const SizedBox(height: SphereSpacing.x8),
            Row(
              children: [
                Icon(
                  LucideIcons.zap,
                  size: 12,
                  color: unlocked
                      ? tierColor
                      : context.sc.onSurfaceMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${achievement.points} pts',
                  style: TextStyle(
                    color: unlocked
                        ? tierColor
                        : context.sc.onSurfaceMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (achievement.tier != AchievementTier.unknown) ...[
                  const Spacer(),
                  Text(
                    achievement.tier.label.toUpperCase(),
                    style: TextStyle(
                      color: unlocked
                          ? tierColor
                          : context.sc.onSurfaceMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
