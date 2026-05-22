import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import 'sphere_count_up.dart';
import 'sphere_progress_ring.dart';

class SpherePendingApprovalsCard extends StatelessWidget {
  const SpherePendingApprovalsCard({
    super.key,
    required this.count,
    this.onTap,
  });
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final urgency = (count / 5).clamp(0.0, 1.0);
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
          ),
          child: Row(
            children: [
              SphereProgressRing(
                size: 80,
                value: urgency,
                strokeWidth: 5,
                child: SphereCountUp(
                  value: count,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: SphereColors.primary,
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
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 payments need a look.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.arrowRight, color: SphereColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
