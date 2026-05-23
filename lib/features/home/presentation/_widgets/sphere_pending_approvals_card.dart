import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import 'sphere_count_up.dart';
import 'sphere_progress_ring.dart';

class SpherePendingApprovalsCard extends StatelessWidget {
  const SpherePendingApprovalsCard({
    super.key,
    required this.count,
    this.onTap,
    this.loading = false,
  });
  final int count;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final urgency = loading ? 0.0 : (count / 5).clamp(0.0, 1.0);
    final subtitle = loading
        ? 'Loading approvals…'
        : (count == 0
            ? 'You are all caught up.'
            : '$count payment${count == 1 ? '' : 's'} need a look.');
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
          ),
          child: Row(
            children: [
              SphereProgressRing(
                size: 80,
                value: urgency,
                strokeWidth: 5,
                child: loading
                    ? Text(
                        '--',
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                              color: context.sc.onSurfaceMuted,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    : SphereCountUp(
                        value: count,
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                              color: context.sc.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
              ),
              const SizedBox(width: SphereSpacing.x16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending approvals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.sc.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.arrowRight, color: context.sc.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
