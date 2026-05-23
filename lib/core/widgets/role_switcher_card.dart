import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../app/theme/sphere_radius.dart';
import '../../app/theme/sphere_spacing.dart';

class RoleSwitcherCard extends StatelessWidget {
  const RoleSwitcherCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.sc.primary : context.sc.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: onTap,
        borderRadius: SphereRadius.cardRect,
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x20),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? context.sc.onPrimary : context.sc.primary,
                size: 32,
              ),
              const SizedBox(width: SphereSpacing.x16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: selected
                                ? context.sc.onPrimary
                                : context.sc.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: selected
                                ? context.sc.onPrimary.withValues(alpha: 0.75)
                                : context.sc.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: selected
                    ? context.sc.onPrimary
                    : context.sc.onSurfaceMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
