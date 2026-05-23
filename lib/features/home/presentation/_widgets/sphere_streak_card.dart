import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import 'sphere_count_up.dart';
import 'sphere_progress_ring.dart';

class SphereStreakCard extends StatelessWidget {
  const SphereStreakCard({
    super.key,
    required this.streakDays,
    this.goal = 10,
    this.onTap,
    this.loading = false,
  });
  final int streakDays;
  final int goal;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final progress = loading ? 0.0 : (streakDays / goal).clamp(0.0, 1.0);
    final subtitle = loading
        ? 'Loading your streak…'
        : (streakDays == 0
            ? 'Start your streak today.'
            : 'One more session and you hit your personal best.');
    return Material(
      color: context.sc.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x20),
          decoration: BoxDecoration(
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
              SphereProgressRing(
                size: 80,
                value: progress,
                strokeWidth: 5,
                child: Icon(
                  LucideIcons.flame,
                  color: context.sc.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: SphereSpacing.x16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (loading)
                          Text(
                            '--',
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                  color: context.sc.onSurfaceMuted,
                                  fontSize: 36,
                                  height: 1,
                                ),
                          )
                        else
                          SphereCountUp(
                            value: streakDays,
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                  color: context.sc.onSurface,
                                  fontSize: 36,
                                  height: 1,
                                ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          'days',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.sc.onSurfaceMuted,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.sc.onSurfaceMuted,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
