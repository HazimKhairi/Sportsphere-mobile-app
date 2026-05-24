import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/recovery_log.dart';
import 'recovery_providers.dart';

class WellnessCheckInScreen extends ConsumerStatefulWidget {
  const WellnessCheckInScreen({super.key});

  @override
  ConsumerState<WellnessCheckInScreen> createState() =>
      _WellnessCheckInScreenState();
}

class _WellnessCheckInScreenState extends ConsumerState<WellnessCheckInScreen> {
  double _fatigue = 4;
  double _sleep = 4;
  double _soreness = 4;
  double _stress = 4;
  double _mood = 4;
  bool _saving = false;

  int get _score => RecoveryLog.computeScore(
        _fatigue.round(),
        _sleep.round(),
        _soreness.round(),
        _stress.round(),
        _mood.round(),
      );

  Color get _scoreColor {
    if (_score >= 70) return const Color(0xFF37F513);
    if (_score >= 50) return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) {
      setState(() => _saving = false);
      return;
    }
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final log = RecoveryLog(
      id: '',
      date: now,
      dateStr: dateStr,
      fatigue: _fatigue.round(),
      sleepQuality: _sleep.round(),
      muscleSoreness: _soreness.round(),
      stress: _stress.round(),
      mood: _mood.round(),
      wellnessScore: _score,
    );
    await ref.read(recoveryRepositoryProvider).saveLog(uid, log);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.dailyWellness,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '$_score%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _scoreColor,
                      ),
                ),
              ),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.wellnessScore,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              _HooperSlider(
                label: AppLocalizations.of(context)!.sleepQuality,
                description: '1 = very restful · 7 = insomnia',
                value: _sleep,
                onChanged: (v) => setState(() => _sleep = v),
              ),
              _HooperSlider(
                label: AppLocalizations.of(context)!.fatigue,
                description: '1 = very fresh · 7 = very tired',
                value: _fatigue,
                onChanged: (v) => setState(() => _fatigue = v),
              ),
              _HooperSlider(
                label: AppLocalizations.of(context)!.muscleSoreness,
                description: '1 = no soreness · 7 = very sore',
                value: _soreness,
                onChanged: (v) => setState(() => _soreness = v),
              ),
              _HooperSlider(
                label: AppLocalizations.of(context)!.stress,
                description: '1 = very relaxed · 7 = highly stressed',
                value: _stress,
                onChanged: (v) => setState(() => _stress = v),
              ),
              _HooperSlider(
                label: AppLocalizations.of(context)!.mood,
                description: '1 = very positive · 7 = highly irritable',
                value: _mood,
                onChanged: (v) => setState(() => _mood = v),
              ),
              const SizedBox(height: SphereSpacing.x24),
              Text(
                'Based on the Hooper Index (Hooper & Mackinnon, 1995). For general guidance only — not a medical assessment.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                      fontSize: 10,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.saveCheckIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HooperSlider extends StatelessWidget {
  const _HooperSlider({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF8B5CF6);
    return Padding(
      padding: const EdgeInsets.only(bottom: SphereSpacing.x20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${value.round()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  fontSize: 10,
                ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              thumbColor: accent,
              inactiveTrackColor: accent.withValues(alpha: 0.2),
              overlayColor: accent.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 7,
              divisions: 6,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
