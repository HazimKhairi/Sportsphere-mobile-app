import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/points_entry.dart';
import '../domain/points_summary.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_section_label.dart';
import 'points_providers.dart';

class PointsScreen extends ConsumerWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(pointsSummaryProvider);

    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(),
                summaryAsync.when(
                  data: (summary) => _SummaryBody(summary: summary, ref: ref),
                  loading: () => const Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(SphereColors.primary),
                        ),
                      ),
                    ),
                  ),
                  error: (err, _) => Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Could not load points.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SphereColors.onSurfaceMuted,
                                ),
                          ),
                          const SizedBox(height: SphereSpacing.x12),
                          TextButton(
                            onPressed: () => ref.invalidate(pointsSummaryProvider),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: SphereColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SphereSpacing.x24,
        SphereSpacing.x16,
        SphereSpacing.x24,
        SphereSpacing.x8,
      ),
      child: Row(
        children: [
          Material(
            color: SphereColors.surfaceElev1,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/profile');
                }
              },
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: SphereColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Text(
              'Points',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.summary, required this.ref});
  final PointsSummary summary;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
            child: _HeroCard(summary: summary),
          ),
          const SizedBox(height: SphereSpacing.x24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
            child: SphereSectionLabel('History'),
          ),
          const SizedBox(height: SphereSpacing.x8),
          Expanded(
            child: _HistoryList(history: summary.history),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});
  final PointsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SphereColors.surfaceElev1,
            SphereColors.primary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              value: summary.totalPoints,
              label: 'Total earned',
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: SphereColors.borderSubtle,
          ),
          Expanded(
            child: _StatColumn(
              value: summary.availablePoints,
              label: 'Available',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: SphereColors.primary,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SphereColors.onSurfaceMuted,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});
  final List<PointsEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Text(
          'No points activity yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SphereColors.onSurfaceMuted,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        SphereSpacing.x24,
        0,
        SphereSpacing.x24,
        90,
      ),
      itemCount: history.length,
      separatorBuilder: (context, i) => const Divider(
        color: SphereColors.borderSubtle,
        height: 1,
      ),
      itemBuilder: (context, i) => _HistoryRow(entry: history[i]),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});
  final PointsEntry entry;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    return '$day $month';
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.points >= 0;
    final circleColor = isPositive ? SphereColors.primary : const Color(0xFFEF4444);
    final textColor = isPositive ? Colors.black : Colors.white;
    final pointsLabel =
        isPositive ? '+${entry.points}' : '${entry.points}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            child: Text(
              pointsLabel,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Text(
              entry.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurface,
                    height: 1.4,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: SphereSpacing.x8),
          Text(
            _formatDate(entry.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SphereColors.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
