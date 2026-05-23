import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../domain/scouting_profile.dart';
import 'scout_providers.dart';

class ScoutEditScreen extends ConsumerStatefulWidget {
  const ScoutEditScreen({super.key});

  @override
  ConsumerState<ScoutEditScreen> createState() => _ScoutEditScreenState();
}

class _ScoutEditScreenState extends ConsumerState<ScoutEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _achievementsCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();

  // State
  String _state = kMalaysianStates.first;
  String _city = '';
  String _sport = 'football';
  String _primaryPosition = kFootballPositions.first;
  final List<String> _secondaryPositions = [];
  String? _foot;
  int _yearsPlaying = 1;
  String _level = 'recreational';
  bool _weekday = false;
  bool _weekend = true;
  int _hoursPerWeek = 5;
  int _travelRadius = 50;
  bool _paidTrials = false;
  final Map<String, double> _skills = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  void _loadExisting() {
    final profile = ref.read(scoutProfileNotifierProvider).valueOrNull;
    if (profile == null) return;
    _nameCtrl.text = profile.displayName;
    _dobCtrl.text = profile.dob;
    _achievementsCtrl.text = profile.achievements ?? '';
    _videoCtrl.text = profile.highlightVideoUrl ?? '';
    setState(() {
      _state = profile.state;
      _city = profile.city ?? '';
      _sport = profile.sport;
      _primaryPosition = profile.primaryPosition;
      _secondaryPositions
        ..clear()
        ..addAll(profile.secondaryPositions);
      _foot = profile.foot;
      _yearsPlaying = profile.yearsPlaying;
      _level = profile.level;
      _weekday = profile.availability.weekday;
      _weekend = profile.availability.weekend;
      _hoursPerWeek = profile.availability.hoursPerWeek;
      _travelRadius = profile.availability.travelRadiusKm;
      _paidTrials = profile.availability.paidTrialsAccepted;
      _skills
        ..clear()
        ..addAll(profile.skills);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _achievementsCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  List<String> get _positions =>
      _sport == 'futsal' ? kFutsalPositions : kFootballPositions;

  List<String> get _skillKeys =>
      _sport == 'futsal' ? kFutsalSkills : kFootballSkills;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    // Sync skills — fill missing keys with 0
    final skillMap = {
      for (final k in _skillKeys) k: _skills[k] ?? 0.0,
    };

    final existing = ref.read(scoutProfileNotifierProvider).valueOrNull;

    final profile = ScoutingProfile(
      displayName: _nameCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      state: _state,
      city: _city.trim().isEmpty ? null : _city.trim(),
      sport: _sport,
      primaryPosition: _primaryPosition,
      secondaryPositions: List.from(_secondaryPositions),
      foot: _foot,
      yearsPlaying: _yearsPlaying,
      pastClubs: existing?.pastClubs ?? [],
      achievements: _achievementsCtrl.text.trim().isEmpty
          ? null
          : _achievementsCtrl.text.trim(),
      level: _level,
      skills: skillMap,
      highlightVideoUrl: _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
      actionPhotoUrls: existing?.actionPhotoUrls ?? [],
      availability: ScoutingAvailability(
        weekday: _weekday,
        weekend: _weekend,
        hoursPerWeek: _hoursPerWeek,
        travelRadiusKm: _travelRadius,
        paidTrialsAccepted: _paidTrials,
      ),
      visibility: existing?.visibility ?? 'hidden',
      reach: existing?.reach ?? 'state',
      affiliation: existing?.affiliation ??
          const ScoutingAffiliation(type: 'free_agent'),
    );

    try {
      await ref.read(scoutProfileNotifierProvider.notifier).save(profile);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: SphereColors.background,
      appBar: AppBar(
        title: const Text('Edit Scout Profile'),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(title: 'Basic Info', icon: LucideIcons.user),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  _field(
                    controller: _nameCtrl,
                    label: 'Display Name',
                    validator: (v) =>
                        (v ?? '').length < 2 ? 'Min 2 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _dobCtrl,
                    label: 'Date of Birth (yyyy-mm-dd)',
                    hint: '2000-01-15',
                    keyboardType: TextInputType.datetime,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
                        return 'Format: yyyy-mm-dd';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _Dropdown<String>(
                    label: 'State',
                    value: _state,
                    items: kMalaysianStates
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _state = v!),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    initialValue: _city,
                    label: 'City (optional)',
                    onChanged: (v) => _city = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Sport & Position', icon: LucideIcons.dumbbell),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  _Dropdown<String>(
                    label: 'Sport',
                    value: _sport,
                    items: const [
                      DropdownMenuItem(value: 'football', child: Text('Football')),
                      DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _sport = v!;
                        _primaryPosition = _positions.first;
                        _secondaryPositions.clear();
                        _skills.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _Dropdown<String>(
                    label: 'Primary Position',
                    value: _primaryPosition,
                    items: _positions
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _primaryPosition = v!),
                  ),
                  const SizedBox(height: 12),
                  _Dropdown<String>(
                    label: 'Preferred Foot',
                    value: _foot ?? '',
                    items: const [
                      DropdownMenuItem(value: '', child: Text('— Not specified —')),
                      DropdownMenuItem(value: 'left', child: Text('Left')),
                      DropdownMenuItem(value: 'right', child: Text('Right')),
                      DropdownMenuItem(value: 'both', child: Text('Both')),
                    ],
                    onChanged: (v) =>
                        setState(() => _foot = (v ?? '').isEmpty ? null : v),
                  ),
                  const SizedBox(height: 12),
                  _Dropdown<String>(
                    label: 'Level',
                    value: _level,
                    items: kScoutingLevelLabels.entries
                        .map((e) =>
                            DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _level = v!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Years playing:',
                          style: tt.bodyMedium
                              ?.copyWith(color: SphereColors.onSurfaceMuted)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: _yearsPlaying.toDouble(),
                          min: 0,
                          max: 20,
                          divisions: 20,
                          label: '$_yearsPlaying',
                          activeColor: SphereColors.primary,
                          onChanged: (v) =>
                              setState(() => _yearsPlaying = v.round()),
                        ),
                      ),
                      Text('$_yearsPlaying yrs', style: tt.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Self-Rate Skills', icon: LucideIcons.zap),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: _skillKeys.map((key) {
                  final val = _skills[key] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            key[0].toUpperCase() + key.substring(1),
                            style: tt.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: val,
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: val == 0 ? 'Not rated' : '${val.round()}',
                            activeColor: SphereColors.primary,
                            onChanged: (v) =>
                                setState(() => _skills[key] = v),
                          ),
                        ),
                        Text(
                          val == 0 ? '–' : '${val.round()}/5',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Availability', icon: LucideIcons.clock),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Available weekdays'),
                    value: _weekday,
                    activeThumbColor: SphereColors.primary,
                    onChanged: (v) => setState(() => _weekday = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Available weekends'),
                    value: _weekend,
                    activeThumbColor: SphereColors.primary,
                    onChanged: (v) => setState(() => _weekend = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Accept paid trials'),
                    value: _paidTrials,
                    activeThumbColor: SphereColors.primary,
                    onChanged: (v) => setState(() => _paidTrials = v),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Text('Hours/week:', style: tt.bodyMedium?.copyWith(color: SphereColors.onSurfaceMuted)),
                      Expanded(
                        child: Slider(
                          value: _hoursPerWeek.toDouble(),
                          min: 0,
                          max: 40,
                          divisions: 40,
                          label: '$_hoursPerWeek',
                          activeColor: SphereColors.primary,
                          onChanged: (v) => setState(() => _hoursPerWeek = v.round()),
                        ),
                      ),
                      Text('$_hoursPerWeek h', style: tt.bodySmall),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Travel radius:', style: tt.bodyMedium?.copyWith(color: SphereColors.onSurfaceMuted)),
                      Expanded(
                        child: Slider(
                          value: _travelRadius.toDouble(),
                          min: 0,
                          max: 200,
                          divisions: 20,
                          label: '${_travelRadius}km',
                          activeColor: SphereColors.primary,
                          onChanged: (v) => setState(() => _travelRadius = v.round()),
                        ),
                      ),
                      Text('${_travelRadius}km', style: tt.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Media & Achievements', icon: LucideIcons.video),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  _field(
                    controller: _videoCtrl,
                    label: 'Highlight Video URL (optional)',
                    hint: 'https://youtube.com/...',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _achievementsCtrl,
                    label: 'Achievements (optional)',
                    hint: 'MSSM state champion 2023, top scorer...',
                    maxLines: 4,
                    maxLength: 500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Profile'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SphereColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: child,
    );
  }

  Widget _field({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
  }) {
    if (controller != null) {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
      );
    }
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: SphereColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
    );
  }
}
