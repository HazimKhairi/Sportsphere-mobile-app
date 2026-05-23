import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/reward.dart';
import '../domain/voucher.dart';
import '_widgets/reward_redeem_sheet.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_section_label.dart';
import 'rewards_providers.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _tabIndex = 0;

  IconData _iconFor(Reward r) {
    switch (r.iconName) {
      case 'shirt':
        return LucideIcons.shirt;
      case 'gift':
        return LucideIcons.gift;
      case 'sticker':
        return LucideIcons.sticker;
      case 'ticket':
        return LucideIcons.ticket;
      case 'trophy':
        return LucideIcons.trophy;
      default:
        return LucideIcons.gift;
    }
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied!')),
    );
  }

  String _formatDate(DateTime date) {
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
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rewardsAsync = ref.watch(myRewardsCatalogProvider);
    final balanceAsync = ref.watch(myPointsBalanceProvider);
    final balance = balanceAsync.valueOrNull ?? 0;

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
                        'Rewards',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x8),
                Text(
                  'Spend points on stuff your club has stocked.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                _BalanceCard(balance: balance),
                const SizedBox(height: SphereSpacing.x24),

                // Tab toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0
                                ? SphereColors.primary
                                : SphereColors.surfaceElev2,
                            borderRadius: SphereRadius.pillRect,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Rewards',
                            style: TextStyle(
                              color: _tabIndex == 0
                                  ? Colors.black
                                  : SphereColors.onSurfaceMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SphereSpacing.x8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1
                                ? SphereColors.primary
                                : SphereColors.surfaceElev2,
                            borderRadius: SphereRadius.pillRect,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'My Vouchers',
                            style: TextStyle(
                              color: _tabIndex == 1
                                  ? Colors.black
                                  : SphereColors.onSurfaceMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x24),

                if (_tabIndex == 0) ...[
                  const SphereSectionLabel('Catalog'),
                  const SizedBox(height: SphereSpacing.x16),
                  rewardsAsync.when(
                    data: (rewards) {
                      if (rewards.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(SphereSpacing.x20),
                          decoration: BoxDecoration(
                            color: SphereColors.surfaceElev1,
                            borderRadius: SphereRadius.cardRect,
                            border: Border.all(
                                color: SphereColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No rewards yet',
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
                                'Your coach can publish rewards from the dashboard.',
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
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: SphereSpacing.x12,
                          crossAxisSpacing: SphereSpacing.x12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: rewards.length,
                        itemBuilder: (context, i) {
                          final r = rewards[i];
                          return _RewardCard(
                            reward: r,
                            icon: _iconFor(r),
                            balance: balance,
                            onTap: () {
                              if (!r.available) return;
                              RewardRedeemSheet.show(
                                context,
                                reward: r,
                                currentBalance: balance,
                              );
                            },
                          );
                        },
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
                            valueColor: AlwaysStoppedAnimation(
                                SphereColors.primary),
                          ),
                        ),
                      ),
                    ),
                    error: (_, _) => Text(
                      'Could not load rewards.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: SphereColors.onSurfaceMuted),
                    ),
                  ),
                ] else ...[
                  _VouchersTab(
                    copyCode: _copyCode,
                    formatDate: _formatDate,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VouchersTab extends ConsumerWidget {
  const _VouchersTab({
    required this.copyCode,
    required this.formatDate,
  });

  final void Function(BuildContext context, String code) copyCode;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vouchersAsync = ref.watch(myVouchersProvider);

    return vouchersAsync.when(
      data: (vouchers) {
        if (vouchers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'You haven\'t redeemed any rewards yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                    ),
              ),
            ),
          );
        }
        return Column(
          children: vouchers
              .map((v) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: SphereSpacing.x12),
                    child: _VoucherCard(
                      voucher: v,
                      copyCode: copyCode,
                      formatDate: formatDate,
                    ),
                  ))
              .toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
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
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              'Could not load vouchers.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(myVouchersProvider),
              child: const Text(
                'Retry',
                style: TextStyle(color: SphereColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({
    required this.voucher,
    required this.copyCode,
    required this.formatDate,
  });

  final Voucher voucher;
  final void Function(BuildContext context, String code) copyCode;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  voucher.rewardName,
                  style: const TextStyle(
                    color: SphereColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: SphereSpacing.x8),
              _StatusBadge(status: voucher.status),
            ],
          ),
          const SizedBox(height: SphereSpacing.x8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: SphereColors.surfaceElev2,
                    borderRadius: SphereRadius.pillRect,
                    border: Border.all(color: SphereColors.borderSubtle),
                  ),
                  child: Text(
                    voucher.code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: SphereColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SphereSpacing.x8),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 18),
                color: SphereColors.primary,
                onPressed: () => copyCode(context, voucher.code),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                LucideIcons.calendar,
                size: 12,
                color: SphereColors.onSurfaceMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'Expires ${formatDate(voucher.expiresAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: SphereColors.onSurfaceMuted,
                ),
              ),
              const Spacer(),
              Text(
                voucher.discountValue,
                style: const TextStyle(
                  color: SphereColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final String label;

    switch (status) {
      case 'used':
        bg = SphereColors.onSurfaceMuted.withValues(alpha: 0.15);
        textColor = SphereColors.onSurfaceMuted;
        label = 'Used';
      case 'expired':
        bg = SphereColors.danger.withValues(alpha: 0.15);
        textColor = SphereColors.danger;
        label = 'Expired';
      default: // 'active'
        bg = SphereColors.primary.withValues(alpha: 0.15);
        textColor = SphereColors.primary;
        label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: SphereRadius.pillRect,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final int balance;

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
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SphereColors.primary.withValues(alpha: 0.18),
              border: Border.all(
                color: SphereColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              LucideIcons.zap,
              color: SphereColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: SphereSpacing.x16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your balance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$balance',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            height: 1,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'pts',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: SphereColors.onSurfaceMuted,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.icon,
    required this.balance,
    required this.onTap,
  });

  final Reward reward;
  final IconData icon;
  final int balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canAfford = balance >= reward.costPoints;
    final available = reward.available;
    final muted = !available;

    return Material(
      color: SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.cardRect,
            border: Border.all(
              color: muted
                  ? SphereColors.borderSubtle
                  : canAfford
                      ? SphereColors.primary.withValues(alpha: 0.4)
                      : SphereColors.borderSubtle,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: muted
                      ? SphereColors.surfaceElev2
                      : SphereColors.primary.withValues(alpha: 0.18),
                  border: Border.all(
                    color: muted
                        ? SphereColors.borderSubtle
                        : SphereColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  muted ? LucideIcons.lock : icon,
                  color: muted
                      ? SphereColors.onSurfaceMuted
                      : SphereColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: SphereSpacing.x12),
              Text(
                reward.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: muted
                          ? SphereColors.onSurfaceMuted
                          : SphereColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  reward.description.isEmpty ? 'Reward' : reward.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SphereColors.onSurfaceMuted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: SphereSpacing.x8),
              Row(
                children: [
                  Icon(
                    LucideIcons.zap,
                    size: 12,
                    color: muted
                        ? SphereColors.onSurfaceMuted
                        : canAfford
                            ? SphereColors.primary
                            : SphereColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reward.costPoints} pts',
                    style: TextStyle(
                      color: muted
                          ? SphereColors.onSurfaceMuted
                          : canAfford
                              ? SphereColors.primary
                              : SphereColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (reward.stock != null &&
                      reward.stock! < 10 &&
                      reward.stock! > 0)
                    Text(
                      'x${reward.stock}',
                      style: const TextStyle(
                        color: SphereColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
