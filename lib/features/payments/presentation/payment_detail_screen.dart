import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/payment_record.dart';
import 'payment_detail_providers.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key, required this.paymentId});
  final String paymentId;

  String _formatDate(DateTime dt) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final h12 = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year} · $h12:$m $period';
  }

  Color _statusColor(PaymentStatusKind s) {
    switch (s) {
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

  IconData _methodIcon(PaymentMethodKind m) {
    switch (m) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(paymentDetailProvider(paymentId: paymentId));

    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: SafeArea(
        bottom: false,
        child: async.when(
          data: (record) {
            if (record == null) return _NotFound(onBack: () => _back(context));
            return _Content(
              record: record,
              formatDate: _formatDate,
              statusColor: _statusColor(record.status),
              methodIcon: _methodIcon(record.method),
              onBack: () => _back(context),
              onOpenReceipt: record.receiptUrl == null
                  ? null
                  : () => _openReceipt(context, record.receiptUrl!),
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(SphereColors.primary),
              ),
            ),
          ),
          error: (_, _) => _NotFound(onBack: () => _back(context)),
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile/payments');
    }
  }

  Future<void> _openReceipt(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open receipt.')),
      );
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.record,
    required this.formatDate,
    required this.statusColor,
    required this.methodIcon,
    required this.onBack,
    required this.onOpenReceipt,
  });

  final PaymentRecord record;
  final String Function(DateTime) formatDate;
  final Color statusColor;
  final IconData methodIcon;
  final VoidCallback onBack;
  final VoidCallback? onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SphereSpacing.x16,
        SphereSpacing.x8,
        SphereSpacing.x16,
        100,
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
                  onTap: onBack,
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
              Text(
                'Receipt',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: SphereSpacing.x24),

          // Hero amount card
          Container(
            padding: const EdgeInsets.all(SphereSpacing.x24),
            decoration: BoxDecoration(
              color: SphereColors.surfaceElev1,
              borderRadius: SphereRadius.cardRect,
              border: Border.all(color: SphereColors.borderSubtle),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SphereColors.surfaceElev1,
                  SphereColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    borderRadius: SphereRadius.pillRect,
                  ),
                  child: Text(
                    record.status.label.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x16),
                Text(
                  record.displayAmount,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: SphereColors.onSurface,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x8),
                Text(
                  record.programName ?? 'Program payment',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: SphereSpacing.x24),
          const SphereSectionLabel('Details'),
          const SizedBox(height: SphereSpacing.x12),
          _DetailRows(
            rows: [
              ('Method', record.method.label),
              ('Date', formatDate(record.createdAt)),
              ('Payment ID', record.id),
              ('Currency', record.currency),
            ],
            methodIcon: methodIcon,
          ),

          if (onOpenReceipt != null) ...[
            const SizedBox(height: SphereSpacing.x24),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOpenReceipt,
                icon: const Icon(LucideIcons.externalLink, size: 18),
                label: const Text('Open receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SphereColors.primary,
                  foregroundColor: SphereColors.onPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: SphereRadius.pillRect,
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRows extends StatelessWidget {
  const _DetailRows({required this.rows, required this.methodIcon});
  final List<(String, String)> rows;
  final IconData methodIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SphereSpacing.x16, vertical: 8),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  if (i == 0) ...[
                    Icon(methodIcon, size: 16, color: SphereColors.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      rows[i].$1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(color: SphereColors.borderSubtle, height: 1),
          ],
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SphereSpacing.x24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: SphereColors.surfaceElev1,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(LucideIcons.chevronLeft,
                    size: 20, color: SphereColors.onSurface),
              ),
            ),
          ),
          const SizedBox(height: SphereSpacing.x32),
          Text(
            'Payment not found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: SphereSpacing.x8),
          Text(
            'This payment may have been removed or you no longer have access.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SphereColors.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
