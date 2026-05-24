import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../core/widgets/sphere_swipe_to_confirm.dart';
import '../../programs/presentation/program_detail_providers.dart';
import 'cash_payment_providers.dart';

class CashPayScreen extends ConsumerStatefulWidget {
  const CashPayScreen({super.key, required this.programId});
  final String programId;

  @override
  ConsumerState<CashPayScreen> createState() => _CashPayScreenState();
}

class _CashPayScreenState extends ConsumerState<CashPayScreen> {
  String? _error;
  bool _submitted = false;

  Future<void> _confirm() async {
    final program = ref
        .read(programDetailProvider(programId: widget.programId))
        .valueOrNull;
    if (program == null) {
      setState(() => _error = 'Program not loaded yet. Try again.');
      throw Exception('Program not loaded');
    }

    try {
      await ref.read(cashPaymentRepositoryProvider).declarePayment(
            programId: program.id,
            amountCents: program.basePriceCents,
            currency: program.currency,
          );
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not record payment: $e');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final programAsync = ref.watch(
      programDetailProvider(programId: widget.programId),
    );

    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.sc.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CircleIconButton(
                    icon: LucideIcons.chevronLeft,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/programs');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: SphereSpacing.x24),
              Text(
                _submitted ? l.waitingForStaff : l.payWithCash,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: SphereSpacing.x8),
              Text(
                _submitted
                    ? l.staffWillConfirm
                    : l.handCashToStaff,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurfaceMuted,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              programAsync.when(
                data: (program) {
                  if (program == null) {
                    return Text(
                      'Program not found.',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.sc.onSurfaceMuted,
                              ),
                    );
                  }
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
                          program.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: context.sc.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.amountDue,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: context.sc.onSurfaceMuted,
                                letterSpacing: 0.6,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          program.displayPrice,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: context.sc.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: context.sc.danger),
                ),
                const SizedBox(height: SphereSpacing.x12),
              ],
              if (_submitted)
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.sc.primary,
                      foregroundColor: context.sc.onPrimary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: SphereRadius.pillRect,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l.done,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                SphereSwipeToConfirm(
                  label: l.swipeToConfirmPayment,
                  confirmedLabel: 'Recorded',
                  onConfirm: _confirm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: context.sc.onSurface),
        ),
      ),
    );
  }
}
