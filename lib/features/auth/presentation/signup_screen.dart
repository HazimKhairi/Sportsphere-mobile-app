import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../role_pick/presentation/role_providers.dart';
import 'auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _passwordVisible = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            displayName: name,
          );
      // Router redirect picks up the new user.
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Sign up failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(selectedRoleProvider);

    return Scaffold(
      backgroundColor: context.sc.surface,
      body: Stack(
        children: [
          // Hero image.
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

          // Header overlay.
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
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/auth/login');
                        }
                      },
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
                child: role == AppRole.staff
                    ? _StaffInviteOnly(onLogin: () => context.go('/auth/login'))
                    : _PlayerSignupForm(
                        nameCtrl: _name,
                        emailCtrl: _email,
                        passwordCtrl: _password,
                        confirmCtrl: _confirm,
                        passwordVisible: _passwordVisible,
                        onTogglePassword: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        busy: _busy,
                        error: _error,
                        onSubmit: _submit,
                        onLogin: () => context.go('/auth/login'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerSignupForm extends StatelessWidget {
  const _PlayerSignupForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.passwordVisible,
    required this.onTogglePassword,
    required this.busy,
    required this.error,
    required this.onSubmit,
    required this.onLogin,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;
  final bool busy;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SphereSpacing.x24,
        SphereSpacing.x32,
        SphereSpacing.x24,
        SphereSpacing.x24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.createYourAccount,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: SphereSpacing.x8),
          Text(
            'Join your academy on SportSphere.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x24),
          _FieldLabel(AppLocalizations.of(context)!.fullName),
          const SizedBox(height: 6),
          _SphereInput(controller: nameCtrl, hint: AppLocalizations.of(context)!.yourFullName),
          const SizedBox(height: SphereSpacing.x16),
          _FieldLabel(AppLocalizations.of(context)!.email),
          const SizedBox(height: 6),
          _SphereInput(
            controller: emailCtrl,
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: SphereSpacing.x16),
          _FieldLabel(AppLocalizations.of(context)!.password),
          const SizedBox(height: 6),
          _SphereInput(
            controller: passwordCtrl,
            hint: AppLocalizations.of(context)!.passwordMinChars,
            obscureText: !passwordVisible,
            trailing: IconButton(
              icon: Icon(
                passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                color: context.sc.onSurfaceMuted,
                size: 20,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          const SizedBox(height: SphereSpacing.x16),
          _FieldLabel(AppLocalizations.of(context)!.confirmPassword),
          const SizedBox(height: 6),
          _SphereInput(
            controller: confirmCtrl,
            hint: AppLocalizations.of(context)!.reTypePassword,
            obscureText: !passwordVisible,
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
            label: AppLocalizations.of(context)!.createAccount,
            busy: busy,
            onTap: busy ? null : onSubmit,
          ),
          const SizedBox(height: SphereSpacing.x24),
          Center(
            child: GestureDetector(
              onTap: onLogin,
              behavior: HitTestBehavior.opaque,
              child: Text.rich(
                TextSpan(
                  text: AppLocalizations.of(context)!.alreadyHaveAccount + ' ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.logIn,
                      style: TextStyle(
                        color: context.sc.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffInviteOnly extends StatelessWidget {
  const _StaffInviteOnly({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SphereSpacing.x24,
        SphereSpacing.x32,
        SphereSpacing.x24,
        SphereSpacing.x24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.staffInviteOnly,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: SphereSpacing.x8),
          Text(
            'Your club admin will email you an invitation to set up your '
            'staff account. Check your inbox, then log in with the '
            'credentials you set up via the email link.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: SphereSpacing.x24),
          Container(
            padding: const EdgeInsets.all(SphereSpacing.x16),
            decoration: BoxDecoration(
              color: context.sc.primary.withValues(alpha: 0.06),
              borderRadius: SphereRadius.cardRect,
              border: Border.all(
                color: context.sc.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.mail,
                  color: context.sc.primary,
                  size: 20,
                ),
                const SizedBox(width: SphereSpacing.x12),
                Expanded(
                  child: Text(
                    'Ask your club admin if you haven’t received an '
                    'invite.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SphereSpacing.x32),
          _PillButton(
            label: 'Got an invite? Log in',
            onTap: onLogin,
          ),
        ],
      ),
    );
  }
}

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
    this.obscureText = false,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: context.sc.onSurface, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.sc.onSurfaceMuted, fontSize: 15),
        suffixIcon: trailing,
        filled: true,
        fillColor: context.sc.surfaceElev2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: SphereRadius.cardRect,
          borderSide: BorderSide(color: context.sc.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SphereRadius.cardRect,
          borderSide: BorderSide(color: context.sc.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: SphereRadius.cardRect,
          borderSide: BorderSide(color: context.sc.borderSubtle),
        ),
      ),
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
          shape:
              const RoundedRectangleBorder(borderRadius: SphereRadius.pillRect),
          elevation: 0,
          disabledBackgroundColor: context.sc.primary.withValues(alpha: 0.5),
        ),
        child: busy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(context.sc.onPrimary),
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
