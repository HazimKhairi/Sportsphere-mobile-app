import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../body_composition_providers.dart';

class BodyCompositionAddSheet extends ConsumerStatefulWidget {
  const BodyCompositionAddSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const BodyCompositionAddSheet(),
      ),
    );
  }

  @override
  ConsumerState<BodyCompositionAddSheet> createState() =>
      _BodyCompositionAddSheetState();
}

class _BodyCompositionAddSheetState
    extends ConsumerState<BodyCompositionAddSheet> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _bodyFat = TextEditingController();
  final _muscle = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _bodyFat.dispose();
    _muscle.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final raw = c.text.trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final w = _parse(_weight);
    final h = _parse(_height);
    final bf = _parse(_bodyFat);
    final mm = _parse(_muscle);

    if (w == null && h == null && bf == null && mm == null) {
      setState(() => _error = 'Enter at least one value.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(bodyCompositionRepositoryProvider).addEntry(
            playerId: user.uid,
            weightKg: w,
            heightCm: h,
            bodyFatPct: bf,
            muscleMassKg: mm,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = 'Could not save: $e';
      });
    }
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
                'Log body composition',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Fill any field you have. Skip the rest.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x24),
              Row(
                children: [
                  Expanded(
                    child: _NumField(
                      controller: _weight,
                      label: 'Weight (kg)',
                      icon: LucideIcons.weight,
                    ),
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Expanded(
                    child: _NumField(
                      controller: _height,
                      label: 'Height (cm)',
                      icon: LucideIcons.ruler,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SphereSpacing.x16),
              Row(
                children: [
                  Expanded(
                    child: _NumField(
                      controller: _bodyFat,
                      label: 'Body fat (%)',
                      icon: LucideIcons.percent,
                    ),
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Expanded(
                    child: _NumField(
                      controller: _muscle,
                      label: 'Muscle (kg)',
                      icon: LucideIcons.activity,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: SphereSpacing.x12),
                Text(
                  _error!,
                  style: TextStyle(color: context.sc.danger),
                ),
              ],
              const SizedBox(height: SphereSpacing.x24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: _busy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(context.sc.onPrimary),
                          ),
                        )
                      : const Icon(LucideIcons.check, size: 18),
                  label: const Text('Save entry'),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.label,
    required this.icon,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.sc.surfaceElev1,
            borderRadius: SphereRadius.pillRect,
            border: Border.all(color: context.sc.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: context.sc.onSurfaceMuted),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: context.sc.onSurface),
                  decoration: InputDecoration(
                    hintText: '-',
                    hintStyle: TextStyle(color: context.sc.onSurfaceMuted),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
