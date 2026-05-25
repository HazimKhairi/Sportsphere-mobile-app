import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../role_pick/presentation/role_providers.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  int _tab = 0;
  bool _saving = false;
  bool _uploadingCert = false;

  // ── Personal (shared) ───────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  DateTime? _dob;
  String? _gender;
  final _nationalityCtrl = TextEditingController();
  final _icCtrl = TextEditingController();

  // ── Playing (player-only) ───────────────────────────────────────────────────
  final _positionCtrl = TextEditingController();
  final _position2Ctrl = TextEditingController();
  final _jerseyCtrl = TextEditingController();
  String? _dominantFoot;
  final _schoolCtrl = TextEditingController();

  // ── Professional (staff-only) ───────────────────────────────────────────────
  final _staffRoleCtrl = TextEditingController();
  String? _jerseySize;
  final _achievementsCtrl = TextEditingController();
  List<String> _certUrls = [];

  // ── Contact (shared base) ───────────────────────────────────────────────────
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Player contact extras
  final _guardian1Ctrl = TextEditingController();
  final _guardian1PhoneCtrl = TextEditingController();

  // Staff contact extras
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text =
        ref.read(currentUserProvider).valueOrNull?.displayName ?? '';
    _load(ref.read(currentUserProvider).valueOrNull?.uid);
  }

  bool get _isStaff => ref.read(selectedRoleProvider) == AppRole.staff;

  Future<void> _load(String? uid) async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists || !mounted) return;
    final d = doc.data() ?? {};

    // Personal
    _nationalityCtrl.text = d['nationality'] as String? ?? '';
    _icCtrl.text = d['icNumber'] as String? ?? '';
    _gender = d['gender'] as String?;
    final dobStr = d['dateOfBirth'] as String?;
    if (dobStr != null) _dob = DateTime.tryParse(dobStr);

    if (_isStaff) {
      // Professional
      _staffRoleCtrl.text = d['staffRole'] as String? ?? '';
      _jerseySize = d['jerseySize'] as String?;
      _achievementsCtrl.text = d['achievements'] as String? ?? '';
      final rawUrls = d['certUrls'];
      if (rawUrls is List) {
        _certUrls = rawUrls.whereType<String>().toList();
      }
      // Contact
      _phoneCtrl.text = d['phone'] as String? ?? '';
      _addressCtrl.text = d['address'] as String? ?? '';
      _emergencyNameCtrl.text = d['emergencyName'] as String? ?? '';
      _emergencyPhoneCtrl.text = d['emergencyPhone'] as String? ?? '';
    } else {
      // Playing
      _positionCtrl.text = d['position'] as String? ?? '';
      _position2Ctrl.text = d['position2'] as String? ?? '';
      _jerseyCtrl.text =
          d['jerseyNumber'] != null ? '${d['jerseyNumber']}' : '';
      _dominantFoot = d['dominantFoot'] as String?;
      _schoolCtrl.text = d['school'] as String? ?? '';
      // Contact
      _phoneCtrl.text = d['phone'] as String? ?? '';
      _addressCtrl.text = d['address'] as String? ?? '';
      _guardian1Ctrl.text = d['parentName'] as String? ?? '';
      _guardian1PhoneCtrl.text = d['parentPhone'] as String? ?? '';
    }

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
    _staffRoleCtrl.dispose();
    _achievementsCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _guardian1Ctrl.dispose();
    _guardian1PhoneCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 28),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickAndUploadCert() async {
    final picker = ImagePicker();
    final source = await _askImageSource();
    if (source == null || !mounted) return;

    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingCert = true);
    try {
      final uid = ref.read(currentUserProvider).valueOrNull?.uid;
      if (uid == null) throw Exception('Not signed in');
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref2 = FirebaseStorage.instance
          .ref('staffDocuments/$uid/$ts.jpg');
      await ref2.putFile(File(file.path));
      final url = await ref2.getDownloadURL();
      setState(() {
        _certUrls = [..._certUrls, url];
        _uploadingCert = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingCert = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Future<ImageSource?> _askImageSource() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.sc.surfaceElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(AppLocalizations.of(context)!.photoLibrary),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removeCert(String url) {
    setState(() => _certUrls = _certUrls.where((u) => u != url).toList());
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

      final Map<String, dynamic> data = {
        if (name.isNotEmpty) 'displayName': name,
        if (_dob != null)
          'dateOfBirth': _dob!.toIso8601String().substring(0, 10),
        if (_gender != null) 'gender': _gender,
        if (_nationalityCtrl.text.trim().isNotEmpty)
          'nationality': _nationalityCtrl.text.trim(),
        if (_icCtrl.text.trim().isNotEmpty)
          'icNumber': _icCtrl.text.trim(),
        if (_phoneCtrl.text.trim().isNotEmpty)
          'phone': _phoneCtrl.text.trim(),
        if (_addressCtrl.text.trim().isNotEmpty)
          'address': _addressCtrl.text.trim(),
      };

      if (_isStaff) {
        if (_staffRoleCtrl.text.trim().isNotEmpty) { data['staffRole'] = _staffRoleCtrl.text.trim(); }
        if (_jerseySize != null) { data['jerseySize'] = _jerseySize; }
        if (_achievementsCtrl.text.trim().isNotEmpty) { data['achievements'] = _achievementsCtrl.text.trim(); }
        data['certUrls'] = _certUrls;
        if (_emergencyNameCtrl.text.trim().isNotEmpty) { data['emergencyName'] = _emergencyNameCtrl.text.trim(); }
        if (_emergencyPhoneCtrl.text.trim().isNotEmpty) { data['emergencyPhone'] = _emergencyPhoneCtrl.text.trim(); }
      } else {
        if (_positionCtrl.text.trim().isNotEmpty) { data['position'] = _positionCtrl.text.trim(); }
        if (_position2Ctrl.text.trim().isNotEmpty) { data['position2'] = _position2Ctrl.text.trim(); }
        final jerseyRaw = int.tryParse(_jerseyCtrl.text.trim());
        if (jerseyRaw != null) { data['jerseyNumber'] = jerseyRaw; }
        if (_dominantFoot != null) { data['dominantFoot'] = _dominantFoot; }
        if (_schoolCtrl.text.trim().isNotEmpty) { data['school'] = _schoolCtrl.text.trim(); }
        if (_guardian1Ctrl.text.trim().isNotEmpty) { data['parentName'] = _guardian1Ctrl.text.trim(); }
        if (_guardian1PhoneCtrl.text.trim().isNotEmpty) { data['parentPhone'] = _guardian1PhoneCtrl.text.trim(); }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
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

  List<String> get _tabLabels => _isStaff
      ? ['Personal', 'Professional', 'Contact']
      : ['Personal', 'Playing', 'Contact'];

  @override
  Widget build(BuildContext context) {
    return SphereFieldBackground(
      child: Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
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
                      Text(AppLocalizations.of(context)!.editProfile,
                          style: Theme.of(context).textTheme.displayLarge),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x20),

                // ── Category pills ─────────────────────────────────────────
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: SphereSpacing.x24),
                    itemCount: _tabLabels.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => _Pill(
                      label: _tabLabels[i],
                      selected: _tab == i,
                      onTap: () => setState(() => _tab = i),
                    ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x20),

                // ── Tab content ────────────────────────────────────────────
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
                          if (_tab == 0)
                            _PersonalTab(
                              nameCtrl: _nameCtrl,
                              dob: _dob,
                              gender: _gender,
                              nationalityCtrl: _nationalityCtrl,
                              icCtrl: _icCtrl,
                              onPickDob: _pickDob,
                              onGenderChanged: (v) =>
                                  setState(() => _gender = v),
                            ),
                          if (_tab == 1 && _isStaff)
                            _ProfessionalTab(
                              staffRoleCtrl: _staffRoleCtrl,
                              jerseySize: _jerseySize,
                              achievementsCtrl: _achievementsCtrl,
                              certUrls: _certUrls,
                              uploading: _uploadingCert,
                              onJerseySizeChanged: (v) =>
                                  setState(() => _jerseySize = v),
                              onAddCert: _pickAndUploadCert,
                              onRemoveCert: _removeCert,
                            ),
                          if (_tab == 1 && !_isStaff)
                            _PlayingTab(
                              positionCtrl: _positionCtrl,
                              position2Ctrl: _position2Ctrl,
                              jerseyCtrl: _jerseyCtrl,
                              dominantFoot: _dominantFoot,
                              schoolCtrl: _schoolCtrl,
                              onFootChanged: (v) =>
                                  setState(() => _dominantFoot = v),
                            ),
                          if (_tab == 2 && _isStaff)
                            _ContactTab(
                              phoneCtrl: _phoneCtrl,
                              addressCtrl: _addressCtrl,
                              isStaff: true,
                              emergencyNameCtrl: _emergencyNameCtrl,
                              emergencyPhoneCtrl: _emergencyPhoneCtrl,
                            ),
                          if (_tab == 2 && !_isStaff)
                            _ContactTab(
                              phoneCtrl: _phoneCtrl,
                              addressCtrl: _addressCtrl,
                              isStaff: false,
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

          // ── Save button ──────────────────────────────────────────────────
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
                                AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.saveChanges),
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

// ─── Category pill ────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.selected, required this.onTap});
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
          color: selected ? context.sc.primary : context.sc.surfaceElev1,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? context.sc.primary : context.sc.borderSubtle,
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
          key: ValueKey(gender),
          initialValue: gender,
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

// ─── Tab: Professional (staff-only) ──────────────────────────────────────────

class _ProfessionalTab extends StatelessWidget {
  const _ProfessionalTab({
    required this.staffRoleCtrl,
    required this.jerseySize,
    required this.achievementsCtrl,
    required this.certUrls,
    required this.uploading,
    required this.onJerseySizeChanged,
    required this.onAddCert,
    required this.onRemoveCert,
  });

  final TextEditingController staffRoleCtrl;
  final String? jerseySize;
  final TextEditingController achievementsCtrl;
  final List<String> certUrls;
  final bool uploading;
  final ValueChanged<String?> onJerseySizeChanged;
  final VoidCallback onAddCert;
  final ValueChanged<String> onRemoveCert;

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('PROFESSIONAL INFO'),
        const _Label('Role / Title'),
        TextFormField(
          controller: staffRoleCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. Head Coach, Assistant Coach, Physio',
            prefixIcon: Icon(LucideIcons.briefcase, size: 18),
          ),
        ),
        _gap,
        const _Label('Jersey size'),
        DropdownButtonFormField<String>(
          key: ValueKey(jerseySize),
          initialValue: jerseySize,
          decoration: const InputDecoration(
            prefixIcon: Icon(LucideIcons.shirt, size: 18),
          ),
          hint: const Text('Select size'),
          items: _sizes
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onJerseySizeChanged,
        ),
        _gap,
        const _SectionLabel('ACHIEVEMENTS'),
        const _Label('Previous achievements'),
        TextFormField(
          controller: achievementsCtrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText:
                'e.g. Coached U-17 national squad 2022, FAM Coaching Licence holder...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 64),
              child: Icon(LucideIcons.trophy, size: 18),
            ),
            alignLabelWithHint: true,
          ),
        ),
        _gap,
        const _SectionLabel('CERTIFICATES & LICENCES'),
        const _Label('Upload documents'),
        const SizedBox(height: 4),
        _CertGrid(
          urls: certUrls,
          uploading: uploading,
          onAdd: onAddCert,
          onRemove: onRemoveCert,
        ),
      ],
    );
  }
}

// ─── Certificate grid ─────────────────────────────────────────────────────────

class _CertGrid extends StatelessWidget {
  const _CertGrid({
    required this.urls,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> urls;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final url in urls)
          _CertThumbnail(url: url, onRemove: () => onRemove(url)),
        if (uploading)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.sc.surfaceElev1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.sc.borderSubtle),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.sc.primary,
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: uploading ? null : onAdd,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.sc.surfaceElev1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.sc.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(LucideIcons.plus,
                  size: 22, color: context.sc.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _CertThumbnail extends StatelessWidget {
  const _CertThumbnail({required this.url, required this.onRemove});
  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 80,
              height: 80,
              color: context.sc.surfaceElev1,
              child: Icon(LucideIcons.fileText,
                  size: 28, color: context.sc.onSurfaceMuted),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: context.sc.danger,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.x,
                  size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tab: Playing (player-only) ───────────────────────────────────────────────

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
          key: ValueKey(dominantFoot),
          initialValue: dominantFoot,
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
    required this.isStaff,
    this.emergencyNameCtrl,
    this.emergencyPhoneCtrl,
    this.guardian1Ctrl,
    this.guardian1PhoneCtrl,
  });

  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final bool isStaff;
  final TextEditingController? emergencyNameCtrl;
  final TextEditingController? emergencyPhoneCtrl;
  final TextEditingController? guardian1Ctrl;
  final TextEditingController? guardian1PhoneCtrl;

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
        if (isStaff) ...[
          const _SectionLabel('EMERGENCY CONTACT'),
          const _Label('Name'),
          TextFormField(
            controller: emergencyNameCtrl,
            decoration: const InputDecoration(
              hintText: 'Full name',
              prefixIcon: Icon(LucideIcons.userCheck, size: 18),
            ),
          ),
          _gap,
          const _Label('Phone number'),
          TextFormField(
            controller: emergencyPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'e.g. 0123456789',
              prefixIcon: Icon(LucideIcons.phoneCall, size: 18),
            ),
          ),
        ] else ...[
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
      ],
    );
  }
}
