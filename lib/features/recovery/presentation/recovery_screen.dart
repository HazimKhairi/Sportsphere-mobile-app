import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/recovery_content.dart';
import '../domain/recovery_log.dart';
import 'recovery_providers.dart';

class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(todayRecoveryLogProvider);
    final contentAsync = ref.watch(recoveryContentProvider);
    final nutritionAsync = ref.watch(nutritionContentProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Recovery & Nutrition',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24, SphereSpacing.x8,
            SphereSpacing.x24, SphereSpacing.bottomNavSafe,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Disclaimer(),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 0,
                child: todayLog.when(
                  data: (log) => _WellnessCard(log: log),
                  loading: () => const _WellnessCard(log: null, loading: true),
                  error: (_, _) => const _WellnessCard(log: null),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              const SphereEntrance(
                delayMs: 80,
                child: SphereSectionLabel('Recovery'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 120,
                child: contentAsync.when(
                  data: (items) => _ContentList(items: items),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              const SphereEntrance(
                delayMs: 160,
                child: SphereSectionLabel('Nutrition'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 200,
                child: nutritionAsync.when(
                  data: (items) => _ContentList(items: items),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WellnessCard extends StatelessWidget {
  const _WellnessCard({this.log, this.loading = false});
  final RecoveryLog? log;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF8B5CF6);
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : log == null
              ? const _LogCta()
              : _ScoreDisplay(log: log!, accent: accent),
    );
  }
}

class _LogCta extends StatelessWidget {
  const _LogCta();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.heartPulse, color: Color(0xFF8B5CF6), size: 24),
        const SizedBox(width: SphereSpacing.x12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you feeling today?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'Log your daily wellness',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => context.push('/train/recovery/check-in'),
          child: const Text('Log', style: TextStyle(color: Color(0xFF8B5CF6))),
        ),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.log, required this.accent});
  final RecoveryLog log;
  final Color accent;

  Color _scoreColor() {
    if (log.wellnessScore >= 70) return const Color(0xFF37F513);
    if (log.wellnessScore >= 50) return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${log.wellnessScore}%',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: _scoreColor(),
              ),
        ),
        const SizedBox(width: SphereSpacing.x16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wellness score',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Logged today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentList extends StatelessWidget {
  const _ContentList({required this.items});
  final List<RecoveryContent> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'Content coming soon.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.sc.onSurfaceMuted,
            ),
      );
    }
    return Column(
      children: items.map((item) => _ContentRow(item: item)).toList(),
    );
  }
}

class _ContentRow extends StatelessWidget {
  const _ContentRow({required this.item});
  final RecoveryContent item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/train/recovery/content/${item.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: SphereSpacing.x8),
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${item.durationMinutes} min · ${item.evidenceLevel} evidence',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: context.sc.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SphereSpacing.x12,
        vertical: SphereSpacing.x8,
      ),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Text(
        'For general sporting guidance only. Not a substitute for advice from a qualified sports dietitian or medical professional.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
              fontSize: 10,
            ),
      ),
    );
  }
}
