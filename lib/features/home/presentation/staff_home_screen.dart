import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '_widgets/sphere_avatar_stack.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_next_session_card.dart';
import '_widgets/sphere_pending_approvals_card.dart';
import '_widgets/sphere_quick_action_chip.dart';
import '_widgets/sphere_section_label.dart';
import 'staff_home_providers.dart';

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

    final pendingApprovalsAsync = ref.watch(staffPendingApprovalsProvider);
    final nextSessionAsync = ref.watch(staffNextSessionProvider);
    final rosterCountAsync = ref.watch(staffRosterCountProvider);

    final pendingCount = pendingApprovalsAsync.valueOrNull ?? 0;
    final pendingLoading = pendingApprovalsAsync.isLoading;

    final nextSession = nextSessionAsync.valueOrNull;
    final nextSessionLoading = nextSessionAsync.isLoading;

    final rosterCount = rosterCountAsync.valueOrNull ?? 0;

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
                                    color: context.sc.onSurfaceMuted,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Coach $firstName',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: context.sc.onSurface,
                                    height: 1.1,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formattedDate(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _BellIconButton(
                          onTap: () => NotificationsSheet.show(context)),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                SphereEntrance(
                  delayMs: 80,
                  child: SpherePendingApprovalsCard(
                    count: pendingCount,
                    loading: pendingLoading,
                    onTap: () => context.push('/staff/approvals'),
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
                          onTap: () => context.go('/schedule'),
                        ),
                        const SizedBox(width: 8),
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
                  child: SphereNextSessionCard(
                    session: nextSession,
                    loading: nextSessionLoading,
                    onCheckIn: () {},
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                const SphereEntrance(
                  delayMs: 300,
                  child: SphereSectionLabel('Your team'),
                ),
                const SizedBox(height: SphereSpacing.x16),
                SphereEntrance(
                  delayMs: 340,
                  child: GestureDetector(
                    onTap: () => context.push('/staff/roster'),
                    child: Container(
                    padding: const EdgeInsets.all(SphereSpacing.x20),
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        SphereAvatarStack(total: rosterCount),
                        const SizedBox(width: SphereSpacing.x16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$rosterCount active player${rosterCount == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: context.sc.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap to manage roster',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.sc.onSurfaceMuted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(LucideIcons.arrowRight,
                            color: context.sc.primary, size: 20),
                      ],
                    ),
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: uid == null
          ? const Stream.empty()
          : FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .where('read', isEqualTo: false)
              .snapshots(),
      builder: (context, snap) {
        final unread = snap.data?.docs.length ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: context.sc.surfaceElev1,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Icon(LucideIcons.bell,
                      size: 20, color: context.sc.onSurface),
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: context.sc.primary,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: context.sc.surface, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
