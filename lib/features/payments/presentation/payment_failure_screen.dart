import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';

class PaymentFailureScreen extends StatefulWidget {
  const PaymentFailureScreen({super.key, this.reason});
  final String? reason;

  @override
  State<PaymentFailureScreen> createState() => _PaymentFailureScreenState();
}

class _PaymentFailureScreenState extends State<PaymentFailureScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reasonText = (widget.reason ?? '').isEmpty
        ? 'Something went wrong. Please try again.'
        : widget.reason!;

    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final t = _shakeCtrl.value;
                  final shake = (t * 4) % 1.0;
                  final dx = shake < 0.5
                      ? -1 + shake * 4
                      : 1 - (shake - 0.5) * 4;
                  return Transform.translate(
                    offset: Offset(t == 0 ? 0 : dx * 6, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SphereColors.danger.withValues(alpha: 0.16),
                    border: Border.all(
                      color: SphereColors.danger.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    size: 56,
                    color: SphereColors.danger,
                  ),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              Text(
                'Payment failed',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: SphereColors.onSurface,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x8),
              Text(
                reasonText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                      height: 1.4,
                    ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/programs');
                    }
                  },
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
                  child: const Text('Try again'),
                ),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SphereColors.onSurface,
                    side: const BorderSide(color: SphereColors.borderSubtle),
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                  ),
                  child: const Text(
                    'Back to home',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
