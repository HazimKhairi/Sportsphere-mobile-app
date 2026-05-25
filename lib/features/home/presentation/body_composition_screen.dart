import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/body_composition_entry.dart';
import '_widgets/body_composition_add_sheet.dart';
import '_widgets/sphere_section_label.dart';
import 'body_composition_providers.dart';

class BodyCompositionScreen extends ConsumerWidget {
  const BodyCompositionScreen({super.key});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(myBodyCompositionProvider);

    return SphereFieldBackground(
      child: Stack(
      children: [
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24,
              SphereSpacing.x16,
              SphereSpacing.x24,
              180,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            context.go('/profile');
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(10),
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
                        'Body',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x8),
                Text(
                  l.trackWeightHeight,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x32),
                async.when(
                  data: (entries) {
                    if (entries.isEmpty) return const _EmptyState();
                    final latest = entries.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LatestCard(entry: latest, formatDate: _formatDate),
                        const SizedBox(height: SphereSpacing.x24),
                        const SphereSectionLabel('History'),
                        const SizedBox(height: SphereSpacing.x12),
                        if (entries.length == 1)
                          Container(
                            padding: const EdgeInsets.all(SphereSpacing.x20),
                            decoration: BoxDecoration(
                              color: context.sc.surfaceElev1,
                              borderRadius: SphereRadius.cardRect,
                              border: Border.all(
                                color: context.sc.borderSubtle,
                              ),
                            ),
                            child: Text(
                              l.logEntry,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                  ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              for (final e in entries.skip(1)) ...[
                                _HistoryRow(
                                  entry: e,
                                  formatDate: _formatDate,
                                ),
                                const SizedBox(height: SphereSpacing.x8),
                              ],
                            ],
                          ),
                      ],
                    );
                  },
                  loading: () => Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(context.sc.primary),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.couldNotLoadEntries,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.sc.onSurfaceMuted,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (e.toString().toLowerCase().contains('permission'))
                        Container(
                          padding: const EdgeInsets.all(SphereSpacing.x16),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: context.sc.warning.withValues(alpha: 0.1),
                            borderRadius: SphereRadius.cardRect,
                            border: Border.all(
                                color: context.sc.warning.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Firestore permission denied. Ask your club admin to update the security rules so players can access their own body composition data.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.sc.warning,
                                  height: 1.5,
                                ),
                          ),
                        ),
                      const SizedBox(height: SphereSpacing.x16),
                      TextButton(
                        onPressed: () => ref.invalidate(myBodyCompositionProvider),
                        child: Text(
                          'Retry',
                          style: TextStyle(color: context.sc.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: SphereSpacing.x16,
          right: SphereSpacing.x16,
          bottom: 110,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => BodyCompositionAddSheet.show(context),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.sc.primary,
                foregroundColor: context.sc.onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: SphereRadius.pillRect,
                ),
                elevation: 4,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.entry, required this.formatDate});
  final BodyCompositionEntry entry;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.sc.surfaceElev1,
            context.sc.primary.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest · ${formatDate(entry.recordedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: SphereSpacing.x12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Metric(
                  label: 'Weight',
                  value: entry.weightKg?.toStringAsFixed(1),
                  unit: 'kg',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Height',
                  value: entry.heightCm?.toStringAsFixed(0),
                  unit: 'cm',
                ),
              ),
            ],
          ),
          const SizedBox(height: SphereSpacing.x16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Metric(
                  label: 'Body fat',
                  value: entry.bodyFatPct?.toStringAsFixed(1),
                  unit: '%',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Muscle',
                  value: entry.muscleMassKg?.toStringAsFixed(1),
                  unit: 'kg',
                ),
              ),
            ],
          ),
          if (entry.bmi != null) ...[
            const SizedBox(height: SphereSpacing.x16),
            Divider(color: context.sc.borderSubtle, height: 1),
            const SizedBox(height: SphereSpacing.x12),
            Row(
              children: [
                Text(
                  'BMI',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
                const Spacer(),
                Text(
                  entry.bmi!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.sc.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurfaceMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontSize: 10,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value ?? '-',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: value == null
                        ? context.sc.onSurfaceMuted
                        : context.sc.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.formatDate});
  final BodyCompositionEntry entry;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (entry.weightKg != null) {
      parts.add('${entry.weightKg!.toStringAsFixed(1)} kg');
    }
    if (entry.bodyFatPct != null) {
      parts.add('${entry.bodyFatPct!.toStringAsFixed(1)}% bf');
    }
    if (entry.muscleMassKg != null) {
      parts.add('${entry.muscleMassKg!.toStringAsFixed(1)} kg muscle');
    }

    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Row(
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
              LucideIcons.activity,
              color: context.sc.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts.isEmpty ? 'Entry' : parts.join(' · '),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(entry.recordedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
            AppLocalizations.of(context)!.noEntries,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.sc.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.tapAddEntry,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
