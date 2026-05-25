import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/recovery_log.dart';
import 'recovery_ai_providers.dart';
import 'recovery_providers.dart';

class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(todayRecoveryLogProvider);
    final insightAsync = ref.watch(recoveryAiInsightProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.recoveryAndNutrition,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, size: 18, color: context.sc.onSurfaceMuted),
            tooltip: AppLocalizations.of(context)!.regenerateAdvice,
            onPressed: () => ref.invalidate(recoveryAiInsightProvider),
          ),
        ],
      ),
      body: SphereFieldBackground(child: SafeArea(
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

              // Wellness card
              SphereEntrance(
                delayMs: 0,
                child: todayLog.when(
                  data: (log) => _WellnessCard(log: log),
                  loading: () => const _WellnessCard(log: null, loading: true),
                  error: (_, __) => const _WellnessCard(log: null),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),

              // AI insight sections
              SphereEntrance(
                delayMs: 80,
                child: insightAsync.when(
                  data: (insight) => _InsightSections(insight: insight),
                  loading: () => const _InsightLoading(),
                  error: (e, _) => _InsightError(
                    onRetry: () => ref.invalidate(recoveryAiInsightProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

// ── Insight sections ───────────────────────────────────────────────────────────

class _InsightSections extends StatelessWidget {
  const _InsightSections({required this.insight});
  final AiInsight insight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI badge + context
        Row(
          children: [
            Icon(LucideIcons.sparkles, size: 12, color: context.sc.primary),
            const SizedBox(width: 4),
            Text(
              'AI-personalised',
              style: TextStyle(
                color: context.sc.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (insight.context.isNotEmpty) ...[
              Text(
                ' · ${insight.context}',
                style: TextStyle(
                  color: context.sc.onSurfaceMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: SphereSpacing.x16),

        SphereSectionLabel(AppLocalizations.of(context)!.recovery),
        const SizedBox(height: SphereSpacing.x12),
        _TipsList(
          tips: insight.recovery,
          accentColor: const Color(0xFF8B5CF6),
          emptyMessage: 'Log your wellness check-in to get personalised recovery tips.',
        ),
        const SizedBox(height: SphereSpacing.x32),

        SphereSectionLabel(AppLocalizations.of(context)!.nutrition),
        const SizedBox(height: SphereSpacing.x12),
        _TipsList(
          tips: insight.nutrition,
          accentColor: const Color(0xFF37F513),
          emptyMessage: 'Add your body composition data to get personalised nutrition tips.',
        ),
        const SizedBox(height: SphereSpacing.x12),
        _NutritionTrackerBanner(),
      ],
    );
  }
}

class _TipsList extends StatelessWidget {
  const _TipsList({
    required this.tips,
    required this.accentColor,
    required this.emptyMessage,
  });
  final List<String> tips;
  final Color accentColor;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurfaceMuted,
              ),
        ),
      );
    }
    return Column(
      children: tips
          .map((tip) => _TipRow(tip: tip, accentColor: accentColor))
          .toList(),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip, required this.accentColor});
  final String tip;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SphereSpacing.x8),
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
            ),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.sc.onSurface,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading & error states ─────────────────────────────────────────────────────

class _InsightLoading extends StatelessWidget {
  const _InsightLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(context.sc.primary),
              ),
            ),
            const SizedBox(width: SphereSpacing.x8),
            Text(
              'Gemini is analysing your data…',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: SphereSpacing.x16),
        SphereSectionLabel(AppLocalizations.of(context)!.recovery),
        const SizedBox(height: SphereSpacing.x12),
        ..._skeletonRows(context, 3),
        const SizedBox(height: SphereSpacing.x32),
        SphereSectionLabel(AppLocalizations.of(context)!.nutrition),
        const SizedBox(height: SphereSpacing.x12),
        ..._skeletonRows(context, 3),
      ],
    );
  }

  List<Widget> _skeletonRows(BuildContext context, int count) {
    return List.generate(count, (i) {
      return Container(
        margin: const EdgeInsets.only(bottom: SphereSpacing.x8),
        padding: const EdgeInsets.all(SphereSpacing.x16),
        height: 56,
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.sc.borderSubtle,
              ),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: context.sc.borderSubtle.withValues(alpha: 0.5),
                  borderRadius: SphereRadius.pillRect,
                ),
              ),
            ),
            const SizedBox(width: SphereSpacing.x32),
          ],
        ),
      );
    });
  }
}

class _InsightError extends StatelessWidget {
  const _InsightError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SphereSpacing.x24),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.wifiOff, size: 28, color: context.sc.onSurfaceMuted),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            'Could not generate advice.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x12),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: context.sc.primary,
              shape: const RoundedRectangleBorder(borderRadius: SphereRadius.pillRect),
            ),
            child: Text(AppLocalizations.of(context)!.tryAgain),
          ),
        ],
      ),
    );
  }
}

// ── Wellness card ──────────────────────────────────────────────────────────────

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
                AppLocalizations.of(context)!.howAreYouFeeling,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                AppLocalizations.of(context)!.logWellness,
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
                AppLocalizations.of(context)!.wellnessScore,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                AppLocalizations.of(context)!.loggedToday,
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

// ── Nutrition tracker banner ───────────────────────────────────────────────────

class _NutritionTrackerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/train/recovery/nutrition'),
      child: Container(
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: const Color(0xFF37F513).withValues(alpha: 0.08),
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: const Color(0xFF37F513).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF37F513).withValues(alpha: 0.15),
                borderRadius: SphereRadius.cardRect,
              ),
              child: const Icon(LucideIcons.utensils, size: 18, color: Color(0xFF37F513)),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition Tracker',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF37F513),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'Log meals with AI photo analysis',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF37F513)),
          ],
        ),
      ),
    );
  }
}

// ── Disclaimer ─────────────────────────────────────────────────────────────────

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
        'AI-generated guidance for general sporting use only. Not a substitute for advice from a qualified sports dietitian or medical professional.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
              fontSize: 10,
            ),
      ),
    );
  }
}
