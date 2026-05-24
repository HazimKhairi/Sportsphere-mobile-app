import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../../strength/domain/workout_template.dart';
import 'staff_training_providers.dart';

class _ExerciseEntry {
  _ExerciseEntry({
    required this.nameCtrl,
    required this.setsCtrl,
    required this.repsCtrl,
  });

  factory _ExerciseEntry.createNew() => _ExerciseEntry(
        nameCtrl: TextEditingController(),
        setsCtrl: TextEditingController(text: '3'),
        repsCtrl: TextEditingController(text: '8'),
      );

  final TextEditingController nameCtrl;
  final TextEditingController setsCtrl;
  final TextEditingController repsCtrl;

  void dispose() {
    nameCtrl.dispose();
    setsCtrl.dispose();
    repsCtrl.dispose();
  }
}

class CreateWorkoutTemplateScreen extends ConsumerStatefulWidget {
  const CreateWorkoutTemplateScreen({super.key});

  @override
  ConsumerState<CreateWorkoutTemplateScreen> createState() =>
      _CreateWorkoutTemplateScreenState();
}

class _CreateWorkoutTemplateScreenState
    extends ConsumerState<CreateWorkoutTemplateScreen> {
  final _titleCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController(text: '45');
  final List<_ExerciseEntry> _exercises = [];
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _minutesCtrl.dispose();
    for (final e in _exercises) {
      e.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() => _exercises.add(_ExerciseEntry.createNew()));
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final minutesStr = _minutesCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a template title.')));
      return;
    }

    final minutes = int.tryParse(minutesStr);
    if (minutes == null || minutes <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a valid duration.')));
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one exercise.')));
      return;
    }

    final clubId = ref.read(activeClubIdProvider).valueOrNull;
    if (clubId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No club selected.')));
      return;
    }

    setState(() => _saving = true);

    try {
      final templateExercises = _exercises.map((e) {
        final name = e.nameCtrl.text.trim();
        final sets = int.tryParse(e.setsCtrl.text.trim()) ?? 3;
        final reps = int.tryParse(e.repsCtrl.text.trim()) ?? 8;
        return TemplateExercise(
          exerciseId: name.isEmpty ? 'Exercise' : name,
          sets: sets,
          reps: reps,
        );
      }).toList();

      await ref.read(staffTrainingRepositoryProvider).createWorkoutTemplate(
            clubId: clubId,
            title: title,
            estimatedMinutes: minutes,
            exercises: templateExercises,
          );

      setState(() => _saving = false);
      ref.invalidate(staffWorkoutTemplatesProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l.newWorkoutTemplate),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.save),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: InputDecoration(labelText: l.templateTitle),
              ),
              const SizedBox(height: SphereSpacing.x16),
              TextField(
                controller: _minutesCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l.estDurationMin),
              ),
              const SizedBox(height: SphereSpacing.x32),
              Row(
                children: [
                  Text(
                    l.exercises,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: Text(l.add),
                  ),
                ],
              ),
              const SizedBox(height: SphereSpacing.x12),
              if (_exercises.isEmpty)
                Center(
                  child: Text(
                    l.noExercisesAdded,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                )
              else
                Column(
                  children: List.generate(
                    _exercises.length,
                    (i) => _ExerciseRow(
                      entry: _exercises[i],
                      onRemove: () => _removeExercise(i),
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

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.entry, required this.onRemove});

  final _ExerciseEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SphereSpacing.x12),
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.nameCtrl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.exerciseName),
                ),
              ),
              const SizedBox(width: SphereSpacing.x8),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: onRemove,
                color: context.sc.onSurfaceMuted,
              ),
            ],
          ),
          const SizedBox(height: SphereSpacing.x8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.setsCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.sets),
                ),
              ),
              const SizedBox(width: SphereSpacing.x8),
              Expanded(
                child: TextField(
                  controller: entry.repsCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.reps),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
