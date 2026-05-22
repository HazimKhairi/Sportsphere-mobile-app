import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _passwordVisible = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: _email.text.trim(),
            password: _password.text,
          );
      // Router redirect will take over.
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Login failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SphereColors.surface,
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
                        SphereColors.surface.withValues(alpha: 0.55),
                        SphereColors.surface.withValues(alpha: 0.25),
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
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/role-pick');
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
                color: SphereColors.surfaceElev1,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(
                    color: SphereColors.primary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: SphereColors.primary.withValues(alpha: 0.08),
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
                child: SingleChildScrollView(
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
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: SphereSpacing.x8),
                      Text(
                        'Log in to continue your training.',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SphereColors.onSurfaceMuted,
                                ),
                      ),
                      const SizedBox(height: SphereSpacing.x24),
                      const _FieldLabel('Email'),
                      const SizedBox(height: 6),
                      _SphereInput(
                        controller: _email,
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: SphereSpacing.x16),
                      const _FieldLabel('Password'),
                      const SizedBox(height: 6),
                      _SphereInput(
                        controller: _password,
                        hint: 'Enter your password',
                        obscureText: !_passwordVisible,
                        trailing: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            color: SphereColors.onSurfaceMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _passwordVisible = !_passwordVisible,
                          ),
                        ),
                      ),
                      const SizedBox(height: SphereSpacing.x8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Phase 2 — forgot password flow
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forgot password coming soon.'),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: SphereColors.primary),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: SphereSpacing.x12),
                        Text(
                          _error!,
                          style: const TextStyle(color: SphereColors.danger),
                        ),
                      ],
                      const SizedBox(height: SphereSpacing.x16),
                      _PillButton(
                        label: 'Log In',
                        busy: _busy,
                        onTap: _busy ? null : _submit,
                      ),
                      const SizedBox(height: SphereSpacing.x24),
                      const _DividerWithLabel(label: 'Or continue with'),
                      const SizedBox(height: SphereSpacing.x20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialPill(
                            // Lucide doesn't ship a 'chrome' icon — use `globe`
                            // as a neutral browser/Google substitute.
                            icon: LucideIcons.globe,
                            label: 'Google',
                            disabled: _busy,
                            onTap: _busy ? () {} : _signInWithGoogle,
                          ),
                          const SizedBox(width: SphereSpacing.x12),
                          _SocialPill(
                            icon: LucideIcons.apple,
                            label: 'Apple',
                            disabled: true,
                            onTap: () => _showAppleComingSoon(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: SphereSpacing.x24),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'New here? ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: SphereColors.onSurfaceMuted,
                                ),
                            children: const [
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                  color: SphereColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // Router redirect will take over.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showAppleComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-In available after enrollment.'),
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
      color: SphereColors.surfaceElev1.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: SphereColors.onSurface),
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
            color: SphereColors.onSurface,
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
    return Container(
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev2,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(color: SphereColors.onSurface),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: SphereColors.onSurfaceMuted),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          ?trailing,
        ],
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
          backgroundColor: SphereColors.primary,
          foregroundColor: SphereColors.onPrimary,
          shape:
              const RoundedRectangleBorder(borderRadius: SphereRadius.pillRect),
          elevation: 0,
          disabledBackgroundColor: SphereColors.primary.withValues(alpha: 0.5),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(SphereColors.onPrimary),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SphereColors.onPrimary,
                ),
              ),
      ),
    );
  }
}

class _DividerWithLabel extends StatelessWidget {
  const _DividerWithLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: SphereColors.borderSubtle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: SphereColors.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: SphereColors.borderSubtle)),
      ],
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color =
        disabled ? SphereColors.onSurfaceMuted : SphereColors.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: SphereRadius.pillRect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: SphereColors.surfaceElev2,
          borderRadius: SphereRadius.pillRect,
          border: Border.all(color: SphereColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
