import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/payment_record.dart';
import 'payment_history_providers.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(myPaymentHistoryProvider);

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
                Row(
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
                        'Payments',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  height: 1.1,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x8),
                Text(
                  'Your last 10 transactions.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x32),
                const SphereSectionLabel('Recent'),
                const SizedBox(height: SphereSpacing.x16),
                historyAsync.when(
                  data: (records) {
                    if (records.isEmpty) {
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
                              'No payments yet',
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
                              'Register for a program to see your payment history here.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: SphereColors.onSurfaceMuted,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final r in records) ...[
                          _PaymentRow(
                            record: r,
                            formatDate: _formatDate,
                          ),
                          const SizedBox(height: SphereSpacing.x8),
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
                    'Couldn’t load your payments.',
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

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.record, required this.formatDate});
  final PaymentRecord record;
  final String Function(DateTime) formatDate;

  IconData get _methodIcon {
    switch (record.method) {
      case PaymentMethodKind.card:
        return LucideIcons.creditCard;
      case PaymentMethodKind.fpx:
        return LucideIcons.building2;
      case PaymentMethodKind.cash:
        return LucideIcons.wallet;
      case PaymentMethodKind.unknown:
        return LucideIcons.circleHelp;
    }
  }

  Color get _statusColor {
    switch (record.status) {
      case PaymentStatusKind.cleared:
        return SphereColors.success;
      case PaymentStatusKind.pendingApproval:
        return SphereColors.warning;
      case PaymentStatusKind.refunded:
        return SphereColors.onSurfaceMuted;
      case PaymentStatusKind.failed:
        return SphereColors.danger;
      case PaymentStatusKind.unknown:
        return SphereColors.onSurfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: () => context.push('/profile/payments/${record.id}'),
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.cardRect,
            border: Border.all(color: SphereColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SphereColors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(_methodIcon,
                    color: SphereColors.primary, size: 20),
              ),
              const SizedBox(width: SphereSpacing.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.programName ?? record.method.label,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: SphereColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDate(record.createdAt)} · ${record.method.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SphereSpacing.x8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.displayAmount,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: SphereColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.18),
                      borderRadius: SphereRadius.pillRect,
                    ),
                    child: Text(
                      record.status.label,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
