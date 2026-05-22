import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '_widgets/sphere_home_card.dart';
import '_widgets/sphere_metric_tile.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final user = ref.watch(currentUserProvider).valueOrNull;
    // user.displayName not surfaced on staff today — header shows date + "Today"

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SphereSpacing.x24,
          SphereSpacing.x16,
          SphereSpacing.x24,
          90,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatToday(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SphereColors.onSurfaceMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                _BellIconButton(onTap: () {}),
              ],
            ),
            const SizedBox(height: SphereSpacing.x24),

            SphereHomeCard(
              leadingNumber: '3',
              title: 'Pending approvals',
              subtitle: 'Tap to review',
              onTap: () {},
            ),
            const SizedBox(height: SphereSpacing.x12),

            Row(
              children: [
                Expanded(
                  child: SphereMetricTile(
                    label: 'Sessions',
                    value: '2 today',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: SphereSpacing.x12),
                Expanded(
                  child: SphereMetricTile(
                    label: 'Roster',
                    value: '47 players',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: SphereSpacing.x24),

            _NextSessionCard(onTap: () {}),
          ],
        ),
      ),
    );
  }

  String _formatToday() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }
}

class _BellIconButton extends StatelessWidget {
  const _BellIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SphereColors.surfaceElev1,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(LucideIcons.bell, size: 20, color: SphereColors.onSurface),
        ),
      ),
    );
  }
}

class _NextSessionCard extends StatelessWidget {
  const _NextSessionCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: Container(
        padding: const EdgeInsets.all(SphereSpacing.x20),
        decoration: BoxDecoration(
          border: Border.all(color: SphereColors.borderSubtle),
          borderRadius: SphereRadius.cardRect,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next session',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x8),
            Text(
              'U13 Training',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SphereColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '7:00 PM, Stadium A',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(LucideIcons.qrCode, size: 18),
                label: const Text('QR Check-in'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SphereColors.primary,
                  foregroundColor: SphereColors.onPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: SphereRadius.pillRect,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
