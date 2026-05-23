import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/workout_template.dart';
import 'strength_providers.dart';

class StrengthScreen extends ConsumerWidget {
  const StrengthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(assignedWorkoutsProvider);

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
          'Strength',
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
                child: SphereSectionLabel('Assigned by Coach'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 80,
                child: workoutsAsync.when(
                  data: (templates) {
                    if (templates.isEmpty) {
                      return const _EmptyState();
                    }
                    return Column(
                      children: [
                        for (final t in templates)
                          _WorkoutCard(template: t),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Text(
                    'Couldn\'t load workouts.',
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

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.template});
  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            template.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: SphereSpacing.x4),
          Text(
            '${template.exercises.length} exercises · Est. ${template.estimatedMinutes} min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  context.push('/train/strength/workout/${template.id}'),
              style: FilledButton.styleFrom(
                backgroundColor: context.sc.warning,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: SphereRadius.pillRect,
                ),
              ),
              child: const Text('Start Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'No workouts assigned yet.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x4),
          Text(
            'Your coach will assign programs here.',
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
