import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_spacing.dart';

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final iconColor = danger ? context.sc.danger : context.sc.primary;
    final labelColor = danger ? context.sc.danger : context.sc.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SphereSpacing.x16,
          vertical: SphereSpacing.x16,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
              const SizedBox(width: 8),
            ],
            if (onTap != null && !danger)
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: context.sc.onSurfaceMuted,
              ),
          ],
        ),
      ),
    );
  }
}
