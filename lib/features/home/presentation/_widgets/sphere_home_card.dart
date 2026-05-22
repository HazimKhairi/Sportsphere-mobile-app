import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';

class SphereHomeCard extends StatelessWidget {
  const SphereHomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingNumber,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? leadingNumber;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: onTap,
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x20),
          decoration: BoxDecoration(
            border: Border.all(color: SphereColors.borderSubtle),
            borderRadius: SphereRadius.cardRect,
          ),
          child: Row(
            children: [
              if (leadingNumber != null) ...[
                _BigNumber(value: leadingNumber!),
                const SizedBox(width: SphereSpacing.x16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: SphereSpacing.x12),
                      trailing!,
                    ],
                  ],
                ),
              ),
              if (onTap != null && trailing == null) ...[
                const SizedBox(width: SphereSpacing.x8),
                const Icon(
                  LucideIcons.arrowRight,
                  size: 22,
                  color: SphereColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BigNumber extends StatelessWidget {
  const _BigNumber({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SphereColors.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: SphereColors.primary.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: SphereColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
