import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  int _tab = 0;
  bool _saving = false;

  // Personal
  final _nameCtrl = TextEditingController();
  DateTime? _dob;
  String? _gender;
  final _nationalityCtrl = TextEditingController();
  final _icCtrl = TextEditingController();

  // Playing
  final _positionCtrl = TextEditingController();
  final _position2Ctrl = TextEditingController();
  final _jerseyCtrl = TextEditingController();
  String? _dominantFoot;
  final _schoolCtrl = TextEditingController();

  // Contact
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _guardian1Ctrl = TextEditingController();
  final _guardian1PhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    _nameCtrl.text = ref.read(currentUserProvider).valueOrNull?.displayName ?? '';
    _load(uid);
  }

  Future<void> _load(String? uid) async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || !mounted) return;
    final d = doc.data() ?? {};

    _nationalityCtrl.text = d['nationality'] as String? ?? '';
    _icCtrl.text = d['icNumber'] as String? ?? '';
    _gender = d['gender'] as String?;

    final dobStr = d['dateOfBirth'] as String?;
    if (dobStr != null) {
      _dob = DateTime.tryParse(dobStr);
    }

    _positionCtrl.text = d['position'] as String? ?? '';
    _position2Ctrl.text = d['position2'] as String? ?? '';
    _jerseyCtrl.text = (d['jerseyNumber'] != null) ? '${d['jerseyNumber']}' : '';
    _dominantFoot = d['dominantFoot'] as String?;
    _schoolCtrl.text = d['school'] as String? ?? '';

    _phoneCtrl.text = d['phone'] as String? ?? '';
    _addressCtrl.text = d['address'] as String? ?? '';
    _guardian1Ctrl.text = d['parentName'] as String? ?? '';
    _guardian1PhoneCtrl.text = d['parentPhone'] as String? ?? '';

    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nationalityCtrl.dispose();
    _icCtrl.dispose();
    _positionCtrl.dispose();
    _position2Ctrl.dispose();
    _jerseyCtrl.dispose();
    _schoolCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _guardian1Ctrl.dispose();
    _guardian1PhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 16),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final uid = ref.read(currentUserProvider).valueOrNull?.uid;
      if (uid == null) throw Exception('Not signed in');

      final name = _nameCtrl.text.trim();
      if (name.isNotEmpty) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      }

      final jerseyRaw = int.tryParse(_jerseyCtrl.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        if (name.isNotEmpty) 'displayName': name,
        if (_dob != null) 'dateOfBirth': _dob!.toIso8601String().substring(0, 10),
        if (_gender != null) 'gender': _gender,
        if (_nationalityCtrl.text.trim().isNotEmpty) 'nationality': _nationalityCtrl.text.trim(),
        if (_icCtrl.text.trim().isNotEmpty) 'icNumber': _icCtrl.text.trim(),
        if (_positionCtrl.text.trim().isNotEmpty) 'position': _positionCtrl.text.trim(),
        if (_position2Ctrl.text.trim().isNotEmpty) 'position2': _position2Ctrl.text.trim(),
        if (jerseyRaw != null) 'jerseyNumber': jerseyRaw,
        if (_dominantFoot != null) 'dominantFoot': _dominantFoot,
        if (_schoolCtrl.text.trim().isNotEmpty) 'school': _schoolCtrl.text.trim(),
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        if (_addressCtrl.text.trim().isNotEmpty) 'address': _addressCtrl.text.trim(),
        if (_guardian1Ctrl.text.trim().isNotEmpty) 'parentName': _guardian1Ctrl.text.trim(),
        if (_guardian1PhoneCtrl.text.trim().isNotEmpty) 'parentPhone': _guardian1PhoneCtrl.text.trim(),
      }, SetOptions(merge: true));

      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated.')),
        );
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SphereSpacing.x24,
                    SphereSpacing.x16,
                    SphereSpacing.x24,
                    0,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: context.sc.surfaceElev1,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => context.canPop()
                              ? context.pop()
                              : context.go('/profile'),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(LucideIcons.chevronLeft,
                                size: 20, color: context.sc.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Text('Edit Profile',
                          style: Theme.of(context).textTheme.displayLarge),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x20),

                // ── Category pills ────────────────────────────────────────
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: SphereSpacing.x24),
                    children: [
                      _Pill(label: 'Personal', selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0)),
                      const SizedBox(width: 8),
                      _Pill(label: 'Playing', selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1)),
                      const SizedBox(width: 8),
                      _Pill(label: 'Contact', selected: _tab == 2,
                          onTap: () => setState(() => _tab = 2)),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x20),

                // ── Tab content ───────────────────────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: SingleChildScrollView(
                      key: ValueKey(_tab),
                      padding: const EdgeInsets.fromLTRB(
                          SphereSpacing.x24, 0, SphereSpacing.x24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_tab == 0) _PersonalTab(
                            nameCtrl: _nameCtrl,
                            dob: _dob,
                            gender: _gender,
                            nationalityCtrl: _nationalityCtrl,
                            icCtrl: _icCtrl,
                            onPickDob: _pickDob,
                            onGenderChanged: (v) => setState(() => _gender = v),
                          ),
                          if (_tab == 1) _PlayingTab(
                            positionCtrl: _positionCtrl,
                            position2Ctrl: _position2Ctrl,
                            jerseyCtrl: _jerseyCtrl,
                            dominantFoot: _dominantFoot,
                            schoolCtrl: _schoolCtrl,
                            onFootChanged: (v) => setState(() => _dominantFoot = v),
                          ),
                          if (_tab == 2) _ContactTab(
                            phoneCtrl: _phoneCtrl,
                            addressCtrl: _addressCtrl,
                            guardian1Ctrl: _guardian1Ctrl,
                            guardian1PhoneCtrl: _guardian1PhoneCtrl,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating save button ─────────────────────────────────────────
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  SphereSpacing.x24, 12, SphereSpacing.x24, 16),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.black)),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Category pill ────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? context.sc.primary
              : context.sc.surfaceElev1,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? context.sc.primary
                : context.sc.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? context.sc.onPrimary : context.sc.onSurface,
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

// ─── Field label ─────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

const _gap = SizedBox(height: SphereSpacing.x20);

// ─── Tab: Personal ────────────────────────────────────────────────────────────

class _PersonalTab extends StatelessWidget {
  const _PersonalTab({
    required this.nameCtrl,
    required this.dob,
    required this.gender,
    required this.nationalityCtrl,
    required this.icCtrl,
    required this.onPickDob,
    required this.onGenderChanged,
  });

  final TextEditingController nameCtrl;
  final DateTime? dob;
  final String? gender;
  final TextEditingController nationalityCtrl;
  final TextEditingController icCtrl;
  final VoidCallback onPickDob;
  final ValueChanged<String?> onGenderChanged;

  String _formatDob(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('PERSONAL DETAILS'),
        const _Label('Full name'),
        TextFormField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            hintText: 'Your full name',
            prefixIcon: Icon(LucideIcons.user, size: 18),
          ),
        ),
        _gap,
        const _Label('Date of birth'),
        GestureDetector(
          onTap: onPickDob,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              controller: TextEditingController(
                  text: dob != null ? _formatDob(dob!) : ''),
              decoration: const InputDecoration(
                hintText: 'Select date',
                prefixIcon: Icon(LucideIcons.calendar, size: 18),
                suffixIcon: Icon(LucideIcons.chevronDown, size: 16),
              ),
            ),
          ),
        ),
        _gap,
        const _Label('Gender'),
        DropdownButtonFormField<String>(
          value: gender,
          decoration: const InputDecoration(
            prefixIcon: Icon(LucideIcons.users, size: 18),
          ),
          hint: const Text('Select gender'),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
          ],
          onChanged: onGenderChanged,
        ),
        _gap,
        const _Label('Nationality'),
        TextFormField(
          controller: nationalityCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. Malaysian',
            prefixIcon: Icon(LucideIcons.globe, size: 18),
          ),
        ),
        _gap,
        const _Label('IC / MyKid number'),
        TextFormField(
          controller: icCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'e.g. 010102020304',
            prefixIcon: Icon(LucideIcons.idCard, size: 18),
          ),
        ),
      ],
    );
  }
}

// ─── Tab: Playing ─────────────────────────────────────────────────────────────

class _PlayingTab extends StatelessWidget {
  const _PlayingTab({
    required this.positionCtrl,
    required this.position2Ctrl,
    required this.jerseyCtrl,
    required this.dominantFoot,
    required this.schoolCtrl,
    required this.onFootChanged,
  });

  final TextEditingController positionCtrl;
  final TextEditingController position2Ctrl;
  final TextEditingController jerseyCtrl;
  final String? dominantFoot;
  final TextEditingController schoolCtrl;
  final ValueChanged<String?> onFootChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('PLAYING INFO'),
        const _Label('Primary position'),
        TextFormField(
          controller: positionCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. Striker, Midfielder',
            prefixIcon: Icon(LucideIcons.crosshair, size: 18),
          ),
        ),
        _gap,
        const _Label('Secondary position'),
        TextFormField(
          controller: position2Ctrl,
          decoration: const InputDecoration(
            hintText: 'Optional',
            prefixIcon: Icon(LucideIcons.crosshair, size: 18),
          ),
        ),
        _gap,
        const _Label('Jersey number'),
        TextFormField(
          controller: jerseyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'e.g. 10',
            prefixIcon: Icon(LucideIcons.hash, size: 18),
          ),
        ),
        _gap,
        const _Label('Dominant foot'),
        DropdownButtonFormField<String>(
          value: dominantFoot,
          decoration: const InputDecoration(
            prefixIcon: Icon(LucideIcons.footprints, size: 18),
          ),
          hint: const Text('Select foot'),
          items: const [
            DropdownMenuItem(value: 'Left', child: Text('Left')),
            DropdownMenuItem(value: 'Right', child: Text('Right')),
            DropdownMenuItem(value: 'Both', child: Text('Both')),
          ],
          onChanged: onFootChanged,
        ),
        _gap,
        const _Label('School'),
        TextFormField(
          controller: schoolCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. SMK Shah Alam',
            prefixIcon: Icon(LucideIcons.school, size: 18),
          ),
        ),
      ],
    );
  }
}

// ─── Tab: Contact ─────────────────────────────────────────────────────────────

class _ContactTab extends StatelessWidget {
  const _ContactTab({
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.guardian1Ctrl,
    required this.guardian1PhoneCtrl,
  });

  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController guardian1Ctrl;
  final TextEditingController guardian1PhoneCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('CONTACT'),
        const _Label('Phone number'),
        TextFormField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'e.g. 0123456789',
            prefixIcon: Icon(LucideIcons.phone, size: 18),
          ),
        ),
        _gap,
        const _Label('Address'),
        TextFormField(
          controller: addressCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Your home address',
            prefixIcon: Icon(LucideIcons.mapPin, size: 18),
          ),
        ),
        const SizedBox(height: SphereSpacing.x32),
        const _SectionLabel('PARENT / GUARDIAN'),
        const _Label('Guardian name'),
        TextFormField(
          controller: guardian1Ctrl,
          decoration: const InputDecoration(
            hintText: 'Full name',
            prefixIcon: Icon(LucideIcons.user, size: 18),
          ),
        ),
        _gap,
        const _Label('Guardian phone'),
        TextFormField(
          controller: guardian1PhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'e.g. 0123456789',
            prefixIcon: Icon(LucideIcons.phone, size: 18),
          ),
        ),
      ],
    );
  }
}
