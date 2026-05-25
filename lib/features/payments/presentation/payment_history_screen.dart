import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
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
    final l = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(myPaymentHistoryProvider);

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
              90,
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
                        l.payments,
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
                  l.yourLast10Transactions,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x32),
                SphereSectionLabel(l.recent),
                const SizedBox(height: SphereSpacing.x16),
                historyAsync.when(
                  data: (records) {
                    if (records.isEmpty) {
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
                              l.noPaymentsYet,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.sc.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l.registerForProgram,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: context.sc.onSurfaceMuted,
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
                    children: [
                      Text(
                        l.couldNotLoadPayments,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.sc.onSurfaceMuted,
                            ),
                      ),
                      const SizedBox(height: SphereSpacing.x12),
                      TextButton(
                        onPressed: () => ref.invalidate(myPaymentHistoryProvider),
                        child: Text(
                          l.retry,
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
      ],
      ),
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

  Color _statusColor(BuildContext context) {
    switch (record.status) {
      case PaymentStatusKind.cleared:
        return context.sc.success;
      case PaymentStatusKind.pendingApproval:
        return context.sc.warning;
      case PaymentStatusKind.refunded:
        return context.sc.onSurfaceMuted;
      case PaymentStatusKind.failed:
        return context.sc.danger;
      case PaymentStatusKind.unknown:
        return context.sc.onSurfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: () => context.push('/profile/payments/${record.id}'),
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.cardRect,
            border: Border.all(color: context.sc.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.sc.primary.withValues(alpha: 0.12),
                ),
                child: Icon(_methodIcon,
                    color: context.sc.primary, size: 20),
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
                                color: context.sc.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDate(record.createdAt)} · ${record.method.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.sc.onSurfaceMuted,
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
                              color: context.sc.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(context).withValues(alpha: 0.18),
                      borderRadius: SphereRadius.pillRect,
                    ),
                    child: Text(
                      record.status.label,
                      style: TextStyle(
                        color: _statusColor(context),
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
