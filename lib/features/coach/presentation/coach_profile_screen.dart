import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/coach_profile.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key, required this.coach});

  final CoachProfile coach;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: Stack(
        children: [
          _Header(coach: coach),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SphereSpacing.x16),
              child: _CircleIconButton(
                icon: LucideIcons.chevronLeft,
                onTap: () => _back(context),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameBadge(coach: coach),
                  const SizedBox(height: SphereSpacing.x24),
                  if (coach.bio != null && coach.bio!.isNotEmpty) ...[
                    _BioCard(bio: coach.bio!),
                    const SizedBox(height: SphereSpacing.x24),
                  ],
                  const SphereSectionLabel('Experience'),
                  const SizedBox(height: SphereSpacing.x12),
                  _ExperienceRows(coach: coach),
                  if (coach.specialties.isNotEmpty) ...[
                    const SizedBox(height: SphereSpacing.x24),
                    const SphereSectionLabel('Specialties'),
                    const SizedBox(height: SphereSpacing.x12),
                    _ChipWrap(items: coach.specialties),
                  ],
                  if (coach.ageGroups.isNotEmpty) ...[
                    const SizedBox(height: SphereSpacing.x24),
                    const SphereSectionLabel('Age Groups'),
                    const SizedBox(height: SphereSpacing.x12),
                    _ChipWrap(items: coach.ageGroups),
                  ],
                  if (coach.languages.isNotEmpty) ...[
                    const SizedBox(height: SphereSpacing.x24),
                    const SphereSectionLabel('Languages'),
                    const SizedBox(height: SphereSpacing.x12),
                    _ChipWrap(items: coach.languages),
                  ],
                  if (coach.previousClubs.isNotEmpty) ...[
                    const SizedBox(height: SphereSpacing.x24),
                    const SphereSectionLabel('Previous Clubs'),
                    const SizedBox(height: SphereSpacing.x12),
                    _PreviousClubsList(clubs: coach.previousClubs),
                  ],
                  if (coach.philosophy != null && coach.philosophy!.isNotEmpty) ...[
                    const SizedBox(height: SphereSpacing.x24),
                    const SphereSectionLabel('Coaching Philosophy'),
                    const SizedBox(height: SphereSpacing.x12),
                    _PhilosophyCard(philosophy: coach.philosophy!),
                  ],
                  if (coach.achievements.isNotEmpty) ...[
                    const SizedBox(height: SphereSpacing.x24),
                    const SphereSectionLabel('Achievements & Certifications'),
                    const SizedBox(height: SphereSpacing.x12),
                    _AchievementsList(achievements: coach.achievements),
                  ],
                  const SizedBox(height: SphereSpacing.x32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.coach});

  final CoachProfile coach;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF064E24), Color(0xFF0F172A)],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  SphereColors.surface.withValues(alpha: 0.0),
                  SphereColors.surface,
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
          Center(
            child: _CoachAvatar(coach: coach, radius: 40),
          ),
        ],
      ),
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  const _CoachAvatar({required this.coach, required this.radius});

  final CoachProfile coach;
  final double radius;

  String get _initials {
    final parts = coach.name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = coach.photoUrl != null && coach.photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: SphereColors.primary,
      backgroundImage: hasPhoto ? NetworkImage(coach.photoUrl!) : null,
      onBackgroundImageError: hasPhoto
          ? (err, stack) {}
          : null,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w700,
                color: SphereColors.onPrimary,
              ),
            ),
    );
  }
}

class _NameBadge extends StatelessWidget {
  const _NameBadge({required this.coach});

  final CoachProfile coach;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: SphereSpacing.x8),
        SizedBox(
          width: double.infinity,
          child: Text(
            coach.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SphereColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: SphereSpacing.x8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: SphereColors.primary.withValues(alpha: 0.15),
            borderRadius: SphereRadius.pillRect,
            border: Border.all(color: SphereColors.primary.withValues(alpha: 0.4)),
          ),
          child: Text(
            coach.role,
            style: const TextStyle(
              color: SphereColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _BioCard extends StatelessWidget {
  const _BioCard({required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Text(
        bio,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SphereColors.onSurfaceMuted,
              height: 1.5,
            ),
      ),
    );
  }
}

class _ExperienceRows extends StatelessWidget {
  const _ExperienceRows({required this.coach});

  final CoachProfile coach;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      if (coach.yearsExperience != null)
        ('Years Coaching', '${coach.yearsExperience} years'),
      ('Certifications', '${coach.certificationsCount} on file'),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x16,
                vertical: SphereSpacing.x12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].$1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                  ),
                  Text(
                    rows[i].$2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(
                color: SphereColors.borderSubtle,
                height: 1,
                indent: SphereSpacing.x16,
                endIndent: SphereSpacing.x16,
              ),
          ],
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SphereSpacing.x8,
      runSpacing: SphereSpacing.x8,
      children: items
          .map(
            (item) => Chip(
              label: Text(item),
              backgroundColor: SphereColors.surfaceElev1,
              side: const BorderSide(color: SphereColors.borderSubtle),
              labelStyle: const TextStyle(
                fontSize: 12,
                color: SphereColors.onSurface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );
  }
}

class _PreviousClubsList extends StatelessWidget {
  const _PreviousClubsList({required this.clubs});

  final List<String> clubs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < clubs.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x16,
                vertical: SphereSpacing.x12,
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.shield,
                    size: 16,
                    color: SphereColors.onSurfaceMuted,
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Expanded(
                    child: Text(
                      clubs[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < clubs.length - 1)
              const Divider(
                color: SphereColors.borderSubtle,
                height: 1,
                indent: SphereSpacing.x16,
                endIndent: SphereSpacing.x16,
              ),
          ],
        ],
      ),
    );
  }
}

class _PhilosophyCard extends StatelessWidget {
  const _PhilosophyCard({required this.philosophy});

  final String philosophy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.quote,
            size: 18,
            color: SphereColors.onSurfaceSubtle,
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Text(
              philosophy,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsList extends StatelessWidget {
  const _AchievementsList({required this.achievements});

  final List<String> achievements;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < achievements.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x16,
                vertical: SphereSpacing.x12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.medal,
                    size: 16,
                    color: SphereColors.accentAmber,
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Expanded(
                    child: Text(
                      achievements[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < achievements.length - 1)
              const Divider(
                color: SphereColors.borderSubtle,
                height: 1,
                indent: SphereSpacing.x16,
                endIndent: SphereSpacing.x16,
              ),
          ],
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SphereColors.surfaceElev1.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: SphereColors.onSurface),
        ),
      ),
    );
  }
}
