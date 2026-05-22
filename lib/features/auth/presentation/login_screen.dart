import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/sphere_colors.dart';
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
      setState(() => _error = e.message ?? 'Login gagal. Cuba lagi.');
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: SphereSpacing.x32),
              Text(
                'Log masuk',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: SphereSpacing.x32),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SphereSpacing.x12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: SphereSpacing.x12),
                Text(_error!, style: const TextStyle(color: SphereColors.danger)),
              ],
              const SizedBox(height: SphereSpacing.x24),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(SphereColors.onPrimary),
                        ),
                      )
                    : const Text('Continue'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              const _DividerWithLabel(label: 'Atau'),
              const SizedBox(height: SphereSpacing.x16),
              // Google + Apple buttons added in Tasks 16-17 (blocked on Apple Dev).
            ],
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
          child: Text(label, style: const TextStyle(color: SphereColors.onSurfaceMuted)),
        ),
        const Expanded(child: Divider(color: SphereColors.borderSubtle)),
      ],
    );
  }
}
