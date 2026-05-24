import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../data/session_media_repository.dart';
import '../domain/session_media_item.dart';

class SessionMediaGalleryScreen extends ConsumerStatefulWidget {
  const SessionMediaGalleryScreen({
    super.key,
    required this.sessionId,
    required this.clubId,
  });

  final String sessionId;
  final String clubId;

  @override
  ConsumerState<SessionMediaGalleryScreen> createState() =>
      _SessionMediaGalleryScreenState();
}

class _SessionMediaGalleryScreenState
    extends ConsumerState<SessionMediaGalleryScreen> {
  final _repo = SessionMediaRepository();
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;
  bool _downloading = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  Future<void> _downloadSelected(List<SessionMediaItem> items) async {
    final toDownload = items.where((i) => _selectedIds.contains(i.id)).toList();
    if (toDownload.isEmpty) return;

    setState(() => _downloading = true);
    final dio = Dio();
    int count = 0;
    try {
      for (final item in toDownload) {
        if (item.type == MediaType.image) {
          final res = await dio.get<List<int>>(
            item.url,
            options: Options(responseType: ResponseType.bytes),
          );
          if (res.data != null) {
            await Gal.putImageBytes(Uint8List.fromList(res.data!), name: 'session_${item.id}');
            count++;
          }
        } else {
          final dir = await getTemporaryDirectory();
          final tempPath = '${dir.path}/session_${item.id}.mp4';
          await dio.download(item.url, tempPath);
          await Gal.putVideo(tempPath);
          await File(tempPath).delete();
          count++;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded $count item${count == 1 ? '' : 's'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
          _selectedIds.clear();
          _selectionMode = false;
        });
      }
    }
  }

  void _openFullScreen(SessionMediaItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullScreenViewer(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _repo.mediaStream(
      clubId: widget.clubId,
      sessionId: widget.sessionId,
    );

    return StreamBuilder<List<SessionMediaItem>>(
      stream: stream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: const Text('Session Media'),
            actions: [
              if (_selectedIds.isNotEmpty)
                TextButton.icon(
                  onPressed: _downloading
                      ? null
                      : () => _downloadSelected(items),
                  icon: _downloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.download, size: 18),
                  label: Text('Download (${_selectedIds.length})'),
                ),
            ],
          ),
          body: Builder(builder: (context) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.image,
                        size: 48, color: context.sc.onSurfaceMuted),
                    const SizedBox(height: SphereSpacing.x12),
                    Text(
                      'No media for this session.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final selected = _selectedIds.contains(item.id);
                return GestureDetector(
                  onTap: () {
                    if (_selectionMode) {
                      _toggleSelection(item.id);
                    } else {
                      _openFullScreen(item);
                    }
                  },
                  onLongPress: () => _enterSelectionMode(item.id),
                  child: ClipRRect(
                    borderRadius: SphereRadius.cardRect,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item.type == MediaType.image)
                          CachedNetworkImage(
                            imageUrl: item.url,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: context.sc.surfaceElev1),
                            errorWidget: (_, _, _) =>
                                Container(color: context.sc.surfaceElev1),
                          )
                        else
                          Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: Icon(LucideIcons.play,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        if (selected)
                          Container(
                            color: context.sc.primary.withValues(alpha: 0.5),
                            child: const Center(
                              child: Icon(LucideIcons.check,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}

// ── Full Screen Viewer ────────────────────────────────────────────────────────

class _FullScreenViewer extends StatefulWidget {
  const _FullScreenViewer({required this.item});

  final SessionMediaItem item;

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == MediaType.video) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.item.url))
            ..initialize().then((_) {
              if (mounted) setState(() => _videoInitialized = true);
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: widget.item.type == MediaType.image
            ? InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.item.url,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      const CircularProgressIndicator(color: Colors.white),
                  errorWidget: (_, _, _) =>
                      const Icon(LucideIcons.imageOff, color: Colors.white),
                ),
              )
            : _videoInitialized && _videoController != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                      const SizedBox(height: SphereSpacing.x16),
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                      ),
                    ],
                  )
                : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
