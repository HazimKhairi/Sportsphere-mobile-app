import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import '../../domain/redemption_result.dart';
import '../../domain/reward.dart';
import '../rewards_providers.dart';

class RewardRedeemSheet extends ConsumerStatefulWidget {
  const RewardRedeemSheet({
    super.key,
    required this.reward,
    required this.currentBalance,
  });

  final Reward reward;
  final int currentBalance;

  static Future<void> show(
    BuildContext context, {
    required Reward reward,
    required int currentBalance,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RewardRedeemSheet(
        reward: reward,
        currentBalance: currentBalance,
      ),
    );
  }

  @override
  ConsumerState<RewardRedeemSheet> createState() => _RewardRedeemSheetState();
}

class _RewardRedeemSheetState extends ConsumerState<RewardRedeemSheet> {
  bool _busy = false;
  String? _error;
  RedemptionResult? _result;

  bool get _canAfford => widget.currentBalance >= widget.reward.costPoints;

  Future<void> _redeem() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref.read(rewardsRepositoryProvider).redeem(
            rewardId: widget.reward.id,
          );
      if (!mounted) return;
      setState(() {
        _result = result;
        _busy = false;
      });
      unawaited(HapticFeedback.mediumImpact());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is RewardsException ? e.message : 'Redeem failed: $e';
        _busy = false;
      });
    }
  }

  void _copyCode() {
    final code = _result?.code;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SphereColors.surfaceElev2,
        borderRadius: SphereRadius.sheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24,
            SphereSpacing.x16,
            SphereSpacing.x24,
            SphereSpacing.x24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SphereSpacing.x16),
                  decoration: BoxDecoration(
                    color: SphereColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (_result != null)
                _SuccessState(
                  result: _result!,
                  reward: widget.reward,
                  onCopy: _copyCode,
                  onDone: () => Navigator.of(context).pop(),
                )
              else
                _ConfirmState(
                  reward: widget.reward,
                  balance: widget.currentBalance,
                  canAfford: _canAfford,
                  busy: _busy,
                  error: _error,
                  onConfirm: _redeem,
                  onCancel: () => Navigator.of(context).pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmState extends StatelessWidget {
  const _ConfirmState({
    required this.reward,
    required this.balance,
    required this.canAfford,
    required this.busy,
    required this.error,
    required this.onConfirm,
    required this.onCancel,
  });

  final Reward reward;
  final int balance;
  final bool canAfford;
  final bool busy;
  final String? error;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final remaining = balance - reward.costPoints;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem reward',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          reward.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SphereColors.onSurfaceMuted,
              ),
        ),
        const SizedBox(height: SphereSpacing.x24),
        Container(
          padding: const EdgeInsets.all(SphereSpacing.x20),
          decoration: BoxDecoration(
            color: SphereColors.surfaceElev1,
            borderRadius: SphereRadius.cardRect,
            border: Border.all(color: SphereColors.borderSubtle),
          ),
          child: Column(
            children: [
              _Row(
                label: 'Reward cost',
                value: '${reward.costPoints} pts',
              ),
              const SizedBox(height: SphereSpacing.x8),
              const Divider(color: SphereColors.borderSubtle, height: 1),
              const SizedBox(height: SphereSpacing.x8),
              _Row(
                label: 'Your balance',
                value: '$balance pts',
              ),
              const SizedBox(height: SphereSpacing.x8),
              const Divider(color: SphereColors.borderSubtle, height: 1),
              const SizedBox(height: SphereSpacing.x8),
              _Row(
                label: 'After redeem',
                value: canAfford ? '$remaining pts' : '–',
                emphasised: true,
                negative: !canAfford,
              ),
            ],
          ),
        ),
        if (!canAfford) ...[
          const SizedBox(height: SphereSpacing.x12),
          Text(
            'Earn ${reward.costPoints - balance} more points to redeem.',
            style: const TextStyle(color: SphereColors.warning),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: SphereSpacing.x12),
          Text(error!, style: const TextStyle(color: SphereColors.danger)),
        ],
        const SizedBox(height: SphereSpacing.x24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: SphereColors.borderSubtle),
                  shape: const RoundedRectangleBorder(
                    borderRadius: SphereRadius.pillRect,
                  ),
                  foregroundColor: SphereColors.onSurface,
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: ElevatedButton(
                onPressed: (busy || !canAfford) ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: SphereColors.primary,
                  foregroundColor: SphereColors.onPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: SphereRadius.pillRect,
                  ),
                  disabledBackgroundColor:
                      SphereColors.primary.withValues(alpha: 0.4),
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(SphereColors.onPrimary),
                        ),
                      )
                    : const Text('Redeem'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasised = false,
    this.negative = false,
  });
  final String label;
  final String value;
  final bool emphasised;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final color = negative
        ? SphereColors.danger
        : emphasised
            ? SphereColors.primary
            : SphereColors.onSurface;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SphereColors.onSurfaceMuted,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({
    required this.result,
    required this.reward,
    required this.onCopy,
    required this.onDone,
  });

  final RedemptionResult result;
  final Reward reward;
  final VoidCallback onCopy;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SphereColors.primary.withValues(alpha: 0.18),
              border: Border.all(
                color: SphereColors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              LucideIcons.check,
              color: SphereColors.primary,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: SphereSpacing.x16),
        Center(
          child: Text(
            'Redeemed',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            reward.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SphereColors.onSurfaceMuted,
                ),
          ),
        ),
        const SizedBox(height: SphereSpacing.x24),
        Container(
          padding: const EdgeInsets.all(SphereSpacing.x20),
          decoration: BoxDecoration(
            color: SphereColors.surfaceElev1,
            borderRadius: SphereRadius.cardRect,
            border: Border.all(
              color: SphereColors.primary.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Text(
                'YOUR CODE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SelectableText(
                result.code,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: SphereColors.primary,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SphereSpacing.x16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(LucideIcons.copy, size: 16),
                  label: const Text('Copy code'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    side: BorderSide(
                      color: SphereColors.primary.withValues(alpha: 0.4),
                    ),
                    foregroundColor: SphereColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SphereSpacing.x16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Balance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                    ),
              ),
            ),
            Text(
              '${result.remainingPoints} pts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SphereColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: SphereSpacing.x24),
        ElevatedButton(
          onPressed: onDone,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
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
          child: const Text('Done'),
        ),
      ],
    );
  }
}
