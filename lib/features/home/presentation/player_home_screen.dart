import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '_widgets/sphere_home_card.dart';
import '_widgets/sphere_metric_tile.dart';

class PlayerHomeScreen extends ConsumerWidget {
  const PlayerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final firstName = (user?.displayName ?? 'Player').split(' ').first;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SphereSpacing.x24,
          SphereSpacing.x16,
          SphereSpacing.x24,
          90, // bottomNavSafe
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hi, $firstName',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                _BellIconButton(onTap: () {}),
              ],
            ),
            const SizedBox(height: SphereSpacing.x24),

            // Streak hero card
            SphereHomeCard(
              title: '7-day streak',
              subtitle: 'Train today to keep it going.',
              onTap: () {},
            ),
            const SizedBox(height: SphereSpacing.x12),

            // 2-col metric grid
            Row(
              children: [
                Expanded(
                  child: SphereMetricTile(
                    label: 'Train',
                    value: '3 drills today',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: SphereSpacing.x12),
                Expanded(
                  child: SphereMetricTile(
                    label: 'Schedule',
                    value: 'Match tomorrow',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: SphereSpacing.x24),

            // Today section
            Text(
              'Today',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x8),
            const Divider(color: SphereColors.borderSubtle, height: 1),
            const SizedBox(height: SphereSpacing.x12),
            _ActivityRow(
              label: 'Checked in: Training 7pm',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
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

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(LucideIcons.arrowRight, size: 18, color: SphereColors.primary),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
