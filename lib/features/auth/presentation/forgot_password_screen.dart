import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import 'auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _busy = false;
  bool _success = false;
  String? _error;

  Future<void> _submit() async {
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(email: email);
      if (mounted) setState(() => _success = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'user-not-found') {
        // Do not leak user existence — show success anyway.
        setState(() => _success = true);
      } else if (e.code == 'invalid-email') {
        setState(() => _error = 'Please enter a valid email address.');
      } else {
        setState(() => _error = e.message ?? 'Something went wrong. Try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sc.surface,
      body: Stack(
        children: [
          // Hero image background.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/brand/login_hero.webp',
                  fit: BoxFit.cover,
                ),
                // Dark overlay so wordmark + back button remain legible.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.sc.surface.withValues(alpha: 0.55),
                        context.sc.surface.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hero overlay: back button + wordmark.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SphereSpacing.x16,
                  vertical: SphereSpacing.x8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconButton(
                      icon: LucideIcons.chevronLeft,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(
                      height: 28,
                      child: Image.asset(
                        'assets/brand/sphere_wordmark.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sliding card.
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.sc.surfaceElev1,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(
                    color: context.sc.primary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.sc.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                  const BoxShadow(
                    color: Color(0xCC000000),
                    blurRadius: 24,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SphereSpacing.x24,
                    SphereSpacing.x32,
                    SphereSpacing.x24,
                    SphereSpacing.x24,
                  ),
                  child: _success ? _SuccessContent(email: _email.text.trim()) : _FormContent(
                    email: _email,
                    busy: _busy,
                    error: _error,
                    onSubmit: _busy ? null : _submit,
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

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.email,
    required this.busy,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController email;
  final bool busy;
  final String? error;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.forgotPassword,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: SphereSpacing.x8),
        Text(
          "Enter your email and we'll send you a reset link.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.sc.onSurfaceMuted,
              ),
        ),
        const SizedBox(height: SphereSpacing.x24),
        _FieldLabel(AppLocalizations.of(context)!.email),
        const SizedBox(height: 6),
        _SphereInput(
          controller: email,
          hint: AppLocalizations.of(context)!.enterYourEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        if (error != null) ...[
          const SizedBox(height: SphereSpacing.x12),
          Text(
            error!,
            style: TextStyle(color: context.sc.danger),
          ),
        ],
        const SizedBox(height: SphereSpacing.x24),
        _PillButton(
          label: AppLocalizations.of(context)!.sendResetLink,
          busy: busy,
          onTap: onSubmit,
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Icon(
            LucideIcons.checkCircle2,
            size: 40,
            color: context.sc.primary,
          ),
        ),
        const SizedBox(height: SphereSpacing.x20),
        Text(
          AppLocalizations.of(context)!.checkYourInbox,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SphereSpacing.x12),
        Text(
          'A reset link has been sent to $email.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.sc.onSurfaceMuted,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private design primitives (self-contained, not shared)
// ---------------------------------------------------------------------------

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: context.sc.onSurface),
        ),
      ),
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
            color: context.sc.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
    );
  }
}

class _SphereInput extends StatelessWidget {
  const _SphereInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.sc.primary,
          foregroundColor: context.sc.onPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: SphereRadius.pillRect),
          elevation: 0,
          disabledBackgroundColor:
              context.sc.primary.withValues(alpha: 0.5),
        ),
        child: busy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation(context.sc.onPrimary),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.sc.onPrimary,
                ),
              ),
      ),
    );
  }
}
