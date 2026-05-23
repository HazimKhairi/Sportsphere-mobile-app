import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';

enum PaymentMethod { card, cash }

class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({super.key});

  static Future<PaymentMethod?> show(BuildContext context) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PaymentMethodSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.sc.surfaceElev2,
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
                    color: context.sc.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Pay with',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Pick how you want to pay.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x20),
              _MethodTile(
                icon: LucideIcons.creditCard,
                title: 'Card or FPX',
                subtitle: 'Pay securely with Stripe.',
                onTap: () => Navigator.of(context).pop(PaymentMethod.card),
              ),
              const SizedBox(height: SphereSpacing.x12),
              _MethodTile(
                icon: LucideIcons.wallet,
                title: 'Cash',
                subtitle: 'Hand cash to staff. Confirm with a swipe.',
                onTap: () => Navigator.of(context).pop(PaymentMethod.cash),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: onTap,
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
                  color: context.sc.primary.withValues(alpha: 0.18),
                ),
                child: Icon(icon, color: context.sc.primary, size: 20),
              ),
              const SizedBox(width: SphereSpacing.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.sc.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: context.sc.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
