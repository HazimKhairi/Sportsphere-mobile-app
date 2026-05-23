import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_spacing.dart';
import '../../data/photo_upload_repository.dart';
import '../../../auth/presentation/auth_providers.dart';

enum _ProPhotoState { idle, generating, preview, adopting, done, error }

class ProPhotoSheet extends ConsumerStatefulWidget {
  const ProPhotoSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final adopted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SphereColors.surfaceElev1,
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
  String? _previewUrl;
  String? _errorMsg;

  Future<void> _generate() async {
    setState(() => _state = _ProPhotoState.generating);
    try {
      final repo = ref.read(photoUploadRepositoryProvider);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
          color: SphereColors.borderSubtle,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildContent() {
    return switch (_state) {
      _ProPhotoState.idle => _IdleView(onGenerate: _generate),
      _ProPhotoState.generating => const _GeneratingView(),
      _ProPhotoState.preview => _PreviewView(
          url: _previewUrl!,
          onUse: _adopt,
          onDiscard: _discard,
        ),
      _ProPhotoState.adopting => const _AdoptingView(),
      _ProPhotoState.done => const _DoneView(),
      _ProPhotoState.error => _ErrorView(
          message: _errorMsg ?? 'Something went wrong',
          onRetry: () => setState(() => _state = _ProPhotoState.idle),
        ),
    };
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onGenerate});
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SphereColors.primary.withValues(alpha: 0.12),
          ),
          child: const Icon(LucideIcons.sparkles, color: SphereColors.primary, size: 26),
        ),
        const SizedBox(height: 16),
        Text(
          'AI Pro Photo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Our AI will generate a professional sports portrait using your current profile photo — same face, jersey, arms crossed, studio lighting.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SphereColors.onSurfaceMuted,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This takes about 30–60 seconds.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SphereColors.onSurfaceMuted,
                fontStyle: FontStyle.italic,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(LucideIcons.wand, size: 18),
            label: const Text('Generate Pro Photo'),
          ),
        ),
      ],
    );
  }
}

class _GeneratingView extends StatelessWidget {
  const _GeneratingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(SphereColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Generating your pro photo...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is creating your professional portrait. This may take up to a minute.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SphereColors.onSurfaceMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({
    required this.url,
    required this.onUse,
    required this.onDiscard,
  });
  final String url;
  final VoidCallback onUse;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your Pro Photo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
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
                : const SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(SphereColors.primary),
                      ),
                    ),
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

class _AdoptingView extends StatelessWidget {
  const _AdoptingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(SphereColors.primary),
            ),
          ),
          SizedBox(height: 16),
          Text('Saving your photo...'),
        ],
      ),
    );
  }
}

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SphereColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(LucideIcons.checkCircle, color: SphereColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'Profile photo updated!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SphereColors.danger.withValues(alpha: 0.12),
          ),
          child: const Icon(LucideIcons.alertCircle, color: SphereColors.danger, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Generation failed',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SphereColors.onSurfaceMuted),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
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
