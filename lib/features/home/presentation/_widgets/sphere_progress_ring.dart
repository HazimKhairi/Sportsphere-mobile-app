import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../app/theme/sphere_colors.dart';

class SphereProgressRing extends StatefulWidget {
  const SphereProgressRing({
    super.key,
    required this.size,
    required this.value,
    this.strokeWidth = 4,
    this.child,
  });
  final double size;
  final double value; // 0.0 to 1.0
  final double strokeWidth;
  final Widget? child;

  @override
  State<SphereProgressRing> createState() => _SphereProgressRingState();
}

class _SphereProgressRingState extends State<SphereProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_ctrl.value);
          return CustomPaint(
            painter: _RingPainter(
              progress: widget.value * t,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(child: widget.child),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.strokeWidth});
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = SphereColors.borderSubtle;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = SphereColors.primary;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        progress * 2 * pi,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}
