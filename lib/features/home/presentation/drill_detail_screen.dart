import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../data/drill_completion_repository.dart';
import '../domain/drill.dart';
import '../domain/drill_completion_result.dart';
import '_widgets/sphere_section_label.dart';
import 'drill_detail_providers.dart';

class DrillDetailScreen extends ConsumerWidget {
  const DrillDetailScreen({super.key, required this.drillId});
  final String drillId;

  /// Extract YouTube videoId from common URL shapes.
  /// - https://youtu.be/XXX
  /// - https://www.youtube.com/watch?v=XXX
  /// - https://youtube.com/watch?v=XXX
  /// - https://www.youtube.com/embed/XXX
  /// Returns null when URL is null/empty/unparseable.
  String? _youtubeId(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        if (uri.pathSegments.isNotEmpty) return uri.pathSegments.first;
      }
      if (uri.host.contains('youtube.com')) {
        final v = uri.queryParameters['v'];
        if (v != null && v.isNotEmpty) return v;
        // /embed/XXX or /shorts/XXX
        if (uri.pathSegments.length >= 2 &&
            (uri.pathSegments.first == 'embed' ||
                uri.pathSegments.first == 'shorts')) {
          return uri.pathSegments[1];
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _openYoutube(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube.')),
      );
    }
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/train');
    }
  }

  String _categoryLabel(String raw) {
    switch (raw) {
      case 'juggle':
        return 'Juggle';
      case 'toe_taps':
        return 'Toe taps';
      case 'back_vee':
        return 'Back-V';
      case 'tic_toc':
        return 'Tic-toc';
      case 'inside_outside':
        return 'Inside-outside';
      case 'sole_rolls':
        return 'Sole rolls';
      case '':
        return 'Drill';
      default:
        return raw
            .split('_')
            .map((p) => p.isEmpty
                ? p
                : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(drillDetailProvider(drillId: drillId));

    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: async.when(
        data: (drill) {
          if (drill == null) return _NotFound(onBack: () => _back(context));
          final videoId = _youtubeId(drill.youtubeUrl);
          return _Content(
            drill: drill,
            categoryLabel: _categoryLabel(drill.category),
            videoId: videoId,
            onBack: () => _back(context),
            onOpenYoutube: drill.youtubeUrl == null
                ? null
                : () => _openYoutube(context, drill.youtubeUrl!),
            onStartPractice: () =>
                context.push('/train/drill/${drill.id}/play'),
            onMarkComplete: () => ref
                .read(drillCompletionRepositoryProvider)
                .markComplete(drillId: drill.id),
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(SphereColors.primary),
            ),
          ),
        ),
        error: (_, _) => _NotFound(onBack: () => _back(context)),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({
    required this.drill,
    required this.categoryLabel,
    required this.videoId,
    required this.onBack,
    required this.onOpenYoutube,
    required this.onStartPractice,
    required this.onMarkComplete,
  });

  final Drill drill;
  final String categoryLabel;
  final String? videoId;
  final VoidCallback onBack;
  final VoidCallback? onOpenYoutube;
  final VoidCallback onStartPractice;
  final Future<DrillCompletionResult> Function() onMarkComplete;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool _completedToday = false;
  bool _marking = false;
  DrillCompletionResult? _result;

  Future<void> _handleMarkComplete() async {
    setState(() => _marking = true);
    try {
      final result = await widget.onMarkComplete();
      setState(() {
        _result = result;
        _completedToday = true;
        _marking = false;
      });
      if (mounted) _showCelebration(result);
    } on DrillAlreadyCompletedToday {
      setState(() {
        _completedToday = true;
        _marking = false;
      });
    } catch (e) {
      setState(() => _marking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not mark as watched. Try again.')),
        );
      }
    }
  }

  void _showCelebration(DrillCompletionResult result) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SphereColors.surfaceElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SphereColors.primary.withValues(alpha: 0.15),
                border: Border.all(
                    color: SphereColors.primary.withValues(alpha: 0.4)),
              ),
              child: const Icon(LucideIcons.checkCircle2,
                  color: SphereColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              '+${result.pointsEarned} pts',
              style: const TextStyle(
                color: SphereColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Drill watched. Keep it up!',
              style: TextStyle(
                  color: SphereColors.onSurfaceMuted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.flame,
                    size: 16, color: SphereColors.warning),
                const SizedBox(width: 4),
                Text(
                  '${result.currentStreak} day streak',
                  style: const TextStyle(
                    color: SphereColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (result.isNewBest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SphereColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Personal Best',
                      style: TextStyle(
                        color: SphereColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SphereColors.primary,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect),
                  elevation: 0,
                ),
                child: const Text('Continue',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hero (YouTube thumbnail or gradient placeholder)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 260,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.videoId != null)
                Image.network(
                  'https://img.youtube.com/vi/${widget.videoId}/maxresdefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _gradient(),
                )
              else
                _gradient(),
              // Gradient overlay so content below pops
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SphereColors.surface.withValues(alpha: 0.55),
                      Colors.transparent,
                      SphereColors.surface,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Play button overlay
              if (widget.videoId != null && widget.onOpenYoutube != null)
                Center(
                  child: Material(
                    color: SphereColors.primary,
                    shape: const CircleBorder(),
                    elevation: 6,
                    child: InkWell(
                      onTap: widget.onOpenYoutube,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(18),
                        child: Icon(
                          LucideIcons.play,
                          size: 28,
                          color: SphereColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Back button overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SphereSpacing.x16),
            child: _CircleIconButton(
              icon: LucideIcons.chevronLeft,
              onTap: widget.onBack,
            ),
          ),
        ),

        // Scrollable content — extra bottom padding for two buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 220),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 220),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(SphereSpacing.x20),
                    decoration: BoxDecoration(
                      color: SphereColors.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: SphereColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Pill(text: widget.categoryLabel),
                            _Pill(text: 'Level ${widget.drill.difficulty}'),
                          ],
                        ),
                        const SizedBox(height: SphereSpacing.x12),
                        Text(
                          widget.drill.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: SphereColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (widget.drill.description.isNotEmpty) ...[
                          const SizedBox(height: SphereSpacing.x12),
                          Text(
                            widget.drill.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: SphereColors.onSurfaceMuted,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (widget.drill.targetAttributes.isNotEmpty) ...[
                    const SizedBox(height: SphereSpacing.x24),
                    const SphereSectionLabel('Builds'),
                    const SizedBox(height: SphereSpacing.x12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final attr in widget.drill.targetAttributes)
                          _AttributeChip(
                            label: attr
                                .replaceAll('_', ' ')
                                .split(' ')
                                .map((w) => w.isEmpty
                                    ? w
                                    : '${w[0].toUpperCase()}${w.substring(1)}')
                                .join(' '),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // "Mark as watched" button (outline, above Start Practice)
        Positioned(
          left: SphereSpacing.x16,
          right: SphereSpacing.x16,
          bottom: 170,
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed:
                  _completedToday || _marking ? null : _handleMarkComplete,
              icon: _completedToday
                  ? const Icon(LucideIcons.checkCircle2,
                      size: 16, color: SphereColors.primary)
                  : _marking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                                SphereColors.primary),
                          ),
                        )
                      : const Icon(LucideIcons.eye, size: 16),
              label: Text(
                _completedToday
                    ? 'Watched (+${_result?.pointsEarned ?? 10} pts)'
                    : 'Mark as watched',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _completedToday
                    ? SphereColors.primary
                    : SphereColors.onSurface,
                side: BorderSide(
                  color: _completedToday
                      ? SphereColors.primary
                      : SphereColors.borderSubtle,
                ),
                shape: const RoundedRectangleBorder(
                    borderRadius: SphereRadius.pillRect),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        // "Start Practice" CTA (filled, below)
        Positioned(
          left: SphereSpacing.x16,
          right: SphereSpacing.x16,
          bottom: 110,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: widget.onStartPractice,
              icon: const Icon(LucideIcons.play, size: 18),
              label: const Text('Start Practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SphereColors.primary,
                foregroundColor: SphereColors.onPrimary,
                shape: const RoundedRectangleBorder(
                    borderRadius: SphereRadius.pillRect),
                elevation: 0,
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1F), Color(0xFF0F2A0F)],
        ),
      ),
      child: Center(
        child: Icon(
          LucideIcons.dumbbell,
          size: 88,
          color: SphereColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SphereColors.primary.withValues(alpha: 0.18),
        borderRadius: SphereRadius.pillRect,
        border:
            Border.all(color: SphereColors.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: SphereColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _AttributeChip extends StatelessWidget {
  const _AttributeChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SphereColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
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

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SphereSpacing.x24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CircleIconButton(icon: LucideIcons.chevronLeft, onTap: onBack),
            const SizedBox(height: SphereSpacing.x32),
            Text(
              'Drill not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: SphereSpacing.x8),
            Text(
              'This drill may have been removed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
