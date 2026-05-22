import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../../role_pick/presentation/role_providers.dart';
import '_widgets/profile_row.dart';
import '_widgets/profile_section_card.dart';
import '_widgets/sign_out_dialog.dart';
import 'sign_out_flow.dart';
import 'switch_club_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _initialsFrom(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final role = ref.watch(selectedRoleProvider);
    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (role == AppRole.staff ? 'Coach' : 'Player');
    final email = user?.email ?? '';
    final roleLabel = role == AppRole.staff ? 'Staff' : 'Player';

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Profile',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    _BellIconButton(onTap: () {}),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x24),

                _IdentityCard(
                  displayName: displayName,
                  email: email,
                  initials: _initialsFrom(displayName),
                  roleLabel: roleLabel,
                ),
                const SizedBox(height: SphereSpacing.x32),

                const SphereSectionLabel('My account'),
                const SizedBox(height: SphereSpacing.x12),
                ProfileSectionCard(
                  children: [
                    ProfileRow(
                      icon: LucideIcons.userPen,
                      label: 'Edit profile',
                      onTap: () => _comingSoon(context, 'Edit profile'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.layoutGrid,
                      label: 'Browse programs',
                      onTap: () => GoRouter.of(context).push('/programs'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.receipt,
                      label: 'Payment history',
                      onTap: () =>
                          GoRouter.of(context).push('/profile/payments'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.gift,
                      label: 'Rewards',
                      onTap: () =>
                          GoRouter.of(context).push('/profile/rewards'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.star,
                      label: 'Points & History',
                      onTap: () =>
                          GoRouter.of(context).push('/profile/points'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.award,
                      label: 'Achievements',
                      onTap: () =>
                          GoRouter.of(context).push('/profile/achievements'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.activity,
                      label: 'Body composition',
                      onTap: () => GoRouter.of(context)
                          .push('/profile/body-composition'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.arrowRightLeft,
                      label: 'Switch club',
                      onTap: () => SwitchClubSheet.show(context),
                    ),
                    ProfileRow(
                      icon: LucideIcons.bell,
                      label: 'Notifications',
                      onTap: () => _comingSoon(context, 'Notification settings'),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x24),

                const SphereSectionLabel('App'),
                const SizedBox(height: SphereSpacing.x12),
                ProfileSectionCard(
                  children: [
                    ProfileRow(
                      icon: LucideIcons.palette,
                      label: 'Theme',
                      trailingText: 'Dark',
                      onTap: () => _comingSoon(context, 'Theme picker'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.languages,
                      label: 'Language',
                      trailingText: 'EN',
                      onTap: () => _comingSoon(context, 'Language picker'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.circleHelp,
                      label: 'Help and FAQ',
                      onTap: () => _comingSoon(context, 'Help'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.info,
                      label: 'About',
                      onTap: () => _comingSoon(context, 'About'),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x24),

                ProfileSectionCard(
                  children: [
                    ProfileRow(
                      icon: LucideIcons.logOut,
                      label: 'Sign out',
                      danger: true,
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x24),

                Center(
                  child: Text(
                    'v1.0.0+1 · 2026-05-22',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SphereColors.onSurfaceMuted,
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

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label coming soon.')),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await SignOutDialog.show(context);
    if (!confirmed) return;
    try {
      await runSignOut(ref);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.displayName,
    required this.email,
    required this.initials,
    required this.roleLabel,
  });

  final String displayName;
  final String email;
  final String initials;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SphereColors.surfaceElev1,
            SphereColors.primary.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SphereColors.primary.withValues(alpha: 0.18),
              border: Border.all(
                color: SphereColors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: SphereColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: SphereSpacing.x16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: SphereColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SphereColors.primary.withValues(alpha: 0.18),
                    borderRadius: SphereRadius.pillRect,
                    border: Border.all(
                      color: SphereColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    roleLabel.toUpperCase(),
                    style: const TextStyle(
                      color: SphereColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
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
          padding: EdgeInsets.all(11),
          child: Icon(LucideIcons.bell, size: 20, color: SphereColors.onSurface),
        ),
      ),
    );
  }
}
