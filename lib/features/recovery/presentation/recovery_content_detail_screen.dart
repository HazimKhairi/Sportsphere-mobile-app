import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../data/recovery_repository.dart';
import '../domain/recovery_content.dart';

class RecoveryContentDetailScreen extends StatelessWidget {
  const RecoveryContentDetailScreen({super.key, required this.contentId});
  final String contentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<RecoveryContent?>(
        future: RecoveryRepository()
            .contentStream()
            .first
            .then((list) => list.where((c) => c.id == contentId).firstOrNull),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final content = snap.data;
          if (content == null) {
            return const Center(child: Text('Content not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24, SphereSpacing.x8,
              SphereSpacing.x24, SphereSpacing.bottomNavSafe,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(content.evidenceLevel),
                    const SizedBox(width: SphereSpacing.x8),
                    _Badge(content.sportContext),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x16),
                Text(
                  content.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x4),
                Text(
                  '${content.durationMinutes} min',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x24),
                for (var i = 0; i < content.steps.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0x268B5CF6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Expanded(
                        child: Text(
                          content.steps[i],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x12),
                ],
                if (content.youtubeUrl != null) ...[
                  const SizedBox(height: SphereSpacing.x16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(content.youtubeUrl!);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                      icon: const Icon(LucideIcons.play, size: 16),
                      label: Text(AppLocalizations.of(context)!.watchVideoGuide),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: const BorderSide(color: Color(0xFF8B5CF6)),
                        shape: const RoundedRectangleBorder(
                          borderRadius: SphereRadius.pillRect,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: SphereSpacing.x24),
                Text(
                  'For general sporting guidance only. Not a substitute for professional advice.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase().replaceAll('_', ' '),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8B5CF6),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
