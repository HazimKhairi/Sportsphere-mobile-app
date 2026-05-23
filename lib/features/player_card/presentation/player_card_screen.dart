import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_theme_ext.dart';
import '../domain/player_card_data.dart';
import 'player_card_providers.dart';

// ─── CONSTANTS ────────────────────────────────────────────────────────────────

const _kDark = Color(0xFF0A0A0A);
const _kDarkCard = Color(0xFF141414);
const _kDarkElev = Color(0xFF1E1E1E);
const _kDarkBorder = Color(0xFF2A2A2A);

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class PlayerCardScreen extends ConsumerWidget {
  const PlayerCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerCardProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kDark,
        extendBodyBehindAppBar: true,
        body: state.when(
          loading: () => const _LoadingView(),
          error: (e, _) => _ErrorView(onRetry: () => ref.invalidate(playerCardProvider)),
          data: (data) => _CardBody(
            card: data.card,
            summary: data.summary,
            onRefresh: () => ref.invalidate(playerCardProvider),
          ),
        ),
      ),
    );
  }
}

// ─── LOADING ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _OverlayButton(
              icon: LucideIcons.chevronLeft,
              onTap: () => context.canPop() ? context.pop() : context.go('/card'),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── BODY ─────────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.card,
    required this.summary,
    required this.onRefresh,
  });
  final PlayerCardData card;
  final TrainingSummary? summary;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final heroH = screenH * 0.48;

    return Stack(
      children: [
        // ── Scrollable content ──────────────────────────────────────────────
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero placeholder (photo drawn in Stack below)
                  SizedBox(height: heroH),

                  // ── Dark content panel ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _kDark,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Club + jersey badge row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ClubBadgeRow(card: card),
                        ),
                        const SizedBox(height: 20),

                        // Player name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            card.playerName.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Position + OVR row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _PositionOvrRow(card: card),
                        ),
                        const SizedBox(height: 24),

                        // Stats grid
                        if (card.activeStats.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _StatsGrid(stats: card.activeStats),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Radar chart
                        if (card.activeStats.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _RadarSection(stats: card.activeStats),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Training summary (compact)
                        if (summary != null && summary!.totalRatedSessions > 0) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _TrainingRow(summary: summary!),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Bottom safe area
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Hero photo (behind scroll) ──────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: heroH,
          child: _HeroPhoto(card: card),
        ),

        // ── Overlay buttons (always on top) ────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _OverlayButton(
                  icon: LucideIcons.chevronLeft,
                  onTap: () => context.canPop() ? context.pop() : context.go('/card'),
                ),
                const Spacer(),
                _OverlayButton(
                  icon: LucideIcons.refreshCw,
                  onTap: onRefresh,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── HERO PHOTO ───────────────────────────────────────────────────────────────

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.card});
  final PlayerCardData card;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background colour
        Container(color: const Color(0xFF1A1A1A)),

        // Player photo
        if (card.playerPhoto != null)
          Image.network(
            card.playerPhoto!,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (ctx, err, st) => const _PhotoFallback(),
          )
        else
          const _PhotoFallback(),

        // Gradient: subtle at top, strong at bottom
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  _kDark,
                ],
              ),
            ),
          ),
        ),

        // OVR badge — top-left info area (below back button)
        Positioned(
          left: 20,
          bottom: 28,
          child: _OvrBadge(ovr: card.ovr, tier: card.rarityTier),
        ),

        // Rarity tier label — bottom-right
        Positioned(
          right: 20,
          bottom: 32,
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
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Center(
        child: Icon(LucideIcons.user, size: 80, color: Colors.white12),
      ),
    );
  }
}

class _OvrBadge extends StatelessWidget {
  const _OvrBadge({required this.ovr, required this.tier});
  final int ovr;
  final RarityTier tier;

  Color _tierColor() => switch (tier) {
        RarityTier.gold => const Color(0xFFFFD700),
        RarityTier.diamond => const Color(0xFF48CAE4),
        RarityTier.silver => const Color(0xFFC0C0C0),
        _ => const Color(0xFFCD7F32),
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$ovr',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: _tierColor(),
            height: 1.0,
          ),
        ),
        Text(
          'OVR',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _tierColor().withValues(alpha: 0.7),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── CLUB + JERSEY ROW ────────────────────────────────────────────────────────

class _ClubBadgeRow extends StatelessWidget {
  const _ClubBadgeRow({required this.card});
  final PlayerCardData card;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Club icon placeholder
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _kDarkElev,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kDarkBorder),
          ),
          child: const Center(
            child: Icon(LucideIcons.shield, size: 18, color: Colors.white38),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            card.clubName ?? 'Independent',
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        if (card.age != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

// ─── POSITION + OVR ROW ───────────────────────────────────────────────────────

class _PositionOvrRow extends StatelessWidget {
  const _PositionOvrRow({required this.card});
  final PlayerCardData card;

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

// ─── STATS GRID ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final List<StatEntry> stats;

  Color _valueColor(int v) {
    if (v >= 80) return const Color(0xFF4ADE80);
    if (v >= 65) return const Color(0xFF60A5FA);
    if (v >= 50) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: stats.map((s) {
        final col = _valueColor(s.value);
        return Container(
          decoration: BoxDecoration(
            color: _kDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kDarkBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${s.value}',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: col,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.key,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── RADAR SECTION ────────────────────────────────────────────────────────────

class _RadarSection extends StatelessWidget {
  const _RadarSection({required this.stats});
  final List<StatEntry> stats;

  @override
  Widget build(BuildContext context) {
    final values = stats.map((s) => (s.value / 100).clamp(0.0, 1.0)).toList();
    final labels = stats.map((s) => s.key).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kDarkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skill Profile',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _PlayerRadarPainter(
                values: values,
                labels: labels,
                fillColor: context.sc.primary,
                gridColor: Colors.white12,
                labelColor: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRadarPainter extends CustomPainter {
  _PlayerRadarPainter({
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

    // Draw rings
    for (int r = 1; r <= _rings; r++) {
      final radius = maxR * (r / _rings);
      final path = Path();
      for (int i = 0; i < n; i++) {
        final p = _point(center, radius, i, n);
        if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw spokes
    for (int i = 0; i < n; i++) {
      final p = _point(center, maxR, i, n);
      canvas.drawLine(center, p, gridPaint);
    }

    // Filled polygon
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
      if (i == 0) { dataPath.moveTo(p.dx, p.dy); } else { dataPath.lineTo(p.dx, p.dy); }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Dots
    final dotPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      final p = _point(center, maxR * values[i], i, n);
      canvas.drawCircle(p, 4, dotPaint);
    }

    // Labels
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
  bool shouldRepaint(_PlayerRadarPainter old) =>
      old.values != values || old.fillColor != fillColor;
}

// ─── TRAINING ROW ─────────────────────────────────────────────────────────────

class _TrainingRow extends StatelessWidget {
  const _TrainingRow({required this.summary});
  final TrainingSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kDarkBorder),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.barChart2, size: 16, color: Colors.white38),
          const SizedBox(width: 10),
          const Text(
            'Training Sessions',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const Spacer(),
          Text(
            '${summary.totalRatedSessions}',
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OVERLAY BUTTON ───────────────────────────────────────────────────────────

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── ERROR ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.idCard, size: 56, color: Colors.white24),
                const SizedBox(height: 16),
                const Text(
                  'Card not available',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your player card appears when a coach has rated your attributes at least once.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white38, height: 1.5),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _OverlayButton(
              icon: LucideIcons.chevronLeft,
              onTap: () => context.canPop() ? context.pop() : context.go('/card'),
            ),
          ),
        ),
      ],
    );
  }
}
