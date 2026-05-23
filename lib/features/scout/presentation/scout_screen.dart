import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../domain/scouting_profile.dart';
import 'scout_providers.dart';

class ScoutScreen extends ConsumerWidget {
  const ScoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scoutProfileNotifierProvider);

    return Scaffold(
      backgroundColor: SphereColors.background,
      appBar: AppBar(
        title: const Text('Scout Profile'),
        actions: [
          state.whenOrNull(
            data: (profile) => profile != null
                ? IconButton(
                    icon: const Icon(LucideIcons.pencil),
                    tooltip: 'Edit',
                    onPressed: () => context.push('/scout/edit'),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e.toString(), onRetry: () => ref.invalidate(scoutProfileNotifierProvider)),
        data: (profile) => profile == null
            ? _EmptyState(onCreate: () => context.push('/scout/edit'))
            : _ProfileView(profile: profile),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: SphereColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.searchCheck, size: 44, color: SphereColors.primary),
            ),
            const SizedBox(height: 24),
            Text('Get Discovered', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Create your scouting profile so clubs and coaches can find you. You control when you\'re visible.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: SphereColors.onSurfaceMuted),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create Scout Profile'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(220, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.lock, size: 14, color: SphereColors.onSurfaceMuted),
                const SizedBox(width: 6),
                Text(
                  'Hidden by default — you decide when to go live',
                  style: tt.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileView extends ConsumerWidget {
  const _ProfileView({required this.profile});
  final ScoutingProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => ref.read(scoutProfileNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroCard(profile: profile)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _VisibilityToggle(profile: profile),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (profile.skills.isNotEmpty)
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Skills',
                icon: LucideIcons.zap,
                child: _SkillsGrid(skills: profile.skills),
              ),
            ),
          SliverToBoxAdapter(
            child: _SectionCard(
              title: 'Availability',
              icon: LucideIcons.clock,
              child: _AvailabilityRow(availability: profile.availability),
            ),
          ),
          if (profile.pastClubs.isNotEmpty)
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Past Clubs',
                icon: LucideIcons.building2,
                child: _PastClubsList(clubs: profile.pastClubs),
              ),
            ),
          if ((profile.achievements ?? '').isNotEmpty)
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Achievements',
                icon: LucideIcons.trophy,
                child: Text(profile.achievements!, style: tt.bodyMedium),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});
  final ScoutingProfile profile;

  String get _ageStr {
    try {
      final dob = DateTime.parse(profile.dob);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
      return '$age';
    } catch (_) {
      return '–';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final levelLabel = kScoutingLevelLabels[profile.level] ?? profile.level;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SphereColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(photoUrl: profile.photoUrl, name: profile.displayName),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.displayName,
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.primaryPosition} · Age $_ageStr · ${profile.state}',
                      style: tt.bodyMedium?.copyWith(color: SphereColors.onSurfaceMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(label: levelLabel, color: SphereColors.accentBluePastel, textColor: SphereColors.accentBlue),
                        const SizedBox(width: 8),
                        _Chip(
                          label: profile.isFreeAgent
                              ? 'Free Agent'
                              : profile.affiliation.clubName ?? 'Club',
                          color: profile.isFreeAgent
                              ? SphereColors.successLight
                              : SphereColors.accentAmberPastel,
                          textColor: profile.isFreeAgent
                              ? SphereColors.primary
                              : SphereColors.accentAmber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile.secondaryPositions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Alt positions:', style: tt.bodySmall),
                const SizedBox(width: 8),
                ...profile.secondaryPositions.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _Chip(label: p, color: SphereColors.surfaceElev1, textColor: SphereColors.onSurfaceMuted),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.photoUrl, required this.name});
  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SphereColors.primaryLight,
        border: Border.all(color: SphereColors.borderSubtle, width: 2),
        image: photoUrl != null
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: photoUrl == null
          ? Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: SphereColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.textColor});
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

class _VisibilityToggle extends ConsumerWidget {
  const _VisibilityToggle({required this.profile});
  final ScoutingProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final isOpen = profile.isOpen;
    final isLoading = ref.watch(scoutProfileNotifierProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOpen ? SphereColors.primaryLight : SphereColors.surfaceElev1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? SphereColors.primary.withAlpha(80) : SphereColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? LucideIcons.eye : LucideIcons.eyeOff,
            color: isOpen ? SphereColors.primary : SphereColors.onSurfaceMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Visible to clubs' : 'Hidden from clubs',
                  style: tt.titleMedium?.copyWith(
                    color: isOpen ? SphereColors.primary : SphereColors.onSurface,
                  ),
                ),
                Text(
                  isOpen
                      ? 'Your card is live — clubs can find you'
                      : 'Turn on to be discoverable by clubs',
                  style: tt.bodySmall,
                ),
              ],
            ),
          ),
          isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: isOpen,
                  activeThumbColor: SphereColors.primary,
                  onChanged: (_) =>
                      ref.read(scoutProfileNotifierProvider.notifier).toggleVisibility(),
                ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SphereColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: SphereColors.onSurfaceMuted),
              const SizedBox(width: 8),
              Text(title,
                  style: tt.labelLarge?.copyWith(color: SphereColors.onSurfaceMuted)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SkillsGrid extends StatelessWidget {
  const _SkillsGrid({required this.skills});
  final Map<String, double> skills;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: skills.entries.map((e) {
        final pct = (e.value / 5).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _capitalize(e.key),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: SphereColors.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: SphereColors.surfaceElev1,
                    color: SphereColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${e.value.round()}/5',
                style: const TextStyle(fontSize: 12, color: SphereColors.onSurfaceMuted),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow({required this.availability});
  final ScoutingAvailability availability;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (availability.weekday)
          _InfoChip(label: 'Weekdays', icon: LucideIcons.calendarDays),
        if (availability.weekend)
          _InfoChip(label: 'Weekends', icon: LucideIcons.calendarCheck),
        _InfoChip(
          label: '${availability.hoursPerWeek}h/week',
          icon: LucideIcons.clock,
        ),
        _InfoChip(
          label: '${availability.travelRadiusKm}km radius',
          icon: LucideIcons.mapPin,
        ),
        if (availability.paidTrialsAccepted)
          _InfoChip(label: 'Paid trials OK', icon: LucideIcons.circleCheck),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: SphereColors.onSurfaceMuted),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 12, color: SphereColors.onSurface)),
        ],
      ),
    );
  }
}

class _PastClubsList extends StatelessWidget {
  const _PastClubsList({required this.clubs});
  final List<PastClubEntry> clubs;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: clubs.map((club) {
        final yearStr = club.toYear != null
            ? '${club.fromYear} – ${club.toYear}'
            : '${club.fromYear} – present';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(LucideIcons.building2, size: 16, color: SphereColors.onSurfaceMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(club.name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(yearStr, style: tt.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.cloudOff, size: 48, color: SphereColors.onSurfaceMuted),
            const SizedBox(height: 16),
            Text('Could not load scout profile', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: SphereColors.onSurfaceMuted)),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
