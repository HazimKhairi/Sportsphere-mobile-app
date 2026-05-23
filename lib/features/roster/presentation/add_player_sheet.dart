import 'package:flutter/material.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';

class AddPlayerSheet extends StatefulWidget {
  const AddPlayerSheet({super.key, required this.onSubmit});

  final Future<void> Function({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? position,
  }) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String firstName,
      required String lastName,
      String? email,
      String? phone,
      String? position,
    }) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.sc.surfaceElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddPlayerSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<AddPlayerSheet> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _position = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _position.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        position:
            _position.text.trim().isEmpty ? null : _position.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e
            .toString()
            .replaceAll('RosterException(400): ', '')
            .replaceAll('RosterException(null): ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: SphereSpacing.x24,
        right: SphereSpacing.x24,
        top: SphereSpacing.x24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.sc.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add player',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Required: first and last name.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.sc.onSurfaceMuted),
          ),
          const SizedBox(height: 20),

          // First + last name side by side
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('First name'),
                    const SizedBox(height: 6),
                    _Input(controller: _firstName, hint: 'First'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Last name'),
                    const SizedBox(height: 6),
                    _Input(controller: _lastName, hint: 'Last'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Email'),
          const SizedBox(height: 6),
          _Input(
            controller: _email,
            hint: 'player@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Phone'),
          const SizedBox(height: 6),
          _Input(
            controller: _phone,
            hint: '+601X-XXXXXXX',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Position'),
          const SizedBox(height: 6),
          _Input(
            controller: _position,
            hint: 'e.g. Midfielder',
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: context.sc.danger,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Submit button — reactive to required fields via ListenableBuilder
          ListenableBuilder(
            listenable: Listenable.merge([_firstName, _lastName]),
            builder: (context, _) {
              final canSubmit = !_busy &&
                  _firstName.text.trim().isNotEmpty &&
                  _lastName.text.trim().isNotEmpty;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.sc.primary,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    elevation: 0,
                    disabledBackgroundColor:
                        context.sc.primary.withValues(alpha: 0.4),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : const Text(
                          'Add player',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private design primitives (self-contained, not shared)
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.sc.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.sc.surfaceElev2,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: context.sc.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.sc.onSurfaceMuted),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
