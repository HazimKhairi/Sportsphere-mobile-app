import 'package:flutter/material.dart';

import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';

class SphereMetricTile extends StatelessWidget {
  const SphereMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: onTap,
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            border: Border.all(color: SphereColors.borderSubtle),
            borderRadius: SphereRadius.cardRect,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x12),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SphereColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
