import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../data/check_in_repository.dart';
import 'check_in_providers.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

enum _ScanStatus { scanning, submitting, success, mismatch, failure, alreadyCheckedIn, notMember }

class _QrScanScreenState extends ConsumerState<QrScanScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scanner;
  late final AnimationController _shake;
  _ScanStatus _status = _ScanStatus.scanning;
  bool _consumed = false;

  @override
  void initState() {
    super.initState();
    _scanner = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _scanner.dispose();
    _shake.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_consumed) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;
    _consumed = true;
    setState(() => _status = _ScanStatus.submitting);

    final result = await ref.read(checkInRepositoryProvider).checkIn(
          sessionId: widget.sessionId,
          qrPayload: raw,
        );

    if (!mounted) return;
    switch (result) {
      case CheckInResult.success:
        setState(() => _status = _ScanStatus.success);
        unawaited(HapticFeedback.heavyImpact());
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/schedule');
          }
        }
      case CheckInResult.alreadyCheckedIn:
        setState(() => _status = _ScanStatus.alreadyCheckedIn);
        unawaited(HapticFeedback.mediumImpact());
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          _consumed = false;
          setState(() => _status = _ScanStatus.scanning);
        }
      case CheckInResult.notMember:
        setState(() => _status = _ScanStatus.notMember);
        unawaited(HapticFeedback.heavyImpact());
        unawaited(_shake.forward(from: 0));
        await Future<void>.delayed(const Duration(seconds: 3));
        if (mounted) {
          _consumed = false;
          setState(() => _status = _ScanStatus.scanning);
        }
      case CheckInResult.sessionNotFound:
        setState(() => _status = _ScanStatus.mismatch);
        unawaited(HapticFeedback.heavyImpact());
        unawaited(_shake.forward(from: 0));
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          _consumed = false;
          setState(() => _status = _ScanStatus.scanning);
        }
      case CheckInResult.failure:
        setState(() => _status = _ScanStatus.failure);
        unawaited(HapticFeedback.heavyImpact());
        unawaited(_shake.forward(from: 0));
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          _consumed = false;
          setState(() => _status = _ScanStatus.scanning);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SphereFieldBackground(child: Stack(
        children: [
          AnimatedBuilder(
            animation: _shake,
            builder: (context, child) {
              final t = _shake.value;
              final shake = (t * 4) % 1.0;
              final dx = shake < 0.5 ? -1 + shake * 4 : 1 - (shake - 0.5) * 4;
              return Transform.translate(
                offset: Offset(t == 0 ? 0 : dx * 8, 0),
                child: child,
              );
            },
            child: MobileScanner(
              controller: _scanner,
              onDetect: _handleDetection,
            ),
          ),
          _ScannerOverlay(status: _status),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SphereSpacing.x16),
              child: Row(
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/schedule');
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(LucideIcons.x, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _TorchToggle(controller: _scanner),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(SphereSpacing.x24),
                child: _StatusBanner(status: _status),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({required this.status});
  final _ScanStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      _ScanStatus.success => context.sc.success,
      _ScanStatus.mismatch || _ScanStatus.failure => context.sc.danger,
      _ => context.sc.primary,
    };
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(28)),
        ),
        child: status == _ScanStatus.success
            ? Center(
                child: Icon(
                  LucideIcons.check,
                  color: color,
                  size: 80,
                ),
              )
            : null,
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final _ScanStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (text, color, icon) = switch (status) {
      _ScanStatus.scanning => (
        l.alignQrCode,
        Colors.white,
        LucideIcons.scanLine,
      ),
      _ScanStatus.submitting => (
        l.checkingIn,
        Colors.white,
        LucideIcons.loader,
      ),
      _ScanStatus.success => (
        l.checkedIn,
        context.sc.success,
        LucideIcons.check,
      ),
      _ScanStatus.mismatch => (
        l.wrongQr,
        context.sc.danger,
        LucideIcons.x,
      ),
      _ScanStatus.alreadyCheckedIn => (
        l.alreadyCheckedIn,
        context.sc.success,
        LucideIcons.check,
      ),
      _ScanStatus.notMember => (
        'Payment required to join this session.',
        context.sc.danger,
        LucideIcons.lockKeyhole,
      ),
      _ScanStatus.failure => (
        'Network hiccup. Try again.',
        context.sc.danger,
        LucideIcons.wifiOff,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TorchToggle extends StatefulWidget {
  const _TorchToggle({required this.controller});
  final MobileScannerController controller;

  @override
  State<_TorchToggle> createState() => _TorchToggleState();
}

class _TorchToggleState extends State<_TorchToggle> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () async {
          await widget.controller.toggleTorch();
          if (mounted) setState(() => _on = !_on);
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            _on ? LucideIcons.flashlightOff : LucideIcons.flashlight,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
