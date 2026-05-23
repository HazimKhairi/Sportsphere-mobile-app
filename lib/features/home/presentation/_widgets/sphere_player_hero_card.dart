import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/sphere_theme_ext.dart';
import '../../../player_card/domain/player_card_data.dart';

const _kDark = Color(0xFF0A0A0A);
const _kDarkElev = Color(0xFF1E1E1E);
const _kDarkBorder = Color(0xFF2A2A2A);

/// Full-bleed hero card for the player home screen.
/// Combines the player photo backdrop, identity info, and skill radar chart.
class SpherePlayerHeroCard extends StatelessWidget {
  const SpherePlayerHeroCard({
    super.key,
    required this.card,
    this.onTap,
    this.greeting,
    this.firstName,
  });

  final PlayerCardData card;
  final VoidCallback? onTap;
  final String? greeting;
  final String? firstName;

  Color get _tierColor => switch (card.rarityTier) {
        RarityTier.gold => const Color(0xFFFFD700),
        RarityTier.diamond => const Color(0xFF48CAE4),
        RarityTier.silver => const Color(0xFFC0C0C0),
        _ => const Color(0xFFCD7F32),
      };

  @override
  Widget build(BuildContext context) {
    final hasStats = card.activeStats.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: _kDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Photo hero — full bleed ────────────────────────────────────
            _HeroPhoto(
              card: card,
              tierColor: _tierColor,
              greeting: greeting,
              firstName: firstName,
            ),

            // ── Identity panel ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClubRow(card: card),
                  const SizedBox(height: 8),
                  Text(
                    card.playerName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _PositionRow(card: card, tierColor: _tierColor),
                ],
              ),
            ),

            // ── Skill radar ─────────────────────────────────────────────────
            if (hasStats) ...[
              const SizedBox(height: 20),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: _kDarkBorder,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'SKILL PROFILE',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CustomPaint(
                    painter: _HeroRadarPainter(
                      values: card.activeStats
                          .map((s) => (s.value / 100).clamp(0.0, 1.0))
                          .toList(),
                      labels: card.activeStats.map((s) => s.key).toList(),
                      fillColor: context.sc.primary,
                      gridColor: Colors.white12,
                      labelColor: Colors.white38,
                    ),
                  ),
                ),
              ),
            ],

            // ── Full view hint ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, hasStats ? 4 : 16, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Full View',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.sc.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.arrowRight, size: 12, color: context.sc.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PHOTO HERO ───────────────────────────────────────────────────────────────

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({
    required this.card,
    required this.tierColor,
    this.greeting,
    this.firstName,
  });
  final PlayerCardData card;
  final Color tierColor;
  final String? greeting;
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (card.playerPhoto != null)
            Image.network(
              card.playerPhoto!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (ctx, err, st) => const _PhotoFallback(),
            )
          else
            const _PhotoFallback(),

          // Gradient — stronger dark at top for text, fade, then dark at bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                    _kDark,
                  ],
                ),
              ),
            ),
          ),

          // Greeting + wordmark overlay — top
          if (greeting != null || firstName != null)
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (greeting != null)
                          Text(
                            greeting!,
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white60,
                            ),
                          ),
                        if (firstName != null)
                          Text(
                            firstName!,
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/brand/sphere_wordmark.png',
                    height: 20,
                    fit: BoxFit.fitHeight,
                  ),
                ],
              ),
            ),

          // OVR — bottom left
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${card.ovr}',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: tierColor,
                    height: 1.0,
                  ),
                ),
                Text(
                  'OVR',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tierColor.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Rarity badge — bottom right
          Positioned(
            right: 16,
            bottom: 26,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                card.rarityTier.label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: Icon(LucideIcons.user, size: 72, color: Colors.white12),
        ),
      );
}

// ─── CLUB ROW ─────────────────────────────────────────────────────────────────

class _ClubRow extends StatelessWidget {
  const _ClubRow({required this.card});
  final PlayerCardData card;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _kDarkElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kDarkBorder),
          ),
          child: const Center(
            child: Icon(LucideIcons.shield, size: 16, color: Colors.white38),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            card.clubName ?? 'Independent',
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        if (card.age != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kDarkElev,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kDarkBorder),
            ),
            child: Text(
              '${card.age} yrs',
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── POSITION ROW ─────────────────────────────────────────────────────────────

class _PositionRow extends StatelessWidget {
  const _PositionRow({required this.card, required this.tierColor});
  final PlayerCardData card;
  final Color tierColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: context.sc.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.sc.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            card.position,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.sc.primary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'SPORTSPHERE',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white24,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ─── RADAR PAINTER ────────────────────────────────────────────────────────────

class _HeroRadarPainter extends CustomPainter {
  const _HeroRadarPainter({
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
    if (n == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = (math.min(size.width, size.height) / 2) - _labelPad;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int r = 1; r <= _rings; r++) {
      final radius = maxR * (r / _rings);
      final path = Path();
      for (int i = 0; i < n; i++) {
        final p = _point(center, radius, i, n);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (int i = 0; i < n; i++) {
      canvas.drawLine(center, _point(center, maxR, i, n), gridPaint);
    }

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
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    final dotPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      canvas.drawCircle(_point(center, maxR * values[i], i, n), 4, dotPaint);
    }

    for (int i = 0; i < n; i++) {
      final labelPt = _point(center, maxR + _labelPad - 6, i, n);
      final angle = (2 * math.pi / n) * i - math.pi / 2;
      final displayVal = (values[i] * 100).round();

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
              text: '$displayVal',
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

  TextAlign _alignForAngle(double a) {
    final c = math.cos(a);
    if (c < -0.3) return TextAlign.right;
    if (c > 0.3) return TextAlign.left;
    return TextAlign.center;
  }

  double _anchorX(double a) {
    final c = math.cos(a);
    if (c < -0.3) return 1.0;
    if (c > 0.3) return 0.0;
    return 0.5;
  }

  double _anchorY(double a) {
    final s = math.sin(a);
    if (s < -0.3) return 1.0;
    if (s > 0.3) return 0.0;
    return 0.5;
  }

  @override
  bool shouldRepaint(_HeroRadarPainter old) =>
      old.values != values || old.fillColor != fillColor;
}
