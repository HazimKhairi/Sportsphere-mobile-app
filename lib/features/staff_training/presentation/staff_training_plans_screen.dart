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
import '../../training_plans/domain/training_plan.dart';
import 'staff_training_providers.dart';

class StaffTrainingPlansScreen extends ConsumerWidget {
  const StaffTrainingPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(staffTrainingPlansProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppLocalizations.of(context)!.trainingPlans),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SphereSpacing.x16),
            child: FilledButton.icon(
              onPressed: () => context.push('/staff/training/plans/new'),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('New'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: SphereRadius.pillRect),
                padding: const EdgeInsets.symmetric(
                    horizontal: SphereSpacing.x16,
                    vertical: SphereSpacing.x8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24,
            SphereSpacing.x8,
            SphereSpacing.x24,
            SphereSpacing.bottomNavSafe,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SphereEntrance(
                delayMs: 0,
                child: SphereSectionLabel('Plans'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 80,
                child: plansAsync.when(
                  data: (plans) {
                    if (plans.isEmpty) return const _EmptyState();
                    return Column(
                      children: plans.map((p) => _PlanCard(plan: p)).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, st) => Text(
                    AppLocalizations.of(context)!.couldNotLoadPlans,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    final subtitle =
        'Week ${plan.currentWeek} of ${plan.totalWeeks} · ${plan.phase}';

    return GestureDetector(
      onTap: () => context.push('/staff/training/plans/${plan.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: SphereSpacing.x12),
        padding: const EdgeInsets.all(SphereSpacing.x20),
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
                    plan.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: context.sc.primary, size: 16),
          ],
        ),
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
          Icon(LucideIcons.clipboardList,
              size: 32, color: context.sc.onSurfaceMuted),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            AppLocalizations.of(context)!.noPlans,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: SphereSpacing.x4),
          Text(
            AppLocalizations.of(context)!.createFirstPlan,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
