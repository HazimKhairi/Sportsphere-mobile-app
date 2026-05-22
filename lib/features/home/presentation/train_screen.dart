import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/drill.dart';
import '_widgets/sphere_drill_of_day_card.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_section_label.dart';
import 'player_home_providers.dart';
import 'train_providers.dart';

class TrainScreen extends ConsumerWidget {
  const TrainScreen({super.key});

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
        return 'Other';
      default:
        // Title-case the raw key with underscores → spaces.
        return raw
            .split('_')
            .map((p) => p.isEmpty
                ? p
                : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
            .join(' ');
    }
  }

  Map<String, List<Drill>> _group(List<Drill> drills) {
    final out = <String, List<Drill>>{};
    for (final d in drills) {
      out.putIfAbsent(d.category, () => []).add(d);
    }
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allDrillsProvider);
    final todayAsync = ref.watch(todayDrillProvider);

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24,
              SphereSpacing.x16,
              SphereSpacing.x24,
              90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SphereEntrance(
                  delayMs: 0,
                  child: Text(
                    'Train',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: SphereSpacing.x8),
                SphereEntrance(
                  delayMs: 60,
                  child: Text(
                    'Keep your touch sharp.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                // Featured: Today's drill
                SphereEntrance(
                  delayMs: 120,
                  child: todayAsync.when(
                    data: (drill) => SphereDrillOfDayCard(
                      drillName: drill?.name ?? 'No drill assigned',
                      drillSubtitle: drill == null
                          ? 'Come back tomorrow.'
                          : '5 min · level ${drill.difficulty} ball control',
                      onTap: drill == null
                          ? null
                          : () => context.push('/train/drill/${drill.id}'),
                    ),
                    loading: () => const SphereDrillOfDayCard(
                      drillName: '',
                      drillSubtitle: '',
                      loading: true,
                    ),
                    error: (_, _) => const SphereDrillOfDayCard(
                      drillName: 'Couldn\'t load drill',
                      drillSubtitle: 'Try again later.',
                    ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                // All drills, grouped by category
                allAsync.when(
                  data: (drills) {
                    if (drills.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(SphereSpacing.x20),
                        decoration: BoxDecoration(
                          color: SphereColors.surfaceElev1,
                          borderRadius: SphereRadius.cardRect,
                          border: Border.all(color: SphereColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No drills available',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: SphereColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your coach can publish drills from the dashboard.',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: SphereColors.onSurfaceMuted,
                                      ),
                            ),
                          ],
                        ),
                      );
                    }
                    final grouped = _group(drills);
                    final categories = grouped.keys.toList()
                      ..sort((a, b) {
                        if (a.isEmpty) return 1;
                        if (b.isEmpty) return -1;
                        return a.compareTo(b);
                      });
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < categories.length; i++) ...[
                          SphereEntrance(
                            delayMs: 160 + i * 50,
                            child: SphereSectionLabel(
                              _categoryLabel(categories[i]),
                            ),
                          ),
                          const SizedBox(height: SphereSpacing.x12),
                          SizedBox(
                            height: 168,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              itemCount: grouped[categories[i]]!.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: SphereSpacing.x12),
                              itemBuilder: (context, idx) {
                                final d = grouped[categories[i]]![idx];
                                return _DrillCard(drill: d);
                              },
                            ),
                          ),
                          const SizedBox(height: SphereSpacing.x24),
                        ],
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(SphereColors.primary),
                        ),
                      ),
                    ),
                  ),
                  error: (_, _) => Text(
                    'Couldn\'t load drills.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrillCard extends StatelessWidget {
  const _DrillCard({required this.drill});
  final Drill drill;

  IconData get _difficultyIcon {
    switch (drill.difficulty) {
      case 1:
        return LucideIcons.signal;
      case 2:
        return LucideIcons.signal;
      case 3:
        return LucideIcons.signal;
      default:
        return LucideIcons.signal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Material(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        child: InkWell(
          onTap: () => context.push('/train/drill/${drill.id}'),
          borderRadius: SphereRadius.cardRect,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: SphereRadius.cardRect,
              border: Border.all(color: SphereColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover gradient w/ dumbbell glyph
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1F1F1F), Color(0xFF0F2A0F)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            right: -8,
                            top: -4,
                            child: Opacity(
                              opacity: 0.18,
                              child: Icon(
                                LucideIcons.dumbbell,
                                size: 88,
                                color: SphereColors.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    SphereColors.primary.withValues(alpha: 0.18),
                                borderRadius: SphereRadius.pillRect,
                                border: Border.all(
                                  color: SphereColors.primary
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_difficultyIcon,
                                      size: 10,
                                      color: SphereColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'L${drill.difficulty}',
                                    style: const TextStyle(
                                      color: SphereColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(SphereSpacing.x12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drill.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: SphereColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        drill.targetAttributes.isEmpty
                            ? 'Drill'
                            : drill.targetAttributes.first
                                .replaceAll('_', ' '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SphereColors.onSurfaceMuted,
                              fontSize: 11,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
