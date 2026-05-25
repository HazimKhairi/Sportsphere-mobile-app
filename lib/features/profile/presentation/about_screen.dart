import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SphereFieldBackground(
      child: Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
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
                      Material(
                        color: context.sc.surfaceElev1,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => context.canPop()
                              ? context.pop()
                              : context.go('/profile'),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(LucideIcons.chevronLeft,
                                size: 20, color: context.sc.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Text(
                        AppLocalizations.of(context)!.about,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x32),
                  // Brand block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(SphereSpacing.x24),
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.sc.surfaceElev1,
                          context.sc.primary.withValues(alpha: 0.06),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/brand/sphere_wordmark.png',
                          height: 32,
                          fit: BoxFit.fitHeight,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.0 (build 1)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                  ),
                        ),
                        const SizedBox(height: SphereSpacing.x12),
                        Text(
                          'The all-in-one sports club management platform. Built for coaches and players to train smarter, pay easier, and grow together.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SphereSpacing.x24),
                  const SphereSectionLabel('App info'),
                  const SizedBox(height: SphereSpacing.x12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Version', value: '1.0.0'),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _InfoRow(label: 'Build', value: '1'),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _InfoRow(label: 'Platform', value: 'Flutter'),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _InfoRow(label: 'Released', value: '2026'),
                      ],
                    ),
                  ),
                  const SizedBox(height: SphereSpacing.x24),
                  SphereSectionLabel(AppLocalizations.of(context)!.legal),
                  const SizedBox(height: SphereSpacing.x12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _LinkRow(
                          icon: LucideIcons.fileText,
                          label: AppLocalizations.of(context)!.termsOfService,
                          onTap: () => _launch(
                              context, 'https://sprtsphr.app/terms'),
                        ),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _LinkRow(
                          icon: LucideIcons.shield,
                          label: AppLocalizations.of(context)!.privacyPolicy,
                          onTap: () => _launch(
                              context, 'https://sprtsphr.app/privacy'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SphereSpacing.x24),
                  Center(
                    child: Text(
                      '© 2026 SportSphere. All rights reserved.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SphereSpacing.x16,
        vertical: SphereSpacing.x12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.sc.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SphereSpacing.x16,
          vertical: SphereSpacing.x12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.sc.onSurfaceMuted),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 14, color: context.sc.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}
