import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/staff_home_providers.dart';
import 'staff_training_providers.dart';

class CreateTrainingPlanScreen extends ConsumerStatefulWidget {
  const CreateTrainingPlanScreen({super.key});

  @override
  ConsumerState<CreateTrainingPlanScreen> createState() =>
      _CreateTrainingPlanScreenState();
}

class _CreateTrainingPlanScreenState
    extends ConsumerState<CreateTrainingPlanScreen> {
  final _titleCtrl = TextEditingController();
  final _weeksCtrl = TextEditingController(text: '6');
  String _phase = 'inseason';
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _weeksCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a plan title.')));
      return;
    }

    final weeks = int.tryParse(_weeksCtrl.text.trim());
    if (weeks == null || weeks < 1 || weeks > 52) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a valid duration (1–52 weeks).')));
      return;
    }

    final clubId = ref.read(activeClubIdProvider).valueOrNull;
    if (clubId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No club selected.')));
      return;
    }

    setState(() => _saving = true);

    try {
      await ref.read(staffTrainingRepositoryProvider).createTrainingPlan(
            clubId: clubId,
            title: title,
            phase: _phase,
            totalWeeks: weeks,
          );

      setState(() => _saving = false);
      ref.invalidate(staffTrainingPlansProvider);
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l.newTrainingPlan),
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
      body: SphereFieldBackground(child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleCtrl,
                autofocus: true,
                decoration: InputDecoration(labelText: l.planTitle),
              ),
              const SizedBox(height: SphereSpacing.x16),
              DropdownButtonFormField<String>(
                initialValue: _phase,
                decoration: const InputDecoration(labelText: 'Phase'),
                items: const [
                  DropdownMenuItem(
                      value: 'preseason', child: Text('Preseason')),
                  DropdownMenuItem(value: 'inseason', child: Text('Inseason')),
                  DropdownMenuItem(
                      value: 'offseason', child: Text('Offseason')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _phase = val);
                },
              ),
              const SizedBox(height: SphereSpacing.x16),
              TextField(
                controller: _weeksCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l.durationWeeks),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
