import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../data/drill_analyzer/drill_mode.dart';
import '../data/drill_analyzer/drill_mode_runner.dart';
import '../data/drill_analyzer/ml_kit_adapter.dart';
import '../domain/drill.dart';
import 'drill_detail_providers.dart';
import 'drill_session_providers.dart';
import 'player_home_providers.dart';

class DrillPlayerScreen extends ConsumerStatefulWidget {
  const DrillPlayerScreen({super.key, required this.drillId});
  final String drillId;

  @override
  ConsumerState<DrillPlayerScreen> createState() => _DrillPlayerScreenState();
}

class _DrillPlayerScreenState extends ConsumerState<DrillPlayerScreen>
    with WidgetsBindingObserver {
  static const _targetReps = 50;

  CameraController? _camera;
  PoseDetector? _detector;
  DrillModeRunner? _runner;
  int? _sessionStartedMs;

  bool _processing = false;
  String? _initError;
  String _modeLabel = '';
  int _reps = 0;
  RunnerState _state = RunnerState.idle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Lock to portrait while the drill player is open.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shutdownCamera();
    _detector?.close();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _shutdownCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraForDrill();
    }
  }

  Future<void> _initCameraForDrill() async {
    final drill = ref.read(drillDetailProvider(drillId: widget.drillId)).valueOrNull;
    if (drill == null) return;
    _runner ??= DrillModeRunner(
      mode: DrillMode.forCategory(drill.category),
      targetReps: _targetReps,
    );
    _modeLabel = _labelForMode(_runner!.mode);
    _detector ??= PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ),
    );
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _initError = 'No camera available on this device.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.nv21,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _initError = null;
      });
      _runner!.start(DateTime.now().millisecondsSinceEpoch);
      _sessionStartedMs = DateTime.now().millisecondsSinceEpoch;
      await controller.startImageStream(_onCameraImage);
    } catch (e) {
      setState(() => _initError = 'Camera error: $e');
    }
  }

  Future<void> _shutdownCamera() async {
    final camera = _camera;
    _camera = null;
    if (camera == null) return;
    try {
      if (camera.value.isStreamingImages) {
        await camera.stopImageStream();
      }
    } catch (_) {}
    await camera.dispose();
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_processing) return;
    _processing = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final poses = await _detector!.processImage(input);
      final snap = snapshotFromMlKit(
        poses,
        DateTime.now().millisecondsSinceEpoch,
      );
      if (snap == null) return;
      final runner = _runner;
      if (runner == null) return;
      final counted = runner.feed(snap);
      if (counted || _state != runner.state || _reps != runner.reps) {
        if (!mounted) return;
        setState(() {
          _reps = runner.reps;
          _state = runner.state;
        });
        if (runner.state == RunnerState.done) {
          await _completeSession();
        }
      }
    } finally {
      _processing = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final camera = _camera;
    if (camera == null) return null;
    final cameraDescription = camera.description;
    final rotation = InputImageRotationValue.fromRawValue(
          cameraDescription.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;
    final rawFormat = image.format.raw;
    final format = rawFormat is int
        ? InputImageFormatValue.fromRawValue(rawFormat)
        : null;
    if (format == null) return null;
    if (Platform.isIOS && image.planes.length != 1) return null;
    if (Platform.isAndroid && image.planes.isEmpty) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _completeSession() async {
    unawaited(HapticFeedback.heavyImpact());
    await _shutdownCamera();

    final drill = ref.read(drillDetailProvider(drillId: widget.drillId)).valueOrNull;
    final runner = _runner;
    final started = _sessionStartedMs ?? DateTime.now().millisecondsSinceEpoch;
    final reps = runner?.reps ?? 0;
    final durationMs = DateTime.now().millisecondsSinceEpoch - started;
    final mode = runner?.mode.name ?? 'kneeLine';

    int streakDays = 0;
    if (drill != null && reps > 0) {
      try {
        final result = await ref
            .read(drillSessionRepositoryProvider)
            .recordSession(
              drillId: drill.id,
              reps: reps,
              durationMs: durationMs,
              mode: mode,
            );
        streakDays = result.streakDays;
      } catch (_) {
        // Best-effort: still navigate to celebration even if server save fails.
      }
    }

    // Invalidate today drill provider so home shows fresh state.
    ref.invalidate(todayDrillProvider);

    if (!mounted) return;
    context.go(
      '/train/drill/${widget.drillId}/complete?reps=$reps&streak=$streakDays',
    );
  }

  void _exit() async {
    await _shutdownCamera();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/train');
    }
  }

  String _labelForMode(DrillMode mode) {
    switch (mode) {
      case DrillMode.kneeLine:
        return 'Juggle';
      case DrillMode.tap:
        return 'Tap';
      case DrillMode.lateral:
        return 'Lateral';
      case DrillMode.sustainedContact:
        return 'Sole roll';
    }
  }

  @override
  Widget build(BuildContext context) {
    final drillAsync = ref.watch(
      drillDetailProvider(drillId: widget.drillId),
    );
    return SphereFieldBackground(
      child: drillAsync.when(
      data: (drill) {
        if (drill == null) return _NotFound(onExit: _exit);
        // Lazy-init camera once we have the drill.
        if (_camera == null && _initError == null && _runner == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initCameraForDrill();
          });
        }
        return _Player(
          drill: drill,
          camera: _camera,
          reps: _reps,
          targetReps: _targetReps,
          state: _state,
          modeLabel: _modeLabel,
          error: _initError,
          onExit: _exit,
          onDone: () async {
            _runner?.finish();
            await _completeSession();
          },
        );
      },
      loading: () => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(context.sc.primary),
            ),
          ),
        ),
      ),
      error: (_, _) => _NotFound(onExit: _exit),
    ));
  }
}

class _Player extends StatelessWidget {
  const _Player({
    required this.drill,
    required this.camera,
    required this.reps,
    required this.targetReps,
    required this.state,
    required this.modeLabel,
    required this.error,
    required this.onExit,
    required this.onDone,
  });

  final Drill drill;
  final CameraController? camera;
  final int reps;
  final int targetReps;
  final RunnerState state;
  final String modeLabel;
  final String? error;
  final VoidCallback onExit;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final progress = (reps / targetReps).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview (or error / loading)
          if (camera != null && camera!.value.isInitialized)
            Positioned.fill(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: camera!.value.previewSize?.height ?? 1,
                      height: camera!.value.previewSize?.width ?? 1,
                      child: CameraPreview(camera!),
                    ),
                  ),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: ColoredBox(color: Colors.black),
            ),

          // Dark vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),

          if (error != null)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(SphereSpacing.x24),
                child: Center(
                  child: Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          // Top HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SphereSpacing.x16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: SphereRadius.pillRect,
                      border: Border.all(
                        color: context.sc.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.dumbbell,
                          color: context.sc.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          modeLabel,
                          style: TextStyle(
                            color: context.sc.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onExit,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center rep counter
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x24,
                vertical: SphereSpacing.x12,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: SphereRadius.modalRect,
                border: Border.all(
                  color: context.sc.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$reps',
                    style: TextStyle(
                      color: context.sc.primary,
                      fontSize: 84,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state == RunnerState.awaitingMotion
                        ? 'Start moving...'
                        : 'of $targetReps',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom HUD: progress + Done
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(SphereSpacing.x16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: SphereRadius.pillRect,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(
                          context.sc.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: SphereSpacing.x12),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onDone,
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.sc.primary,
                          foregroundColor: context.sc.onPrimary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: SphereRadius.pillRect,
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onExit});
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onExit,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      LucideIcons.chevronLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              Text(
                AppLocalizations.of(context)!.drillNotFound,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
