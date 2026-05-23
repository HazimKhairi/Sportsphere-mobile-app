import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../../role_pick/presentation/role_providers.dart';
import '../data/photo_upload_repository.dart';
import '_widgets/pro_photo_sheet.dart';
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
                  photoUrl: user?.photoUrl,
                ),
                const SizedBox(height: SphereSpacing.x32),

                const SphereSectionLabel('My account'),
                const SizedBox(height: SphereSpacing.x12),
                ProfileSectionCard(
                  children: [
                    ProfileRow(
                      icon: LucideIcons.userPen,
                      label: 'Edit profile',
                      onTap: () => GoRouter.of(context).push('/profile/edit'),
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
                      icon: LucideIcons.idCard,
                      label: 'My Player Card',
                      onTap: () => GoRouter.of(context).push('/player-card'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.searchCheck,
                      label: 'Scout Profile',
                      onTap: () => GoRouter.of(context).push('/scout'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.activity,
                      label: 'Body composition',
                      onTap: () => GoRouter.of(context)
                          .push('/profile/body-composition'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.shield,
                      label: 'My Club',
                      onTap: () => GoRouter.of(context).push('/club'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.arrowRightLeft,
                      label: 'Switch club',
                      onTap: () => SwitchClubSheet.show(context),
                    ),
                    ProfileRow(
                      icon: LucideIcons.bell,
                      label: 'Notifications',
                      onTap: () => GoRouter.of(context).push('/profile/notifications'),
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
                      onTap: () => GoRouter.of(context).push('/profile/theme'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.languages,
                      label: 'Language',
                      trailingText: 'EN',
                      onTap: () => GoRouter.of(context).push('/profile/language'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.circleHelp,
                      label: 'Help and FAQ',
                      onTap: () => GoRouter.of(context).push('/profile/help'),
                    ),
                    ProfileRow(
                      icon: LucideIcons.info,
                      label: 'About',
                      onTap: () => GoRouter.of(context).push('/profile/about'),
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
                          color: context.sc.onSurfaceMuted,
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

class _IdentityCard extends ConsumerStatefulWidget {
  const _IdentityCard({
    required this.displayName,
    required this.email,
    required this.initials,
    required this.roleLabel,
    this.photoUrl,
  });

  final String displayName;
  final String email;
  final String initials;
  final String roleLabel;
  final String? photoUrl;

  @override
  ConsumerState<_IdentityCard> createState() => _IdentityCardState();
}

class _IdentityCardState extends ConsumerState<_IdentityCard> {
  bool _uploading = false;

  Future<void> _pickAndUpload(bool fromCamera) async {
    final repo = ref.read(photoUploadRepositoryProvider);
    final file = await repo.pickPhoto(fromCamera: fromCamera);
    if (file == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final result = await repo.uploadWithBgRemoval(file);
      if (mounted) {
        ref.invalidate(currentUserProvider);
        final msg = result.bgRemoved
            ? 'Photo updated — background removed automatically'
            : 'Photo updated';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(msg)),
              ],
            ),
            backgroundColor: context.sc.primary,
          ),
        );
      }
    } on PhotoValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo rejected: ${e.reason}'),
            backgroundColor: context.sc.danger,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: context.sc.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.sc.surfaceElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.sc.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'AI will validate your photo and automatically remove the background.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.sc.onSurfaceMuted),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(LucideIcons.camera, color: context.sc.onSurface),
              title: Text('Take photo', style: TextStyle(color: context.sc.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(true);
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.image, color: context.sc.onSurface),
              title: Text('Choose from gallery', style: TextStyle(color: context.sc.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(false);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _showProPhotoSheet() async {
    final adopted = await ProPhotoSheet.show(context);
    if (adopted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Pro photo set as your profile picture!'),
            ],
          ),
          backgroundColor: context.sc.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlayer = ref.watch(selectedRoleProvider) == AppRole.player;
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.sc.surfaceElev1,
            context.sc.primary.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
        children: [
          GestureDetector(
            onTap: _showPhotoOptions,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.sc.primary.withValues(alpha: 0.18),
                      border: Border.all(
                        color: context.sc.primary.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: widget.photoUrl != null && !_uploading
                        ? ClipOval(
                            child: Image.network(
                              widget.photoUrl!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => Text(
                                widget.initials,
                                style: TextStyle(
                                  color: context.sc.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        : _uploading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(context.sc.primary),
                                ),
                              )
                            : Text(
                                widget.initials,
                                style: TextStyle(
                                  color: context.sc.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                  ),
                  if (!_uploading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.sc.primary,
                          border: Border.all(
                            color: context.sc.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.pencil,
                          size: 10,
                          color: context.sc.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: SphereSpacing.x16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.sc.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.sc.primary.withValues(alpha: 0.18),
                    borderRadius: SphereRadius.pillRect,
                    border: Border.all(
                      color: context.sc.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    widget.roleLabel.toUpperCase(),
                    style: TextStyle(
                      color: context.sc.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (widget.email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
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
          if (isPlayer && !_uploading) ...[
            const SizedBox(height: SphereSpacing.x12),
            GestureDetector(
              onTap: _showProPhotoSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.sc.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.sc.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 14, color: context.sc.primary),
                    SizedBox(width: 6),
                    Text(
                      'Generate AI Pro Photo',
                      style: TextStyle(
                        color: context.sc.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      color: context.sc.surfaceElev1,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(11),
          child: Icon(LucideIcons.bell, size: 20, color: context.sc.onSurface),
        ),
      ),
    );
  }
}
