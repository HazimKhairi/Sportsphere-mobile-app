import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../domain/training_plan.dart';
import 'training_plans_providers.dart';

class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeksAsync = ref.watch(planWeeksProvider(planId));

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
          'Plan Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: weeksAsync.when(
          data: (weeks) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24, SphereSpacing.x8,
              SphereSpacing.x24, SphereSpacing.bottomNavSafe,
            ),
            itemCount: weeks.length,
            itemBuilder: (context, i) => _WeekSection(week: weeks[i]),
          ),
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(
            child: Text(
              'Couldn\'t load plan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekSection extends StatelessWidget {
  const _WeekSection({required this.week});
  final PlanWeek week;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x12),
          child: Text(
            'Week ${week.weekNumber}${week.theme.isNotEmpty ? ' · ${week.theme}' : ''}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ),
        for (final session in week.sessions) _SessionRow(session: session),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final PlanSession session;

  static const _days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final color = Color(session.focus.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: SphereSpacing.x8),
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: SphereRadius.pillRect,
            ),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${_days[session.dayOfWeek]} · ${session.focus.label} · ${session.durationMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          ),
          if (session.isCompleted)
            const Icon(Icons.check_circle, color: Color(0xFF37F513), size: 20)
          else
            Icon(LucideIcons.circle, color: context.sc.onSurfaceMuted, size: 20),
        ],
      ),
    );
  }
}
