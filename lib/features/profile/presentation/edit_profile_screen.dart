import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _positionCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _phoneCtrl = TextEditingController();
    _positionCtrl = TextEditingController();
    _loadExtras(user?.uid);
  }

  Future<void> _loadExtras(String? uid) async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || !mounted) return;
    final data = doc.data() ?? {};
    _phoneCtrl.text = (data['phone'] as String?) ?? '';
    _positionCtrl.text = (data['position'] as String?) ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final uid = ref.read(currentUserProvider).valueOrNull?.uid;
      if (uid == null) throw Exception('Not signed in');

      final name = _nameCtrl.text.trim();
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'displayName': name,
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        if (_positionCtrl.text.trim().isNotEmpty) 'position': _positionCtrl.text.trim(),
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
              children: [
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
                          onTap: () => context.canPop() ? context.pop() : context.go('/profile'),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(LucideIcons.chevronLeft, size: 20, color: context.sc.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        SphereSpacing.x24,
                        SphereSpacing.x24,
                        SphereSpacing.x24,
                        120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Display name'),
                          const SizedBox(height: 6),
                          _SphereTextField(
                            controller: _nameCtrl,
                            hint: 'Your full name',
                            icon: LucideIcons.user,
                            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
                          ),
                          const SizedBox(height: SphereSpacing.x20),
                          _FieldLabel('Phone number'),
                          const SizedBox(height: 6),
                          _SphereTextField(
                            controller: _phoneCtrl,
                            hint: 'e.g. 0123456789',
                            icon: LucideIcons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: SphereSpacing.x20),
                          _FieldLabel('Position'),
                          const SizedBox(height: 6),
                          _SphereTextField(
                            controller: _positionCtrl,
                            hint: 'e.g. Forward, Midfielder',
                            icon: LucideIcons.shirt,
                          ),
                          const SizedBox(height: SphereSpacing.x32),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
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
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.black),
                                      ),
                                    )
                                  : const Text('Save changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.sc.onSurfaceMuted,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _SphereTextField extends StatelessWidget {
  const _SphereTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
      ),
    );
  }
}
