import 'package:flutter/material.dart';
import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_radius.dart';

class SphereQuickActionChip extends StatelessWidget {
  const SphereQuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      borderRadius: SphereRadius.pillRect,
      child: InkWell(
        onTap: onTap,
        borderRadius: SphereRadius.pillRect,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.pillRect,
            border: Border.all(color: context.sc.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: context.sc.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
