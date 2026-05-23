import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';

class SignOutDialog extends StatelessWidget {
  const SignOutDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const SignOutDialog(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.sc.surfaceElev2,
      shape: const RoundedRectangleBorder(borderRadius: SphereRadius.modalRect),
      child: Padding(
        padding: const EdgeInsets.all(SphereSpacing.x20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.sc.danger.withValues(alpha: 0.12),
              ),
              child: Icon(
                LucideIcons.logOut,
                color: context.sc.danger,
                size: 26,
              ),
            ),
            const SizedBox(height: SphereSpacing.x16),
            Text(
              'Sign out of SportSphere?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.sc.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'You will need to log in again to access your account.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.sc.onSurfaceMuted,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: context.sc.borderSubtle),
                      shape: const RoundedRectangleBorder(
                        borderRadius: SphereRadius.pillRect,
                      ),
                      foregroundColor: context.sc.onSurface,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: SphereSpacing.x12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: context.sc.danger,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: SphereRadius.pillRect,
                      ),
                    ),
                    child: const Text(
                      'Sign out',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
