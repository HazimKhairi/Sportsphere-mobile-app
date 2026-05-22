import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '_widgets/sphere_avatar_stack.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_next_session_card.dart';
import '_widgets/sphere_pending_approvals_card.dart';
import '_widgets/sphere_quick_action_chip.dart';
import '_widgets/sphere_section_label.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final firstName = (user?.displayName ?? 'Coach').split(' ').first;

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        SafeArea(
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
                SphereEntrance(
                  delayMs: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()},',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: SphereColors.onSurfaceMuted,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Coach $firstName',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: SphereColors.onSurface,
                                    height: 1.1,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formattedDate(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: SphereColors.onSurfaceMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _BellIconButton(onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                SphereEntrance(
                  delayMs: 80,
                  child: SpherePendingApprovalsCard(
                    count: 3,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: SphereSpacing.x16),

                SphereEntrance(
                  delayMs: 140,
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SphereQuickActionChip(
                          icon: LucideIcons.scanLine,
                          label: 'Take attendance',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        SphereQuickActionChip(
                          icon: LucideIcons.calendarPlus,
                          label: 'Create session',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        SphereQuickActionChip(
                          icon: LucideIcons.megaphone,
                          label: 'Send announcement',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                const SphereEntrance(
                  delayMs: 200,
                  child: SphereSectionLabel('Up next'),
                ),
                const SizedBox(height: SphereSpacing.x16),
                SphereEntrance(
                  delayMs: 240,
                  child: SphereNextSessionCard(onCheckIn: () {}),
                ),
                const SizedBox(height: SphereSpacing.x32),

                const SphereEntrance(
                  delayMs: 300,
                  child: SphereSectionLabel('Your team'),
                ),
                const SizedBox(height: SphereSpacing.x16),
                SphereEntrance(
                  delayMs: 340,
                  child: Container(
                    padding: const EdgeInsets.all(SphereSpacing.x20),
                    decoration: BoxDecoration(
                      color: SphereColors.surfaceElev1,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      border: Border.all(color: SphereColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const SphereAvatarStack(total: 47),
                        const SizedBox(width: SphereSpacing.x16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '47 active players',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: SphereColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap to manage roster',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: SphereColors.onSurfaceMuted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.arrowRight,
                            color: SphereColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BellIconButton extends StatelessWidget {
  const _BellIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: SphereColors.surfaceElev1,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(11),
              child: Icon(LucideIcons.bell, size: 20, color: SphereColors.onSurface),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SphereColors.primary,
              border: Border.all(color: SphereColors.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
