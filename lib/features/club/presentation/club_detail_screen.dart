import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/club_info.dart';
import 'club_providers.dart';

class ClubDetailScreen extends ConsumerWidget {
  const ClubDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(myClubProvider);

    return Scaffold(
      backgroundColor: context.sc.surface,
      body: clubAsync.when(
        data: (ClubInfo? club) {
          if (club == null) {
            return _ErrorView(onRetry: () => ref.invalidate(myClubProvider));
          }
          return _ClubContent(club: club);
        },
        loading: () => Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(context.sc.primary),
            ),
          ),
        ),
        error: (_, s) => _ErrorView(
          onRetry: () => ref.invalidate(myClubProvider),
        ),
      ),
    );
  }
}

class _ClubContent extends StatelessWidget {
  const _ClubContent({required this.club});

  final ClubInfo club;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SphereHeroGradient(height: 240),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SphereSpacing.x16),
            child: _CircleIconButton(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 64,
              left: SphereSpacing.x16,
              right: SphereSpacing.x16,
              bottom: SphereSpacing.x32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: SphereSpacing.x24),
                _ClubHeader(club: club),
                const SizedBox(height: SphereSpacing.x24),
                if (club.description != null &&
                    club.description!.isNotEmpty) ...[
                  _DescriptionCard(description: club.description!),
                  const SizedBox(height: SphereSpacing.x24),
                ],
                _ContactSection(club: club),
                if (club.enabledSports.isNotEmpty) ...[
                  const SizedBox(height: SphereSpacing.x24),
                  _SportsSection(sports: club.enabledSports),
                ],
                if (club.certifications.isNotEmpty) ...[
                  const SizedBox(height: SphereSpacing.x24),
                  _CertificationsSection(certifications: club.certifications),
                ],
                if (_hasSocial(club.storefront)) ...[
                  const SizedBox(height: SphereSpacing.x24),
                  _SocialSection(storefront: club.storefront!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _hasSocial(ClubStorefront? sf) {
    if (sf == null) return false;
    return sf.instagramUrl != null ||
        sf.facebookUrl != null ||
        sf.tiktokUrl != null;
  }
}

class _ClubHeader extends StatelessWidget {
  const _ClubHeader({required this.club});

  final ClubInfo club;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ClubLogo(logoUrl: club.logoUrl, name: club.name),
        const SizedBox(height: SphereSpacing.x12),
        Text(
          club.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: context.sc.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (club.sport != null) ...[
          const SizedBox(height: SphereSpacing.x8),
          _SportPill(sport: club.sport!),
        ],
      ],
    );
  }
}

class _ClubLogo extends StatelessWidget {
  const _ClubLogo({required this.logoUrl, required this.name});

  final String? logoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial =
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.sc.surfaceElev1,
        border: Border.all(color: context.sc.borderSubtle, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? Image.network(
              logoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => _Initials(initial: initial),
            )
          : _Initials(initial: initial),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: context.sc.primary,
          fontWeight: FontWeight.w800,
          fontSize: 30,
        ),
      ),
    );
  }
}

class _SportPill extends StatelessWidget {
  const _SportPill({required this.sport});

  final String sport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.sc.primary.withValues(alpha: 0.12),
        borderRadius: SphereRadius.pillRect,
        border:
            Border.all(color: context.sc.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        sport,
        style: TextStyle(
          color: context.sc.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SphereSpacing.x16,
        vertical: SphereSpacing.x16,
      ),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.sc.onSurfaceMuted,
              height: 1.5,
            ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.club});

  final ClubInfo club;

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[
      if (club.address != null)
        _InfoRow(icon: LucideIcons.mapPin, text: club.address!),
      if (club.phone != null)
        _InfoRow(icon: LucideIcons.phone, text: club.phone!),
      if (club.email != null)
        _InfoRow(icon: LucideIcons.mail, text: club.email!),
      if (club.website != null)
        _InfoRow(icon: LucideIcons.globe, text: club.website!),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SphereSectionLabel('Contact'),
        const SizedBox(height: SphereSpacing.x12),
        _InfoCard(rows: rows),
      ],
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x16, vertical: 8),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(rows[i].icon,
                      size: 20, color: context.sc.onSurfaceMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rows[i].text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.sc.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(color: context.sc.borderSubtle, height: 1),
          ],
        ],
      ),
    );
  }
}

class _SportsSection extends StatelessWidget {
  const _SportsSection({required this.sports});

  final List<String> sports;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SphereSectionLabel('Sports Offered'),
        const SizedBox(height: SphereSpacing.x12),
        Wrap(
          spacing: SphereSpacing.x8,
          runSpacing: SphereSpacing.x8,
          children: sports.map((s) => _SportChip(label: s)).toList(),
        ),
      ],
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _CertificationsSection extends StatelessWidget {
  const _CertificationsSection({required this.certifications});

  final List<String> certifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SphereSectionLabel('Club Certifications'),
        const SizedBox(height: SphereSpacing.x12),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SphereSpacing.x16, vertical: 8),
          decoration: BoxDecoration(
            color: context.sc.surfaceElev1,
            borderRadius: SphereRadius.cardRect,
            border: Border.all(color: context.sc.borderSubtle),
          ),
          child: Column(
            children: [
              for (var i = 0; i < certifications.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(LucideIcons.shieldCheck,
                          size: 20, color: context.sc.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          certifications[i],
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.sc.onSurface,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < certifications.length - 1)
                  Divider(color: context.sc.borderSubtle, height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({required this.storefront});

  final ClubStorefront storefront;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SphereSectionLabel('Social Media'),
        const SizedBox(height: SphereSpacing.x12),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SphereSpacing.x16, vertical: 8),
          decoration: BoxDecoration(
            color: context.sc.surfaceElev1,
            borderRadius: SphereRadius.cardRect,
            border: Border.all(color: context.sc.borderSubtle),
          ),
          child: Column(
            children: [
              if (storefront.instagramUrl != null) ...[
                _SocialRow(
                  icon: LucideIcons.link,
                  platform: 'Instagram',
                  url: storefront.instagramUrl!,
                ),
              ],
              if (storefront.instagramUrl != null &&
                  (storefront.facebookUrl != null ||
                      storefront.tiktokUrl != null))
                Divider(color: context.sc.borderSubtle, height: 1),
              if (storefront.facebookUrl != null) ...[
                _SocialRow(
                  icon: LucideIcons.link,
                  platform: 'Facebook',
                  url: storefront.facebookUrl!,
                ),
              ],
              if (storefront.facebookUrl != null &&
                  storefront.tiktokUrl != null)
                Divider(color: context.sc.borderSubtle, height: 1),
              if (storefront.tiktokUrl != null)
                _SocialRow(
                  icon: LucideIcons.music,
                  platform: 'TikTok',
                  url: storefront.tiktokUrl!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.icon,
    required this.platform,
    required this.url,
  });

  final IconData icon;
  final String platform;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.sc.onSurfaceMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  url,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Icon(LucideIcons.chevronLeft,
              size: 20, color: context.sc.onSurface),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SphereSpacing.x32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load club info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.sc.onSurface,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
