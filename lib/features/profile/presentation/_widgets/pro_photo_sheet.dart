import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_spacing.dart';
import '../../data/photo_upload_repository.dart';
import '../../../auth/presentation/auth_providers.dart';

enum _ProPhotoState {
  idle,           // no photo picked yet — show instructions + camera/gallery
  ready,          // photo picked — show preview + generate button
  uploading,      // uploading reference photo to backend
  generating,     // generating AI portrait
  preview,        // show AI result
  adopting,
  done,
  error,
}

class ProPhotoSheet extends ConsumerStatefulWidget {
  const ProPhotoSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final adopted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.sc.surfaceElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ProPhotoSheet(),
    );
    return adopted == true;
  }

  @override
  ConsumerState<ProPhotoSheet> createState() => _ProPhotoSheetState();
}

class _ProPhotoSheetState extends ConsumerState<ProPhotoSheet> {
  _ProPhotoState _state = _ProPhotoState.idle;
  XFile? _pickedFile;
  String? _previewUrl;
  String? _errorMsg;

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final repo = ref.read(photoUploadRepositoryProvider);
    final file = await repo.pickPhoto(fromCamera: fromCamera);
    if (file != null && mounted) {
      setState(() {
        _pickedFile = file;
        _state = _ProPhotoState.ready;
      });
    }
  }

  Future<void> _uploadAndGenerate() async {
    setState(() => _state = _ProPhotoState.uploading);
    try {
      final repo = ref.read(photoUploadRepositoryProvider);
      // Upload jersey photo as reference (sets it as profile photo on backend)
      await repo.uploadWithBgRemoval(_pickedFile!);
      if (!mounted) return;
      setState(() => _state = _ProPhotoState.generating);
      final url = await repo.generateProPhoto();
      if (mounted) setState(() { _state = _ProPhotoState.preview; _previewUrl = url; });
    } catch (e) {
      if (mounted) setState(() { _state = _ProPhotoState.error; _errorMsg = e.toString(); });
    }
  }

  Future<void> _adopt() async {
    setState(() => _state = _ProPhotoState.adopting);
    try {
      final repo = ref.read(photoUploadRepositoryProvider);
      await repo.adoptProPhoto();
      ref.invalidate(currentUserProvider);
      if (mounted) {
        setState(() => _state = _ProPhotoState.done);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) setState(() { _state = _ProPhotoState.error; _errorMsg = e.toString(); });
    }
  }

  void _discard() => Navigator.of(context).pop(false);

  void _retryPick() => setState(() { _pickedFile = null; _state = _ProPhotoState.idle; });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              const SizedBox(height: 20),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle() => Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: context.sc.borderSubtle,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildContent() {
    return switch (_state) {
      _ProPhotoState.idle => _IdleView(onPickCamera: () => _pickPhoto(fromCamera: true), onPickGallery: () => _pickPhoto(fromCamera: false)),
      _ProPhotoState.ready => _ReadyView(file: _pickedFile!, onGenerate: _uploadAndGenerate, onRetake: _retryPick),
      _ProPhotoState.uploading => const _ProgressView(label: 'Uploading your photo...', sub: 'Setting up reference image…'),
      _ProPhotoState.generating => const _ProgressView(label: 'Generating your pro photo…', sub: 'AI is creating your professional portrait. Up to a minute.'),
      _ProPhotoState.preview => _PreviewView(url: _previewUrl!, onUse: _adopt, onDiscard: _discard),
      _ProPhotoState.adopting => const _ProgressView(label: 'Saving your photo...', sub: ''),
      _ProPhotoState.done => const _DoneView(),
      _ProPhotoState.error => _ErrorView(
          message: _errorMsg ?? 'Something went wrong',
          onRetry: () => setState(() => _state = _ProPhotoState.idle),
        ),
    };
  }
}

// ── Idle — instructions + pick buttons ──────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onPickCamera, required this.onPickGallery});
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.sc.primary.withValues(alpha: 0.12),
          ),
          child: Icon(LucideIcons.sparkles, color: context.sc.primary, size: 26),
        ),
        const SizedBox(height: 16),
        Text(
          'AI Pro Photo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        // Requirement card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.sc.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.sc.primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.info, size: 14, color: context.sc.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Photo requirements',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.sc.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Req(icon: LucideIcons.user, text: 'Face clearly visible, front-facing'),
              const SizedBox(height: 4),
              _Req(icon: LucideIcons.shirt, text: 'Wearing your club jersey'),
              const SizedBox(height: 4),
              _Req(icon: LucideIcons.sun, text: 'Good lighting, no heavy filters'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Takes 30–60 seconds after upload.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurfaceMuted,
                fontStyle: FontStyle.italic,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPickCamera,
            icon: const Icon(LucideIcons.camera, size: 18),
            label: const Text('Take Photo'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPickGallery,
            icon: const Icon(LucideIcons.image, size: 18),
            label: const Text('Choose from Gallery'),
          ),
        ),
      ],
    );
  }
}

class _Req extends StatelessWidget {
  const _Req({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: context.sc.onSurfaceMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.sc.onSurface),
          ),
        ),
      ],
    );
  }
}

// ── Ready — show picked photo + confirm ─────────────────────────────────────

class _ReadyView extends StatelessWidget {
  const _ReadyView({required this.file, required this.onGenerate, required this.onRetake});
  final XFile file;
  final VoidCallback onGenerate;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Looks good?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Make sure your face and jersey are clearly visible.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.sc.onSurfaceMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(file.path),
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(LucideIcons.wand, size: 18),
            label: const Text('Generate Pro Photo'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRetake,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Retake / Choose different'),
          ),
        ),
      ],
    );
  }
}

// ── Shared progress view ─────────────────────────────────────────────────────

class _ProgressView extends StatelessWidget {
  const _ProgressView({required this.label, required this.sub});
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(context.sc.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.sc.onSurfaceMuted), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

// ── Preview ──────────────────────────────────────────────────────────────────

class _PreviewView extends StatelessWidget {
  const _PreviewView({required this.url, required this.onUse, required this.onDiscard});
  final String url;
  final VoidCallback onUse;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Your Pro Photo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            width: 240,
            height: 240,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(context.sc.primary))),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onUse,
            icon: const Icon(LucideIcons.checkCircle, size: 18),
            label: const Text('Use as Profile Photo'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDiscard,
            icon: const Icon(LucideIcons.x, size: 18),
            label: const Text('Discard'),
          ),
        ),
      ],
    );
  }
}

// ── Done ─────────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  const _DoneView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.sc.primary.withValues(alpha: 0.12)),
            child: Icon(LucideIcons.checkCircle, color: context.sc.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Profile photo updated!', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.sc.danger.withValues(alpha: 0.12)),
          child: Icon(LucideIcons.alertCircle, color: context.sc.danger, size: 28),
        ),
        const SizedBox(height: 16),
        Text('Generation failed', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.sc.onSurfaceMuted), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}
