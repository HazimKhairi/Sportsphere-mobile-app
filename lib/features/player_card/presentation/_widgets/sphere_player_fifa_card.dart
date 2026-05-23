import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/player_card_data.dart';

// ─── PUBLIC FIFA CARD WIDGET ─────────────────────────────────────────────────

/// Renders the FIFA-style player card. Pass [cardWidth] to control size;
/// height is derived from the fixed 280:380 aspect ratio.
class SphereFifaCard extends StatelessWidget {
  const SphereFifaCard({
    super.key,
    required this.card,
    this.cardWidth,
  });

  final PlayerCardData card;

  /// If null, fills available width (clamped 240–340).
  final double? cardWidth;

  static const _aspect = 280.0 / 380.0;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width - 32;
    final w = cardWidth ?? screenW.clamp(240.0, 340.0);
    final h = w / _aspect;
    final colors = _rarityColors(card.rarityTier);

    return Center(
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.glow.withValues(alpha: 0.4),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(painter: _CardPatternPainter(colors.accent)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top: OVR + position + rarity | brand
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${card.ovr}',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: colors.text,
                              height: 1,
                            ),
                          ),
                          Text(
                            card.position,
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.text.withValues(alpha: 0.78),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.text.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: colors.text.withValues(alpha: 0.24)),
                            ),
                            child: Text(
                              card.rarityTier.label.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: colors.text,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'SPORTSPHERE',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.text.withValues(alpha: 0.47),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Player photo
                  Expanded(
                    child: _PlayerPhoto(
                        photoUrl: card.playerPhoto, colors: colors),
                  ),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    card.playerName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: colors.text,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Stats
                  _StatsRow(stats: card.activeStats, colors: colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── INTERNAL WIDGETS ─────────────────────────────────────────────────────────

class _PlayerPhoto extends StatelessWidget {
  const _PlayerPhoto({this.photoUrl, required this.colors});
  final String? photoUrl;
  final _RarityColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.text.withValues(alpha: 0.06),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => _silhouette(),
            )
          : _silhouette(),
    );
  }

  Widget _silhouette() => Center(
        child:
            Icon(LucideIcons.user, size: 72, color: colors.text.withValues(alpha: 0.24)),
      );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.colors});
  final List<StatEntry> stats;
  final _RarityColors colors;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((s) {
        return Column(
          children: [
            Text(
              '${s.value}',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
            ),
            Text(
              s.key,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: colors.text.withValues(alpha: 0.63),
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── RARITY COLORS ────────────────────────────────────────────────────────────

class _RarityColors {
  const _RarityColors({
    required this.gradient,
    required this.text,
    required this.accent,
    required this.glow,
  });
  final List<Color> gradient;
  final Color text;
  final Color accent;
  final Color glow;
}

_RarityColors _rarityColors(RarityTier tier) => switch (tier) {
      RarityTier.bronze => const _RarityColors(
          gradient: [Color(0xFFCD7F32), Color(0xFF8B4513)],
          text: Color(0xFFFFF8F0),
          accent: Color(0xFFCD7F32),
          glow: Color(0xFFCD7F32),
        ),
      RarityTier.silver => const _RarityColors(
          gradient: [Color(0xFFC0C0C0), Color(0xFF708090)],
          text: Color(0xFFF8F9FA),
          accent: Color(0xFFC0C0C0),
          glow: Color(0xFFC0C0C0),
        ),
      RarityTier.gold => const _RarityColors(
          gradient: [Color(0xFFFFD700), Color(0xFFB8860B)],
          text: Color(0xFF1A1000),
          accent: Color(0xFFFFD700),
          glow: Color(0xFFFFD700),
        ),
      RarityTier.diamond => const _RarityColors(
          gradient: [Color(0xFF48CAE4), Color(0xFF0077B6), Color(0xFF023E8A)],
          text: Color(0xFFE0F4FF),
          accent: Color(0xFF48CAE4),
          glow: Color(0xFF48CAE4),
        ),
    };

// ─── CARD PATTERN PAINTER ─────────────────────────────────────────────────────

class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i < 12; i++) {
      final y = size.height * i / 12;
      final angle = math.pi / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width * math.tan(angle)), paint);
    }
  }

  @override
  bool shouldRepaint(_CardPatternPainter old) => old.color != color;
}
