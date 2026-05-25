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
import '../../strength/domain/workout_template.dart';
import 'staff_training_providers.dart';

class StaffWorkoutTemplatesScreen extends ConsumerWidget {
  const StaffWorkoutTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(staffWorkoutTemplatesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppLocalizations.of(context)!.workoutTemplates),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SphereSpacing.x16),
            child: FilledButton.icon(
              onPressed: () => context.push('/staff/training/workouts/new'),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('New'),
              style: FilledButton.styleFrom(
                backgroundColor: context.sc.warning,
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
      body: SphereFieldBackground(child: SafeArea(
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
                child: SphereSectionLabel('Templates'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 80,
                child: workoutsAsync.when(
                  data: (templates) {
                    if (templates.isEmpty) return const _EmptyState();
                    return Column(
                      children: templates
                          .map((t) => _TemplateCard(template: t))
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, st) => Text(
                    AppLocalizations.of(context)!.couldNotLoadTemplates,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
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

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});

  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    final count = template.exercises.length;
    final subtitle =
        '$count exercise${count == 1 ? '' : 's'} · ${template.estimatedMinutes} min';

    return GestureDetector(
      onTap: () => context.push('/staff/training/workouts/${template.id}'),
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
                    template.title,
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
          Icon(LucideIcons.dumbbell, size: 32, color: context.sc.onSurfaceMuted),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            AppLocalizations.of(context)!.noTemplates,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: SphereSpacing.x4),
          Text(
            AppLocalizations.of(context)!.createFirstTemplate,
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
