import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';

class DrillCompleteScreen extends StatefulWidget {
  const DrillCompleteScreen({
    super.key,
    required this.drillId,
    required this.reps,
    this.streakDays = 0,
  });
  final String drillId;
  final int reps;
  final int streakDays;

  @override
  State<DrillCompleteScreen> createState() => _DrillCompleteScreenState();
}

class _DrillCompleteScreenState extends State<DrillCompleteScreen>
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
    HapticFeedback.heavyImpact();
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
      backgroundColor: Colors.transparent,
      body: SphereFieldBackground(child: SafeArea(
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
                    final entry =
                        Curves.easeOutBack.transform(_entryCtrl.value);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 220 + pulse * 20,
                          height: 220 + pulse * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.sc.primary
                                .withValues(alpha: 0.06 + pulse * 0.04),
                          ),
                        ),
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
                              LucideIcons.flame,
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
                      AppLocalizations.of(context)!.drillComplete,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: context.sc.onSurface,
                          ),
                    ),
                    const SizedBox(height: SphereSpacing.x8),
                    Text(
                      '${widget.reps} reps in the bag.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                    if (widget.streakDays > 0) ...[
                      const SizedBox(height: SphereSpacing.x24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SphereSpacing.x20,
                          vertical: SphereSpacing.x12,
                        ),
                        decoration: BoxDecoration(
                          color: context.sc.primary.withValues(alpha: 0.18),
                          borderRadius: SphereRadius.pillRect,
                          border: Border.all(
                            color: context.sc.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.flame,
                              size: 16,
                              color: context.sc.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.streakDays}-day streak',
                              style: TextStyle(
                                color: context.sc.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        onPressed: () => context.go('/train'),
                        icon: const Icon(LucideIcons.dumbbell, size: 18),
                        label: Text(AppLocalizations.of(context)!.backToDrills),
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
                          side: BorderSide(
                            color: context.sc.borderSubtle,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: SphereRadius.pillRect,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.goHome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
