import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';

class SphereNextSessionCard extends StatelessWidget {
  const SphereNextSessionCard({super.key, this.onCheckIn});
  final VoidCallback? onCheckIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 14, color: SphereColors.primary),
              const SizedBox(width: 6),
              Text(
                'Starts in 2h 15m',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SphereColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            'U13 Training',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: SphereColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: SphereColors.onSurfaceMuted),
              const SizedBox(width: 6),
              Text(
                '7:00 PM · Stadium A',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: SphereSpacing.x20),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckIn,
              icon: const Icon(LucideIcons.qrCode, size: 18),
              label: const Text('QR Check-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SphereColors.primary,
                foregroundColor: SphereColors.onPrimary,
                shape: const RoundedRectangleBorder(borderRadius: SphereRadius.pillRect),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
