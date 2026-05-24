import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/training_plan.dart';
import 'training_plans_providers.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(assignedPlansProvider);

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
          AppLocalizations.of(context)!.trainingPlans,
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
              const SphereEntrance(
                delayMs: 0,
                child: SphereSectionLabel('Active Plans'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 80,
                child: plansAsync.when(
                  data: (plans) {
                    if (plans.isEmpty) {
                      return const _EmptyState();
                    }
                    return Column(
                      children: plans.map((p) => _PlanCard(plan: p)).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Text(
                    'Couldn\'t load plans.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final progress = plan.currentWeek / plan.totalWeeks;

    return GestureDetector(
      onTap: () => context.push('/train/plans/${plan.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: SphereSpacing.x12),
        padding: const EdgeInsets.all(SphereSpacing.x20),
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
                Expanded(
                  child: Text(
                    plan.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: SphereRadius.pillRect,
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    plan.phase.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B82F6),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SphereSpacing.x8),
            _WeekStrip(current: plan.currentWeek, total: plan.totalWeeks),
            const SizedBox(height: SphereSpacing.x12),
            Text(
              'Week ${plan.currentWeek} of ${plan.totalWeeks}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x8),
            ClipRRect(
              borderRadius: SphereRadius.pillRect,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(total, (i) {
          final weekNum = i + 1;
          final isDone = weekNum < current;
          final isCurrent = weekNum == current;
          return Container(
            margin: const EdgeInsets.only(right: 6),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? const Color(0xFF3B82F6)
                  : isCurrent
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                      : context.sc.surfaceElev2,
              border: isCurrent
                  ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                  : null,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '$weekNum',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? const Color(0xFF3B82F6)
                            : context.sc.onSurfaceMuted,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
          Icon(LucideIcons.clipboardList, size: 32, color: context.sc.onSurfaceMuted),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            AppLocalizations.of(context)!.noPlansAssigned,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x4),
          Text(
            'Your coach will assign training programs here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
