import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../l10n/app_localizations.dart';
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

  // Career history
  final List<PastClubEntry> _pastClubs = [];
  final List<RepresentativeEntry> _repHistory = [];
  final List<TournamentEntry> _tournamentHistory = [];

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
      _pastClubs..clear()..addAll(profile.pastClubs);
      _repHistory..clear()..addAll(profile.representativeHistory);
      _tournamentHistory..clear()..addAll(profile.tournamentHistory);
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
      pastClubs: List.from(_pastClubs),
      representativeHistory: List.from(_repHistory),
      tournamentHistory: List.from(_tournamentHistory),
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

  Future<void> _showAddClubSheet() async {
    final nameCtrl = TextEditingController();
    final fromYearCtrl = TextEditingController(text: '${DateTime.now().year}');
    final toYearCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    String? sport;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Past Club',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Club Name *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: fromYearCtrl,
                      decoration: const InputDecoration(labelText: 'From Year *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: toYearCtrl,
                      decoration: const InputDecoration(labelText: 'To Year (optional)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Role (optional)',
                  hintText: 'e.g. Captain, Striker',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: sport,
                decoration: const InputDecoration(labelText: 'Sport (optional)'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('— Not specified —')),
                  DropdownMenuItem(value: 'football', child: Text('Football')),
                  DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setSheet(() => sport = v),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final fromYear = int.tryParse(fromYearCtrl.text.trim()) ??
                          DateTime.now().year;
                      final toYear = toYearCtrl.text.trim().isEmpty
                          ? null
                          : int.tryParse(toYearCtrl.text.trim());
                      final role = roleCtrl.text.trim().isEmpty
                          ? null
                          : roleCtrl.text.trim();
                      setState(() {
                        _pastClubs.add(PastClubEntry(
                          name: name,
                          fromYear: fromYear,
                          toYear: toYear,
                          role: role,
                          sport: sport,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddRepSheet() async {
    String level = kRepresentativeLevelLabels.keys.first;
    final teamNameCtrl = TextEditingController();
    String sport = 'football';
    final yearCtrl = TextEditingController(text: '${DateTime.now().year}');
    String? achievement;
    final notesCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Representative History',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: level,
                  decoration: const InputDecoration(labelText: 'Level *'),
                  items: kRepresentativeLevelLabels.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => setSheet(() => level = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: teamNameCtrl,
                  decoration: const InputDecoration(labelText: 'Team Name *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: sport,
                  decoration: const InputDecoration(labelText: 'Sport *'),
                  items: const [
                    DropdownMenuItem(value: 'football', child: Text('Football')),
                    DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setSheet(() => sport = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearCtrl,
                  decoration: const InputDecoration(labelText: 'Year *'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: achievement,
                  decoration: const InputDecoration(labelText: 'Achievement (optional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...kAchievementLabels.entries.map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        )),
                  ],
                  onChanged: (v) => setSheet(() => achievement = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final teamName = teamNameCtrl.text.trim();
                        if (teamName.isEmpty) return;
                        final year = int.tryParse(yearCtrl.text.trim()) ??
                            DateTime.now().year;
                        final notes = notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim();
                        setState(() {
                          _repHistory.add(RepresentativeEntry(
                            level: level,
                            teamName: teamName,
                            sport: sport,
                            year: year,
                            achievement: achievement,
                            notes: notes,
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddTournamentSheet() async {
    final nameCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '${DateTime.now().year}');
    String sport = 'football';
    final organiserCtrl = TextEditingController();
    String? achievement;
    final notesCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Tournament',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tournament Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearCtrl,
                  decoration: const InputDecoration(labelText: 'Year *'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: sport,
                  decoration: const InputDecoration(labelText: 'Sport *'),
                  items: const [
                    DropdownMenuItem(value: 'football', child: Text('Football')),
                    DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setSheet(() => sport = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: organiserCtrl,
                  decoration: const InputDecoration(labelText: 'Organiser (optional)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: achievement,
                  decoration: const InputDecoration(labelText: 'Achievement (optional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...kAchievementLabels.entries.map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        )),
                  ],
                  onChanged: (v) => setSheet(() => achievement = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final year = int.tryParse(yearCtrl.text.trim()) ??
                            DateTime.now().year;
                        final organiser = organiserCtrl.text.trim().isEmpty
                            ? null
                            : organiserCtrl.text.trim();
                        final notes = notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim();
                        setState(() {
                          _tournamentHistory.add(TournamentEntry(
                            name: name,
                            year: year,
                            sport: sport,
                            organiser: organiser,
                            achievement: achievement,
                            notes: notes,
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l.editScoutProfile),
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
                  child: Text(l.save),
                ),
        ],
      ),
      body: SphereFieldBackground(child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(title: 'Basic Info', icon: LucideIcons.user),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  _field(
                    controller: _nameCtrl,
                    label: l.displayName,
                    validator: (v) =>
                        (v ?? '').length < 2 ? l.nameMinChars : null,
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
            const _SectionHeader(title: 'Sport & Position', icon: LucideIcons.dumbbell),
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
                              ?.copyWith(color: context.sc.onSurfaceMuted)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: _yearsPlaying.toDouble(),
                          min: 0,
                          max: 20,
                          divisions: 20,
                          label: '$_yearsPlaying',
                          activeColor: context.sc.primary,
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
            _SectionHeader(title: l.selfRateSkills, icon: LucideIcons.zap),
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
                            activeColor: context.sc.primary,
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
            _SectionHeader(title: l.availability, icon: LucideIcons.clock),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.availableWeekdays),
                    value: _weekday,
                    activeThumbColor: context.sc.primary,
                    onChanged: (v) => setState(() => _weekday = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.availableWeekends),
                    value: _weekend,
                    activeThumbColor: context.sc.primary,
                    onChanged: (v) => setState(() => _weekend = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Accept paid trials'),
                    value: _paidTrials,
                    activeThumbColor: context.sc.primary,
                    onChanged: (v) => setState(() => _paidTrials = v),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Text('Hours/week:', style: tt.bodyMedium?.copyWith(color: context.sc.onSurfaceMuted)),
                      Expanded(
                        child: Slider(
                          value: _hoursPerWeek.toDouble(),
                          min: 0,
                          max: 40,
                          divisions: 40,
                          label: '$_hoursPerWeek',
                          activeColor: context.sc.primary,
                          onChanged: (v) => setState(() => _hoursPerWeek = v.round()),
                        ),
                      ),
                      Text('$_hoursPerWeek h', style: tt.bodySmall),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Travel radius:', style: tt.bodyMedium?.copyWith(color: context.sc.onSurfaceMuted)),
                      Expanded(
                        child: Slider(
                          value: _travelRadius.toDouble(),
                          min: 0,
                          max: 200,
                          divisions: 20,
                          label: '${_travelRadius}km',
                          activeColor: context.sc.primary,
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
            const _SectionHeader(title: 'Media & Achievements', icon: LucideIcons.video),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  _field(
                    controller: _videoCtrl,
                    label: l.highlightVideoUrl,
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
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Past Clubs', icon: LucideIcons.building2),
            const SizedBox(height: 12),
            _card(
              child: _CareerListSection<PastClubEntry>(
                items: _pastClubs,
                emptyLabel: 'No clubs added yet',
                itemBuilder: (club) => Text(
                  '${club.name} (${club.fromYear}${club.toYear != null ? '–${club.toYear}' : '–present'})${club.role != null ? ' · ${club.role}' : ''}',
                ),
                onDelete: (i) => setState(() => _pastClubs.removeAt(i)),
                onAdd: () => _showAddClubSheet(),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Representative History', icon: LucideIcons.medal),
            const SizedBox(height: 12),
            _card(
              child: _CareerListSection<RepresentativeEntry>(
                items: _repHistory,
                emptyLabel: 'No representative experience added',
                itemBuilder: (e) => Text(
                  '${kRepresentativeLevelLabels[e.level] ?? e.level} · ${e.teamName} (${e.year})',
                ),
                onDelete: (i) => setState(() => _repHistory.removeAt(i)),
                onAdd: () => _showAddRepSheet(),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Tournament History', icon: LucideIcons.trophy),
            const SizedBox(height: 12),
            _card(
              child: _CareerListSection<TournamentEntry>(
                items: _tournamentHistory,
                emptyLabel: 'No tournaments added',
                itemBuilder: (e) => Text(
                  '${e.name} (${e.year})${e.achievement != null ? ' · ${kAchievementLabels[e.achievement] ?? e.achievement}' : ''}',
                ),
                onDelete: (i) => setState(() => _tournamentHistory.removeAt(i)),
                onAdd: () => _showAddTournamentSheet(),
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
                  : Text(l.saveProfile),
            ),
            const SizedBox(height: 32),
          ],
        ),
      )),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.sc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sc.borderSubtle),
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

class _CareerListSection<T> extends StatelessWidget {
  const _CareerListSection({
    required this.items,
    required this.emptyLabel,
    required this.itemBuilder,
    required this.onDelete,
    required this.onAdd,
  });
  final List<T> items;
  final String emptyLabel;
  final Widget Function(T) itemBuilder;
  final void Function(int) onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(emptyLabel,
                style: TextStyle(color: context.sc.onSurfaceMuted, fontSize: 13)),
          ),
        ...items.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(child: itemBuilder(entry.value)),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 16),
                color: context.sc.onSurfaceMuted,
                onPressed: () => onDelete(entry.key),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        )),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(LucideIcons.plus, size: 14),
          label: const Text('Add'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
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
        Icon(icon, size: 16, color: context.sc.primary),
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
