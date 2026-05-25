import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_field_background.dart';
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

    final l = AppLocalizations.of(context)!;
    return SphereFieldBackground(
      child: Scaffold(
      backgroundColor: Colors.transparent,
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
                    color: context.sc.danger.withValues(alpha: 0.16),
                    border: Border.all(
                      color: context.sc.danger.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.x,
                    size: 56,
                    color: context.sc.danger,
                  ),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              Text(
                l.paymentFailed,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: context.sc.onSurface,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x8),
              Text(
                reasonText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurfaceMuted,
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
                    backgroundColor: context.sc.primary,
                    foregroundColor: context.sc.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l.tryAgain),
                ),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.sc.onSurface,
                    side: BorderSide(color: context.sc.borderSubtle),
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                  ),
                  child: Text(
                    l.backToHome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
