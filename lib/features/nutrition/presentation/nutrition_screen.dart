import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../data/nutrition_repository.dart';
import 'nutrition_log_sheet.dart';
import 'nutrition_providers.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayNutritionLogsProvider);
    final summary = ref.watch(todayNutritionSummaryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NutritionLogSheet.show(context, ref),
        backgroundColor: context.sc.primary,
        foregroundColor: context.sc.onPrimary,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text(
          'Log Meal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24,
            SphereSpacing.x16,
            SphereSpacing.x24,
            SphereSpacing.bottomNavSafe,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Material(
                    color: context.sc.surfaceElev1,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          LucideIcons.chevronLeft,
                          size: 20,
                          color: context.sc.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Expanded(
                    child: Text(
                      'Nutrition',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SphereSpacing.x8),
              Text(
                'Track your meals and fuel your performance.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurfaceMuted,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x24),
              _CalorieSummaryCard(summary: summary),
              const SizedBox(height: SphereSpacing.x16),
              _MacroRow(summary: summary),
              const SizedBox(height: SphereSpacing.x32),
              const SphereSectionLabel("Today's Meals"),
              const SizedBox(height: SphereSpacing.x12),
              logsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) return const _EmptyMealsState();
                  return Column(
                    children: [
                      for (final log in logs) ...[
                        _MealCard(log: log, ref: ref),
                        const SizedBox(height: SphereSpacing.x8),
                      ],
                    ],
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(context.sc.primary),
                      ),
                    ),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Could not load meals.',
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

// ---------------------------------------------------------------------------
// Calorie Summary Card
// ---------------------------------------------------------------------------

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({required this.summary});
  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final eaten = summary.totalCalories.toInt();
    final target = summary.calorieTarget.toInt();
    final progress = summary.calorieProgress;

    return Container(
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
            'Calories today',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: SphereSpacing.x8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$eaten',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ $target kcal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: SphereSpacing.x12),
          ClipRRect(
            borderRadius: SphereRadius.pillRect,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.sc.borderSubtle,
              valueColor: AlwaysStoppedAnimation(context.sc.primary),
            ),
          ),
          const SizedBox(height: SphereSpacing.x8),
          Text(
            '${(progress * 100).toInt()}% of daily goal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Macro Row
// ---------------------------------------------------------------------------

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.summary});
  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SphereSpacing.x8,
      runSpacing: SphereSpacing.x8,
      children: [
        _MacroPill(
          icon: LucideIcons.dumbbell,
          label: '${summary.totalProteinG.toStringAsFixed(1)}g',
          sublabel: 'Protein',
          accent: const Color(0xFF3B82F6),
        ),
        _MacroPill(
          icon: LucideIcons.droplets,
          label: '${summary.totalFatG.toStringAsFixed(1)}g',
          sublabel: 'Fat',
          accent: const Color(0xFFF59E0B),
        ),
        _MacroPill(
          icon: LucideIcons.zap,
          label: '${summary.totalCarbsG.toStringAsFixed(1)}g',
          sublabel: 'Carbs',
          accent: const Color(0xFF8B5CF6),
        ),
        _MacroPill(
          icon: LucideIcons.leaf,
          label: '${summary.totalFibreG.toStringAsFixed(1)}g',
          sublabel: 'Fibre',
          accent: const Color(0xFF37F513),
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.sc.onSurface,
                    ),
              ),
              Text(
                sublabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meal Card
// ---------------------------------------------------------------------------

class _MealCard extends StatelessWidget {
  const _MealCard({required this.log, required this.ref});
  final NutritionLog log;
  final WidgetRef ref;

  IconData _mealIcon(MealType type) => switch (type) {
        MealType.breakfast => LucideIcons.sunrise,
        MealType.lunch => LucideIcons.sun,
        MealType.dinner => LucideIcons.moon,
        MealType.snack => LucideIcons.cookie,
      };

  String _mealLabel(MealType type) => switch (type) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete meal?'),
        content: Text(
          'Remove ${_mealLabel(log.mealType)} from today\'s log?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null) {
        await ref.read(nutritionRepositoryProvider).deleteLog(log.id, token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodNames = log.foods.map((f) => f.name).join(', ');

    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: Container(
        padding: const EdgeInsets.all(SphereSpacing.x16),
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
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.sc.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    _mealIcon(log.mealType),
                    size: 16,
                    color: context.sc.primary,
                  ),
                ),
                const SizedBox(width: SphereSpacing.x12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _mealLabel(log.mealType),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.sc.onSurface,
                                ),
                      ),
                      Text(
                        _formatTime(log.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.sc.onSurfaceMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${log.totalCalories.toInt()} kcal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.sc.primary,
                      ),
                ),
              ],
            ),
            if (foodNames.isNotEmpty) ...[
              const SizedBox(height: SphereSpacing.x8),
              Text(
                foodNames,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (log.recommendation != null) ...[
              const SizedBox(height: SphereSpacing.x8),
              Text(
                log.recommendation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                      fontStyle: FontStyle.italic,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------

class _EmptyMealsState extends StatelessWidget {
  const _EmptyMealsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.utensils,
              size: 40,
              color: context.sc.onSurface.withValues(alpha: 0.24),
            ),
            const SizedBox(height: SphereSpacing.x12),
            Text(
              'No meals logged today',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x4),
            Text(
              'Tap + to log your first meal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
