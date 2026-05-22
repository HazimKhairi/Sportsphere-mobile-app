import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/sphere_colors.dart';
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
  });
  final int streakDays;
  final int goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (streakDays / goal).clamp(0.0, 1.0);
    return Material(
      color: SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: onTap,
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x20),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.cardRect,
            border: Border.all(color: SphereColors.borderSubtle),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SphereColors.surfaceElev1,
                SphereColors.primary.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: Row(
            children: [
              SphereProgressRing(
                size: 80,
                value: progress,
                strokeWidth: 5,
                child: const Icon(
                  LucideIcons.flame,
                  color: SphereColors.primary,
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
                        SphereCountUp(
                          value: streakDays,
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                color: SphereColors.onSurface,
                                fontSize: 36,
                                height: 1,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'days',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: SphereColors.onSurfaceMuted,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'One more session and you hit your personal best.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SphereColors.onSurfaceMuted,
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
