import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/pending_payment.dart';
import 'approvals_providers.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Approvals',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: SphereColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pending cash payments to review.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: _ApprovalsList()),
        ],
      ),
    );
  }
}

class _ApprovalsList extends ConsumerWidget {
  const _ApprovalsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(approvalsNotifierProvider);

    return approvalsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(SphereColors.primary),
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load approvals.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(approvalsNotifierProvider),
              child: const Text(
                'Retry',
                style: TextStyle(color: SphereColors.primary),
              ),
            ),
          ],
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.checkCircle2,
                  size: 48,
                  color: SphereColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'All caught up!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SphereColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No pending approvals.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          itemCount: list.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _PaymentCard(payment: list[index]),
        );
      },
    );
  }
}

class _PaymentCard extends ConsumerStatefulWidget {
  const _PaymentCard({required this.payment});
  final PendingPayment payment;

  @override
  ConsumerState<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends ConsumerState<_PaymentCard> {
  bool _busy = false;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}';
  }

  Future<void> _handleApprove(BuildContext context) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(approvalsNotifierProvider.notifier)
          .approve(widget.payment.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment approved.')),
        );
      }
    } catch (_) {
      setState(() => _busy = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Approve failed. Try again.')),
        );
      }
    }
  }

  void _showRejectSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SphereColors.surfaceElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          bool busy = false;
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SphereColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reject payment',
                  style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                        color: SphereColors.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This will notify the player.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reason',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: SphereColors.surfaceElev2,
                    borderRadius: SphereRadius.cardRect,
                    border: Border.all(color: SphereColors.borderSubtle),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: controller,
                    maxLines: 3,
                    style:
                        const TextStyle(color: SphereColors.onSurface),
                    onChanged: (_) => setSheetState(() {}),
                    decoration: const InputDecoration(
                      hintText:
                          'e.g. Amount does not match program fee.',
                      hintStyle: TextStyle(
                          color: SphereColors.onSurfaceMuted),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: busy ||
                            controller.text.trim().length < 3
                        ? null
                        : () async {
                            setSheetState(() => busy = true);
                            try {
                              await ref
                                  .read(approvalsNotifierProvider
                                      .notifier)
                                  .reject(widget.payment.id,
                                      controller.text.trim());
                              if (sheetCtx.mounted) {
                                Navigator.of(sheetCtx).pop();
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Payment rejected.')),
                                );
                              }
                            } catch (_) {
                              setSheetState(() => busy = false);
                              if (sheetCtx.mounted) {
                                ScaffoldMessenger.of(sheetCtx)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Reject failed. Try again.')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SphereColors.danger,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius: SphereRadius.pillRect),
                      elevation: 0,
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                  Colors.white),
                            ),
                          )
                        : const Text(
                            'Reject payment',
                            style: TextStyle(
                                fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: payer name + method badge
          Row(
            children: [
              Expanded(
                child: Text(
                  payment.payerName,
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                ),
              ),
              _MethodBadge(method: payment.paymentMethod),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            payment.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SphereColors.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: 12),
          // Amount + date row
          Row(
            children: [
              Text(
                payment.formattedAmount,
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: SphereColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
              ),
              const Spacer(),
              const Icon(LucideIcons.clock,
                  size: 12, color: SphereColors.onSurfaceMuted),
              const SizedBox(width: 4),
              Text(
                _formatDate(payment.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _busy ? null : () => _showRejectSheet(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SphereColors.danger,
                    side: const BorderSide(color: SphereColors.danger),
                    shape: const RoundedRectangleBorder(
                        borderRadius: SphereRadius.pillRect),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _busy ? null : () => _handleApprove(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SphereColors.primary,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                        borderRadius: SphereRadius.pillRect),
                    elevation: 0,
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});
  final String method;

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    switch (method) {
      case 'cash':
        label = 'Cash';
        bg = SphereColors.primary.withValues(alpha: 0.15);
        fg = SphereColors.primary;
      case 'fpx_manual':
        label = 'FPX';
        bg = const Color(0xFF1D4ED8).withValues(alpha: 0.15);
        fg = const Color(0xFF3B82F6);
      default:
        label = method.toUpperCase();
        bg = SphereColors.onSurfaceMuted.withValues(alpha: 0.15);
        fg = SphereColors.onSurfaceMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: SphereRadius.pillRect,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
