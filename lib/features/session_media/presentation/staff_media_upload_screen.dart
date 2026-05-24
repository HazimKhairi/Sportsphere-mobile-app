import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/session_media_repository.dart';
import '../domain/session_media_item.dart';

class StaffMediaUploadScreen extends ConsumerStatefulWidget {
  const StaffMediaUploadScreen({
    super.key,
    required this.sessionId,
    required this.clubId,
  });

  final String sessionId;
  final String clubId;

  @override
  ConsumerState<StaffMediaUploadScreen> createState() =>
      _StaffMediaUploadScreenState();
}

class _StaffMediaUploadScreenState
    extends ConsumerState<StaffMediaUploadScreen> {
  final _repo = SessionMediaRepository();
  final _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _upload(List<String> paths, MediaType type) async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.valueOrNull;
    final uploaderName = user?.displayName ?? 'Staff';

    setState(() => _uploading = true);
    try {
      for (final path in paths) {
        await _repo.uploadMedia(
          clubId: widget.clubId,
          sessionId: widget.sessionId,
          localPath: path,
          type: type,
          uploaderName: uploaderName,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickPhotos() async {
    final files = await _picker.pickMultiImage();
    if (files.isEmpty) return;
    await _upload(files.map((f) => f.path).toList(), MediaType.image);
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    await _upload([file.path], MediaType.video);
  }

  Future<void> _confirmDelete(SessionMediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete media?'),
        content:
            const Text('This will permanently remove the item from the session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: context.sc.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.deleteMedia(
        clubId: widget.clubId,
        sessionId: widget.sessionId,
        itemId: item.id,
        storagePath: item.storagePath,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = _repo.mediaStream(
      clubId: widget.clubId,
      sessionId: widget.sessionId,
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Session Photos & Videos'),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<SessionMediaItem>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.image,
                          size: 48, color: context.sc.onSurfaceMuted),
                      const SizedBox(height: SphereSpacing.x12),
                      Text(
                        'No media yet. Add photos or videos from this session.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.sc.onSurfaceMuted,
                            ),
                      ),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  4,
                  4,
                  4,
                  80 + SphereSpacing.x8,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) =>
                    _MediaTile(item: items[i], onLongPress: _confirmDelete),
              );
            },
          ),
          if (_uploading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              onAddPhoto: _uploading ? null : _pickPhotos,
              onAddVideo: _uploading ? null : _pickVideo,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item, required this.onLongPress});

  final SessionMediaItem item;
  final Future<void> Function(SessionMediaItem) onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => onLongPress(item),
      child: ClipRRect(
        borderRadius: SphereRadius.cardRect,
        child: item.type == MediaType.image
            ? CachedNetworkImage(
                imageUrl: item.url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: context.sc.surfaceElev1),
                errorWidget: (_, _, _) =>
                    Container(color: context.sc.surfaceElev1),
              )
            : Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(LucideIcons.play, color: Colors.white, size: 36),
                ),
              ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onAddPhoto, required this.onAddVideo});

  final VoidCallback? onAddPhoto;
  final VoidCallback? onAddVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        SphereSpacing.x16,
        SphereSpacing.x12,
        SphereSpacing.x16,
        SphereSpacing.x12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.sc.surface,
        border: Border(top: BorderSide(color: context.sc.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAddPhoto,
              icon: const Icon(LucideIcons.image, size: 18),
              label: const Text('Add Photo'),
            ),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAddVideo,
              icon: const Icon(LucideIcons.video, size: 18),
              label: const Text('Add Video'),
            ),
          ),
        ],
      ),
    );
  }
}
