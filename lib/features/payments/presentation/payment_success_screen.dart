import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key, required this.registrationId});
  final String registrationId;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sc.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                width: 240,
                height: 240,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_entryCtrl, _pulseCtrl]),
                  builder: (context, _) {
                    final pulse = Curves.easeInOut.transform(_pulseCtrl.value);
                    final entry = Curves.easeOutBack.transform(_entryCtrl.value);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse ring
                        Container(
                          width: 220 + pulse * 20,
                          height: 220 + pulse * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.sc.primary
                                .withValues(alpha: 0.06 + pulse * 0.04),
                          ),
                        ),
                        // Middle ring
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.sc.primary.withValues(alpha: 0.14),
                            border: Border.all(
                              color: context.sc.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        // Solid disc + check
                        Transform.scale(
                          scale: entry,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.sc.primary,
                            ),
                            child: Icon(
                              LucideIcons.check,
                              size: 56,
                              color: context.sc.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryCtrl,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                ),
                child: Column(
                  children: [
                    Text(
                      "You're in",
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: context.sc.onSurface,
                              ),
                    ),
                    const SizedBox(height: SphereSpacing.x8),
                    Text(
                      'Your registration is confirmed. We sent a receipt to your email.',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.sc.onSurfaceMuted,
                                height: 1.4,
                              ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryCtrl,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(
                          '/profile/payments/${widget.registrationId}',
                        ),
                        icon: const Icon(LucideIcons.fileText, size: 18),
                        label: const Text('View receipt'),
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
                        child: const Text(
                          'Back to home',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
