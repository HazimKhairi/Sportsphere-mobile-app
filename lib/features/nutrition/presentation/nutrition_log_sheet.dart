import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../data/nutrition_repository.dart';
import 'nutrition_providers.dart';

class NutritionLogSheet {
  NutritionLogSheet._();

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final container = ProviderScope.containerOf(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UncontrolledProviderScope(
        container: container,
        child: const _NutritionLogSheetContent(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet Content
// ---------------------------------------------------------------------------

class _NutritionLogSheetContent extends ConsumerStatefulWidget {
  const _NutritionLogSheetContent();

  @override
  ConsumerState<_NutritionLogSheetContent> createState() =>
      _NutritionLogSheetContentState();
}

enum _LogMode { photo, text }

class _NutritionLogSheetContentState
    extends ConsumerState<_NutritionLogSheetContent> {
  _LogMode _mode = _LogMode.photo;
  MealType _mealType = MealType.breakfast;
  bool _analysing = false;
  NutritionLog? _result;
  String? _errorMsg;
  XFile? _pickedImage;
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    _mealType = hour < 10
        ? MealType.breakfast
        : hour < 14
            ? MealType.lunch
            : hour < 19
                ? MealType.dinner
                : MealType.snack;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyseText() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) return;
    setState(() {
      _analysing = true;
      _errorMsg = null;
    });
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        setState(() {
          _errorMsg = 'Not signed in. Please log in again.';
          _analysing = false;
        });
        return;
      }
      final log = await ref.read(nutritionRepositoryProvider).logMeal(
            description: desc,
            mealType: _mealType,
            authToken: token,
          );
      setState(() {
        _result = log;
        _analysing = false;
      });
    } on NutritionException catch (e) {
      setState(() {
        _errorMsg = e.message;
        _analysing = false;
      });
    } catch (_) {
      setState(() {
        _errorMsg = 'Something went wrong. Please try again.';
        _analysing = false;
      });
    }
  }

  Future<void> _analyse() async {
    if (_pickedImage == null) return;
    setState(() {
      _analysing = true;
      _errorMsg = null;
    });
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        setState(() {
          _errorMsg = 'Not signed in. Please log in again.';
          _analysing = false;
        });
        return;
      }

      final bytes = await _pickedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final ext = _pickedImage!.name.split('.').last.toLowerCase();
      final mimeType =
          (ext == 'jpeg' || ext == 'jpg') ? 'image/jpeg' : 'image/png';

      final log = await ref.read(nutritionRepositoryProvider).analyzePhoto(
            base64Image: base64Image,
            mimeType: mimeType,
            mealType: _mealType,
            authToken: token,
          );

      setState(() {
        _result = log;
        _analysing = false;
      });
    } on NutritionException catch (e) {
      setState(() {
        _errorMsg = e.message;
        _analysing = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Something went wrong. Please try again.';
        _analysing = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
        _errorMsg = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          SphereSpacing.x24,
          SphereSpacing.x16,
          SphereSpacing.x24,
          SphereSpacing.x24,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.sc.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SphereSpacing.x16),
              Text(
                'Log Meal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x20),
              if (_result == null) _buildStep1(context) else _buildStep2(context),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 — pick meal type + photo
  // ---------------------------------------------------------------------------

  Widget _buildStep1(BuildContext context) {
    final canAnalyse = _mode == _LogMode.photo
        ? _pickedImage != null && !_analysing
        : _descCtrl.text.trim().isNotEmpty && !_analysing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode toggle
        Row(
          children: [
            Expanded(
              child: _ModeTab(
                label: 'Photo',
                icon: LucideIcons.camera,
                selected: _mode == _LogMode.photo,
                onTap: () => setState(() {
                  _mode = _LogMode.photo;
                  _errorMsg = null;
                }),
              ),
            ),
            const SizedBox(width: SphereSpacing.x8),
            Expanded(
              child: _ModeTab(
                label: 'Type it in',
                icon: LucideIcons.pencilLine,
                selected: _mode == _LogMode.text,
                onTap: () => setState(() {
                  _mode = _LogMode.text;
                  _errorMsg = null;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: SphereSpacing.x20),
        Text(
          'Meal type',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurfaceMuted,
              ),
        ),
        const SizedBox(height: SphereSpacing.x8),
        _MealTypePicker(
          selected: _mealType,
          onChanged: (t) => setState(() => _mealType = t),
        ),
        const SizedBox(height: SphereSpacing.x20),
        if (_mode == _LogMode.photo) ...[
          Text(
            'Photo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x8),
          if (_pickedImage == null)
            _PhotoPickerRow(onPick: _pickImage)
          else
            _ImagePreview(
              file: File(_pickedImage!.path),
              onRemove: () => setState(() => _pickedImage = null),
            ),
        ] else ...[
          Text(
            'What did you eat?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x8),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'e.g. nasi lemak dengan ayam goreng, teh tarik',
              filled: true,
              fillColor: context.sc.surface,
              border: OutlineInputBorder(
                borderRadius: SphereRadius.cardRect,
                borderSide: BorderSide(color: context.sc.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: SphereRadius.cardRect,
                borderSide: BorderSide(color: context.sc.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SphereRadius.cardRect,
                borderSide: BorderSide(color: context.sc.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(SphereSpacing.x12),
            ),
          ),
        ],
        if (_errorMsg != null) ...[
          const SizedBox(height: SphereSpacing.x8),
          Text(
            _errorMsg!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.danger,
                ),
          ),
        ],
        const SizedBox(height: SphereSpacing.x20),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton(
            onPressed: canAnalyse
                ? (_mode == _LogMode.photo ? _analyse : _analyseText)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: context.sc.primary,
              foregroundColor: context.sc.onPrimary,
              shape: const RoundedRectangleBorder(
                borderRadius: SphereRadius.pillRect,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _analysing
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(context.sc.onPrimary),
                    ),
                  )
                : const Text('Analyse'),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 — review analysis result
  // ---------------------------------------------------------------------------

  Widget _buildStep2(BuildContext context) {
    final result = _result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnalysisResultCard(result: result),
        const SizedBox(height: SphereSpacing.x12),
        if (result.recommendation != null)
          Text(
            result.recommendation!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
        const SizedBox(height: SphereSpacing.x24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _result = null;
                      _pickedImage = null;
                      _descCtrl.clear();
                      _errorMsg = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    side: BorderSide(color: context.sc.borderSubtle),
                    foregroundColor: context.sc.onSurface,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Retake'),
                ),
              ),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.sc.primary,
                    foregroundColor: context.sc.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mode Tab
// ---------------------------------------------------------------------------

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.sc.primary : context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(
            color: selected ? context.sc.primary : context.sc.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.black : context.sc.onSurfaceMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.black : context.sc.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo Picker Row
// ---------------------------------------------------------------------------

class _PhotoPickerRow extends StatelessWidget {
  const _PhotoPickerRow({required this.onPick});
  final void Function(ImageSource) onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => onPick(ImageSource.camera),
              icon: const Icon(LucideIcons.camera, size: 16),
              label: const Text('Camera'),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: SphereRadius.cardRect,
                ),
                side: BorderSide(color: context.sc.borderSubtle),
                foregroundColor: context.sc.onSurface,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: SphereSpacing.x12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => onPick(ImageSource.gallery),
              icon: const Icon(LucideIcons.image, size: 16),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: SphereRadius.cardRect,
                ),
                side: BorderSide(color: context.sc.borderSubtle),
                foregroundColor: context.sc.onSurface,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Image Preview
// ---------------------------------------------------------------------------

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.file, required this.onRemove});
  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: SphereRadius.cardRect,
          child: Image.file(
            file,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.x, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Meal Type Picker
// ---------------------------------------------------------------------------

class _MealTypePicker extends StatelessWidget {
  const _MealTypePicker({
    required this.selected,
    required this.onChanged,
  });
  final MealType selected;
  final ValueChanged<MealType> onChanged;

  String _label(MealType t) => switch (t) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MealType.values.map((t) {
        final isSelected = t == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: t != MealType.snack ? SphereSpacing.x8 : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.sc.primary
                      : context.sc.surfaceElev1,
                  borderRadius: SphereRadius.cardRect,
                  border: Border.all(
                    color: isSelected
                        ? context.sc.primary
                        : context.sc.borderSubtle,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _label(t),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: isSelected
                            ? Colors.black
                            : context.sc.onSurfaceMuted,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Analysis Result Card
// ---------------------------------------------------------------------------

class _AnalysisResultCard extends StatelessWidget {
  const _AnalysisResultCard({required this.result});
  final NutritionLog result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foods detected',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: SphereSpacing.x8),
          for (final food in result.foods) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '${food.name} (${food.estimatedGrams.toInt()}g) — ${food.calories.toInt()} kcal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurface,
                    ),
              ),
            ),
          ],
          Divider(
            color: context.sc.borderSubtle,
            height: SphereSpacing.x24,
          ),
          // Macro pills
          Wrap(
            spacing: SphereSpacing.x8,
            runSpacing: SphereSpacing.x8,
            children: [
              _ResultMacroPill(
                icon: LucideIcons.dumbbell,
                label: '${result.totalProteinG.toStringAsFixed(1)}g',
                sublabel: 'Protein',
                accent: const Color(0xFF3B82F6),
              ),
              _ResultMacroPill(
                icon: LucideIcons.droplets,
                label: '${result.totalFatG.toStringAsFixed(1)}g',
                sublabel: 'Fat',
                accent: const Color(0xFFF59E0B),
              ),
              _ResultMacroPill(
                icon: LucideIcons.zap,
                label: '${result.totalCarbsG.toStringAsFixed(1)}g',
                sublabel: 'Carbs',
                accent: const Color(0xFF8B5CF6),
              ),
              _ResultMacroPill(
                icon: LucideIcons.leaf,
                label: '${result.totalFibreG.toStringAsFixed(1)}g',
                sublabel: 'Fibre',
                accent: const Color(0xFF37F513),
              ),
            ],
          ),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            '${result.totalCalories.toInt()} kcal total',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.sc.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class _ResultMacroPill extends StatelessWidget {
  const _ResultMacroPill({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.sc.onSurface,
                    ),
              ),
              Text(
                sublabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
