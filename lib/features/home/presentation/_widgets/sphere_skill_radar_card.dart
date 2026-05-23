import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_spacing.dart';

class SphereSkillRadarCard extends StatelessWidget {
  const SphereSkillRadarCard({
    super.key,
    required this.skills,
    this.onTap,
    this.loading = false,
  });

  /// e.g. {'pace': 72, 'passing': 58, 'shooting': 45, 'dribbling': 80, 'defense': 60, 'physical': 55}
  final Map<String, double> skills;
  final VoidCallback? onTap;
  final bool loading;

  static const _axes = ['pace', 'shooting', 'physical', 'defense', 'dribbling', 'passing'];
  static const _labels = ['Pace', 'Shooting', 'Physical', 'Defense', 'Dribbling', 'Passing'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SphereSpacing.x20),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Skill Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.sc.onSurface,
                      ),
                ),
                const Spacer(),
                if (onTap != null)
                  Text(
                    'Edit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: SphereSpacing.x16),
            if (loading)
              SizedBox(
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(context.sc.primary),
                  ),
                ),
              )
            else if (skills.isEmpty)
              SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'No skills set yet. Tap Edit to add your profile.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _RadarPainter(
                    values: List.generate(
                      _axes.length,
                      (i) => ((skills[_axes[i]] ?? 0) / 100).clamp(0.0, 1.0),
                    ),
                    labels: _labels,
                    fillColor: context.sc.primary,
                    gridColor: context.sc.borderSubtle,
                    labelColor: context.sc.onSurfaceMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.labels,
    required this.fillColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<double> values;
  final List<String> labels;
  final Color fillColor;
  final Color gridColor;
  final Color labelColor;

  static const _rings = 4;
  static const _labelPad = 28.0;

  Offset _point(Offset center, double radius, int i, int total) {
    final angle = (2 * math.pi / total) * i - math.pi / 2;
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = (math.min(size.width, size.height) / 2) - _labelPad;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final spokePaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw rings
    for (int r = 1; r <= _rings; r++) {
      final radius = maxR * (r / _rings);
      final path = Path();
      for (int i = 0; i < n; i++) {
        final p = _point(center, radius, i, n);
        if (i == 0) path.moveTo(p.dx, p.dy);
        else path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw spokes
    for (int i = 0; i < n; i++) {
      final p = _point(center, maxR, i, n);
      canvas.drawLine(center, p, spokePaint);
    }

    // Draw filled polygon
    final fillPaint = Paint()
      ..color = fillColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final p = _point(center, maxR * values[i], i, n);
      if (i == 0) dataPath.moveTo(p.dx, p.dy);
      else dataPath.lineTo(p.dx, p.dy);
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Draw dots on data polygon
    final dotPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      final p = _point(center, maxR * values[i], i, n);
      canvas.drawCircle(p, 4, dotPaint);
    }

    // Draw labels
    for (int i = 0; i < n; i++) {
      final labelPt = _point(center, maxR + _labelPad - 6, i, n);
      final angle = (2 * math.pi / n) * i - math.pi / 2;
      final pct = (values[i] * 100).round();

      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${labels[i]}\n',
              style: TextStyle(
                color: labelColor,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '$pct',
              style: TextStyle(
                color: fillColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textAlign: _alignForAngle(angle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 56);

      final dx = labelPt.dx - textPainter.width * _anchorX(angle);
      final dy = labelPt.dy - textPainter.height * _anchorY(angle);
      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  TextAlign _alignForAngle(double angle) {
    final cos = math.cos(angle);
    if (cos < -0.3) return TextAlign.right;
    if (cos > 0.3) return TextAlign.left;
    return TextAlign.center;
  }

  double _anchorX(double angle) {
    final cos = math.cos(angle);
    if (cos < -0.3) return 1.0;
    if (cos > 0.3) return 0.0;
    return 0.5;
  }

  double _anchorY(double angle) {
    final sin = math.sin(angle);
    if (sin < -0.3) return 1.0;
    if (sin > 0.3) return 0.0;
    return 0.5;
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.values != values || old.fillColor != fillColor;
}
