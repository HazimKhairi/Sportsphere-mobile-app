import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../../player_card/presentation/player_card_providers.dart';
import '../../role_pick/presentation/role_providers.dart';
import '../data/photo_upload_repository.dart';
import '_widgets/pro_photo_sheet.dart';
import '_widgets/profile_row.dart';
import '_widgets/profile_section_card.dart';
import '_widgets/sign_out_dialog.dart';
import 'sign_out_flow.dart';

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
    final authDisplayName = ref.watch(userDisplayNameProvider).valueOrNull
        ?? (role == AppRole.staff ? 'Coach' : 'Player');
    final cardAsync = ref.watch(playerCardProvider);
    final displayName = (role == AppRole.player
            ? cardAsync.valueOrNull?.card.playerName
            : null) ??
        authDisplayName;
    final firstName = displayName.split(' ').first;
    final email = user?.email ?? '';
    final l = AppLocalizations.of(context)!;
    final roleLabel = role == AppRole.staff ? l.staff : l.player;
    final isPlayer = role == AppRole.player;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SphereSpacing.x24,
          SphereSpacing.x16,
          SphereSpacing.x24,
          SphereSpacing.bottomNavSafe,
        ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ──────────────────────────────────────────────────
                SphereEntrance(
                  delayMs: 0,
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.profile,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const Spacer(),
                      _IconBtn(
                        icon: LucideIcons.settings,
                        onTap: () => context.push('/profile/notifications'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                // ── Avatar hero (centered) ────────────────────────────────────
                SphereEntrance(
                  delayMs: 60,
                  child: Center(child: _AvatarHero(
                    displayName: displayName,
                    firstName: firstName,
                    email: email,
                    initials: _initialsFrom(displayName),
                    roleLabel: roleLabel,
                    photoUrl: user?.photoUrl,
                    isPlayer: isPlayer,
                  )),
                ),
                const SizedBox(height: SphereSpacing.x32),

                // ── Quick action 2-col grid ───────────────────────────────────
                SphereEntrance(
                  delayMs: 120,
                  child: isPlayer
                      ? _PlayerQuickGrid()
                      : _StaffQuickGrid(),
                ),
                const SizedBox(height: SphereSpacing.x32),

                // ── Account section ───────────────────────────────────────────
                SphereEntrance(
                  delayMs: 180,
                  child: SphereSectionLabel(AppLocalizations.of(context)!.account),
                ),
                const SizedBox(height: SphereSpacing.x12),
                SphereEntrance(
                  delayMs: 200,
                  child: ProfileSectionCard(
                    children: [
                      ProfileRow(
                        icon: LucideIcons.userPen,
                        label: AppLocalizations.of(context)!.editProfile,
                        subtitle: AppLocalizations.of(context)!.updateYourDetails,
                        onTap: () => context.push('/profile/edit'),
                      ),
                      if (isPlayer) ...[
                        ProfileRow(
                          icon: LucideIcons.layoutGrid,
                          label: 'Browse programs',
                          subtitle: 'Enrol in training programs',
                          onTap: () => context.push('/programs'),
                        ),
                        ProfileRow(
                          icon: LucideIcons.receipt,
                          label: AppLocalizations.of(context)!.paymentHistory,
                          subtitle: AppLocalizations.of(context)!.viewYourTransactions,
                          onTap: () => context.push('/profile/payments'),
                        ),
                        ProfileRow(
                          icon: LucideIcons.activity,
                          label: 'Body composition',
                          subtitle: 'Monitor your physique progress',
                          onTap: () => context.push('/profile/body-composition'),
                        ),
                      ],
                      ProfileRow(
                        icon: LucideIcons.shield,
                        label: AppLocalizations.of(context)!.myClub,
                        subtitle: AppLocalizations.of(context)!.viewClubDetails,
                        onTap: () => context.push('/club'),
                      ),
                      ProfileRow(
                        icon: LucideIcons.bell,
                        label: AppLocalizations.of(context)!.notifications,
                        subtitle: AppLocalizations.of(context)!.manageAlerts,
                        onTap: () => context.push('/profile/notifications'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x24),

                // ── App section ───────────────────────────────────────────────
                SphereEntrance(
                  delayMs: 260,
                  child: SphereSectionLabel(AppLocalizations.of(context)!.app),
                ),
                const SizedBox(height: SphereSpacing.x12),
                SphereEntrance(
                  delayMs: 280,
                  child: ProfileSectionCard(
                    children: [
                      ProfileRow(
                        icon: LucideIcons.palette,
                        label: AppLocalizations.of(context)!.theme,
                        subtitle: 'Dark / Light mode',
                        trailingText: 'Dark',
                        onTap: () => context.push('/profile/theme'),
                      ),
                      ProfileRow(
                        icon: LucideIcons.languages,
                        label: AppLocalizations.of(context)!.language,
                        subtitle: AppLocalizations.of(context)!.appDisplayLanguage,
                        trailingText: 'EN',
                        onTap: () => context.push('/profile/language'),
                      ),
                      ProfileRow(
                        icon: LucideIcons.circleHelp,
                        label: AppLocalizations.of(context)!.help,
                        subtitle: 'Get support or browse answers',
                        onTap: () => context.push('/profile/help'),
                      ),
                      ProfileRow(
                        icon: LucideIcons.info,
                        label: 'About',
                        subtitle: AppLocalizations.of(context)!.versionInfo,
                        onTap: () => context.push('/profile/about'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x24),

                // ── Sign out ──────────────────────────────────────────────────
                SphereEntrance(
                  delayMs: 320,
                  child: ProfileSectionCard(
                    children: [
                      ProfileRow(
                        icon: LucideIcons.logOut,
                        label: AppLocalizations.of(context)!.signOut,
                        danger: true,
                        onTap: () => _confirmSignOut(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x24),

                Center(
                  child: Text(
                    'v1.0.0+1 · SportSphere',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
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

// ── Avatar hero section ────────────────────────────────────────────────────────

class _AvatarHero extends ConsumerStatefulWidget {
  const _AvatarHero({
    required this.displayName,
    required this.firstName,
    required this.email,
    required this.initials,
    required this.roleLabel,
    required this.isPlayer,
    this.photoUrl,
  });

  final String displayName;
  final String firstName;
  final String email;
  final String initials;
  final String roleLabel;
  final bool isPlayer;
  final String? photoUrl;

  @override
  ConsumerState<_AvatarHero> createState() => _AvatarHeroState();
}

class _AvatarHeroState extends ConsumerState<_AvatarHero> {
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
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ]),
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
              title: Text(AppLocalizations.of(context)!.takePhoto, style: TextStyle(color: context.sc.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(true);
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.image, color: context.sc.onSurface),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery, style: TextStyle(color: context.sc.onSurface)),
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
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text('Pro photo set as your profile picture!'),
          ]),
          backgroundColor: context.sc.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        GestureDetector(
          onTap: _showPhotoOptions,
          child: SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.sc.primary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: context.sc.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: widget.photoUrl != null && !_uploading
                      ? ClipOval(
                          child: Image.network(
                            widget.photoUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, e, __) => Text(
                              widget.initials,
                              style: TextStyle(
                                color: context.sc.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                      : _uploading
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(context.sc.primary),
                              ),
                            )
                          : Text(
                              widget.initials,
                              style: TextStyle(
                                color: context.sc.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                ),
                if (!_uploading)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.sc.primary,
                        border: Border.all(color: context.sc.surface, width: 2),
                      ),
                      child: Icon(
                        LucideIcons.pencil,
                        size: 12,
                        color: context.sc.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SphereSpacing.x16),

        // Name greeting
        Text(
          'Hello, ${widget.firstName}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.sc.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        if (widget.email.isNotEmpty) ...[
          const SizedBox(height: SphereSpacing.x4),
          Text(
            widget.email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: SphereSpacing.x12),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x12, vertical: 4),
          decoration: BoxDecoration(
            color: context.sc.primary.withValues(alpha: 0.15),
            borderRadius: SphereRadius.pillRect,
            border: Border.all(color: context.sc.primary.withValues(alpha: 0.4)),
          ),
          child: Text(
            widget.roleLabel.toUpperCase(),
            style: TextStyle(
              color: context.sc.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // AI Pro photo button (player only)
        if (widget.isPlayer && !_uploading) ...[
          const SizedBox(height: SphereSpacing.x16),
          GestureDetector(
            onTap: _showProPhotoSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x16,
                vertical: SphereSpacing.x8,
              ),
              decoration: BoxDecoration(
                color: context.sc.primary.withValues(alpha: 0.08),
                borderRadius: SphereRadius.pillRect,
                border: Border.all(color: context.sc.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.sparkles, size: 14, color: context.sc.primary),
                  const SizedBox(width: 6),
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
    );
  }
}

// ── Quick action grids ─────────────────────────────────────────────────────────

class _PlayerQuickGrid extends StatelessWidget {
  const _PlayerQuickGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCard(
            badge: 'MY',
            icon: LucideIcons.idCard,
            accentColor: context.sc.primary,
            title: AppLocalizations.of(context)!.playerCard,
            subtitle: AppLocalizations.of(context)!.viewYourDigitalId,
            onTap: () => context.push('/player-card'),
          ),
        ),
        const SizedBox(width: SphereSpacing.x12),
        Expanded(
          child: _QuickCard(
            badge: 'NEW',
            icon: LucideIcons.award,
            accentColor: const Color(0xFFF59E0B),
            title: AppLocalizations.of(context)!.achievements,
            subtitle: AppLocalizations.of(context)!.trackMilestones,
            onTap: () => context.push('/profile/achievements'),
          ),
        ),
      ],
    );
  }
}

class _StaffQuickGrid extends StatelessWidget {
  const _StaffQuickGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCard(
            badge: 'TEAM',
            icon: LucideIcons.users,
            accentColor: context.sc.primary,
            title: AppLocalizations.of(context)!.roster,
            subtitle: AppLocalizations.of(context)!.viewAndManagePlayers,
            onTap: () => context.push('/staff/roster'),
          ),
        ),
        const SizedBox(width: SphereSpacing.x12),
        Expanded(
          child: _QuickCard(
            badge: 'PLAN',
            icon: LucideIcons.dumbbell,
            accentColor: const Color(0xFFF97316),
            title: AppLocalizations.of(context)!.training,
            subtitle: AppLocalizations.of(context)!.manageWorkouts,
            onTap: () => context.push('/staff/training'),
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.badge,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String badge;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: SphereRadius.pillRect,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(icon, size: 18, color: accentColor),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.sc.onSurface,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                    fontSize: 10,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: context.sc.onSurface),
    );
  }
}
