import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import 'active_workout_providers.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.templateId});
  final String templateId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _restTimer;
  final _repsController = TextEditingController(text: '8');
  final _weightController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    WakelockPlus.disable();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    ref.read(activeWorkoutProvider.notifier).startRest(seconds);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = ref.read(activeWorkoutProvider);
      if (state.restSecondsLeft <= 1) {
        _restTimer?.cancel();
        ref.read(activeWorkoutProvider.notifier).endRest();
        HapticFeedback.heavyImpact();
      } else {
        ref.read(activeWorkoutProvider.notifier).tickRest();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.activeWorkout,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SphereFieldBackground(child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (workoutState.isResting)
                _RestTimerCard(
                  secondsLeft: workoutState.restSecondsLeft,
                  onSkip: () {
                    _restTimer?.cancel();
                    ref.read(activeWorkoutProvider.notifier).endRest();
                  },
                ),
              Text(
                AppLocalizations.of(context)!.logSet,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x16),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: AppLocalizations.of(context)!.reps,
                      controller: _repsController,
                    ),
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Expanded(
                    child: _NumberField(
                      label: AppLocalizations.of(context)!.weightKg,
                      controller: _weightController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SphereSpacing.x16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final reps = int.tryParse(_repsController.text) ?? 0;
                    final weight = double.tryParse(_weightController.text) ?? 0;
                    ref.read(activeWorkoutProvider.notifier).logSet(
                          exerciseId: widget.templateId,
                          reps: reps,
                          weightKg: weight,
                        );
                    HapticFeedback.mediumImpact();
                    _startRestTimer(90);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.sc.warning,
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x16),
                  ),
                  child: Text(AppLocalizations.of(context)!.logSetStartRest),
                ),
              ),
              const SizedBox(height: SphereSpacing.x24),
              if (workoutState.sets.isNotEmpty)
                Text(
                  '${workoutState.sets.length} sets logged',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
            ],
          ),
        ),
      )),
    );
  }
}

class _RestTimerCard extends StatelessWidget {
  const _RestTimerCard({required this.secondsLeft, required this.onSkip});
  final int secondsLeft;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SphereSpacing.x20),
      margin: const EdgeInsets.only(bottom: SphereSpacing.x24),
      decoration: BoxDecoration(
        color: context.sc.warning.withValues(alpha: 0.12),
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.restSeconds,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.warning,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            '${secondsLeft}s',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: context.sc.warning,
                  fontWeight: FontWeight.w900,
                ),
          ),
          TextButton(
            onPressed: onSkip,
            child: Text(AppLocalizations.of(context)!.skipRest),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurfaceMuted,
              ),
        ),
        const SizedBox(height: SphereSpacing.x4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.sc.surfaceElev1,
            border: OutlineInputBorder(
              borderRadius: SphereRadius.cardRect,
              borderSide: BorderSide(color: context.sc.borderSubtle),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: SphereSpacing.x12),
          ),
        ),
      ],
    );
  }
}
