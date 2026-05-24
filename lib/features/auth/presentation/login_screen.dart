import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
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
                color: context.sc.surfaceElev1,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    SphereSpacing.x24,
                    SphereSpacing.x32,
                    SphereSpacing.x24,
                    SphereSpacing.x24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcomeBack,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: SphereSpacing.x8),
                      Text(
                        'Log in to continue your training.',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.sc.onSurfaceMuted,
                                ),
                      ),
                      const SizedBox(height: SphereSpacing.x24),
                      _FieldLabel(AppLocalizations.of(context)!.email),
                      const SizedBox(height: 6),
                      _SphereInput(
                        controller: _email,
                        hint: AppLocalizations.of(context)!.enterYourEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: SphereSpacing.x16),
                      _FieldLabel(AppLocalizations.of(context)!.password),
                      const SizedBox(height: 6),
                      _SphereInput(
                        controller: _password,
                        hint: AppLocalizations.of(context)!.enterYourPassword,
                        obscureText: !_passwordVisible,
                        trailing: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            color: context.sc.onSurfaceMuted,
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
                          onPressed: () => context.push('/auth/forgot-password'),
                          child: Text(
                            AppLocalizations.of(context)!.forgotPassword,
                            style: TextStyle(color: context.sc.primary),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: SphereSpacing.x12),
                        Text(
                          _error!,
                          style: TextStyle(color: context.sc.danger),
                        ),
                      ],
                      const SizedBox(height: SphereSpacing.x16),
                      _PillButton(
                        label: AppLocalizations.of(context)!.logIn,
                        busy: _busy,
                        onTap: _busy ? null : _submit,
                      ),
                      const SizedBox(height: SphereSpacing.x24),
                      _DividerWithLabel(label: AppLocalizations.of(context)!.orContinueWith),
                      const SizedBox(height: SphereSpacing.x20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialPill(
                            iconBuilder: (_) => SvgPicture.asset(
                              'assets/brand/google_g.svg',
                              width: 18,
                              height: 18,
                            ),
                            label: 'Google',
                            disabled: _busy,
                            onTap: _busy ? () {} : _signInWithGoogle,
                          ),
                          const SizedBox(width: SphereSpacing.x12),
                          _SocialPill(
                            iconBuilder: (color) => SvgPicture.asset(
                              'assets/brand/apple_logo.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                color,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: 'Apple',
                            disabled: true,
                            onTap: () => _showAppleComingSoon(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: SphereSpacing.x24),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/auth/signup'),
                          behavior: HitTestBehavior.opaque,
                          child: Text.rich(
                            TextSpan(
                              text: AppLocalizations.of(context)!.newHere + ' ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                  ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.signUp,
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

class _DividerWithLabel extends StatelessWidget {
  const _DividerWithLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.sc.borderSubtle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: context.sc.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.sc.borderSubtle)),
      ],
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({
    required this.iconBuilder,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  /// Returns the icon widget given the resolved label color, so monochrome
  /// icons can inherit the muted state but full-color brand icons (Google G)
  /// can ignore it.
  final Widget Function(Color color) iconBuilder;
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color =
        disabled ? context.sc.onSurfaceMuted : context.sc.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: SphereRadius.pillRect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev2,
          borderRadius: SphereRadius.pillRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Center(child: iconBuilder(color)),
            ),
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
