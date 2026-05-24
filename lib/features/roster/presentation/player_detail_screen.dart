import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../data/roster_repository.dart';
import 'roster_providers.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final String playerId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/staff/roster');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      playerDetailProvider(playerId: playerId),
    );

    return detailAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.sc.surface,
        body: Center(
          child: CircularProgressIndicator(
            color: context.sc.primary,
          ),
        ),
      ),
      error: (_, e) => Scaffold(
        backgroundColor: context.sc.surface,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.userX,
                color: context.sc.onSurfaceMuted,
                size: 48,
              ),
              const SizedBox(height: SphereSpacing.x16),
              Text(
                AppLocalizations.of(context)!.playerNotFound,
                style: TextStyle(
                  color: context.sc.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SphereSpacing.x24),
              TextButton(
                onPressed: () => _back(context),
                child: Text(AppLocalizations.of(context)!.goBack),
              ),
            ],
          ),
        ),
      ),
      data: (player) => _PlayerDetailContent(
        player: player,
        onBack: () => _back(context),
      ),
    );
  }
}

class _PlayerDetailContent extends StatelessWidget {
  const _PlayerDetailContent({
    required this.player,
    required this.onBack,
  });

  final PlayerDetail player;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sc.surface,
      body: Stack(
        children: [
          // Hero gradient top
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: _GradientHeader(),
          ),
          // Back button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(SphereSpacing.x16),
                child: _BackButton(onPressed: onBack),
              ),
            ),
          ),
          // Main scrollable content (below fold)
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.sc.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Space for avatar overlap: avatar top=100, radius=72 → bottom=244, content top=140 → overlap=104px + gap
                    const SizedBox(height: 120),
                    // Name
                    Text(
                      player.fullName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: context.sc.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    // Jersey number
                    if (player.jerseyNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '#${player.jerseyNumber}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.sc.onSurfaceMuted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Availability badge
                    if (player.availability != null)
                      _AvailabilityBadge(status: player.availability!),
                    const SizedBox(height: 24),
                    // Position + team row
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.crosshair, size: 14, color: context.sc.onSurfaceMuted),
                            const SizedBox(width: 4),
                            Text(
                              player.position.isEmpty ? 'No position' : player.position,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.shield, size: 14, color: context.sc.onSurfaceMuted),
                            const SizedBox(width: 4),
                            Text(
                              player.teamName.isEmpty ? 'No team' : player.teamName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Contact card
                    _InfoCard(
                      title: 'CONTACT',
                      items: [
                        _InfoRow(
                          icon: LucideIcons.mail,
                          label: 'Email',
                          value: player.email.isEmpty ? '—' : player.email,
                        ),
                        _InfoRow(
                          icon: LucideIcons.phone,
                          label: 'Phone',
                          value: player.phone.isEmpty ? '—' : player.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Personal card
                    _InfoCard(
                      title: 'PERSONAL',
                      items: [
                        _InfoRow(
                          icon: LucideIcons.cake,
                          label: 'Date of birth',
                          value: player.dateOfBirth ?? '—',
                        ),
                      ],
                    ),
                    // Parent card (conditional)
                    if (player.parentName != null ||
                        player.parentPhone != null) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'PARENT / GUARDIAN',
                        items: [
                          if (player.parentName != null)
                            _InfoRow(
                              icon: LucideIcons.user,
                              label: 'Name',
                              value: player.parentName!,
                            ),
                          if (player.parentPhone != null)
                            _InfoRow(
                              icon: LucideIcons.phone,
                              label: 'Phone',
                              value: player.parentPhone!,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Avatar (centered, overlapping the fold at top=100)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: _Avatar(player: player),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.sc.primary.withValues(alpha: 0.1),
            context.sc.surface.withValues(alpha: 0.7),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.pillRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Icon(
          LucideIcons.arrowLeft,
          size: 18,
          color: context.sc.onSurface,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player});

  final PlayerDetail player;

  @override
  Widget build(BuildContext context) {
    final photoUrl = player.photoUrl;
    return CircleAvatar(
      radius: 72,
      backgroundColor: context.sc.primary.withValues(alpha: 0.18),
      foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(
              player.initials,
              style: TextStyle(
                color: context.sc.primary,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
            )
          : null,
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'injured' => ('Injured', const Color(0xFFEF4444)),
      'sick' => ('Sick', const Color(0xFFF59E0B)),
      'away' => ('Away', const Color(0xFF3B82F6)),
      _ => ('Unavailable', context.sc.onSurfaceMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.items});

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.sc.onSurfaceMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
