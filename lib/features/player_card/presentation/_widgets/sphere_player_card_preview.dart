import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/sphere_theme_ext.dart';
import '../../domain/player_card_data.dart';

const _kDark = Color(0xFF0A0A0A);
const _kDarkElev = Color(0xFF1E1E1E);
const _kDarkBorder = Color(0xFF2A2A2A);

/// Compact version of the player card screen design, for embedding in home.
class SpherePlayerCardPreview extends StatelessWidget {
  const SpherePlayerCardPreview({
    super.key,
    required this.card,
    this.onTap,
  });

  final PlayerCardData card;
  final VoidCallback? onTap;

  Color _tierColor() => switch (card.rarityTier) {
        RarityTier.gold => const Color(0xFFFFD700),
        RarityTier.diamond => const Color(0xFF48CAE4),
        RarityTier.silver => const Color(0xFFC0C0C0),
        _ => const Color(0xFFCD7F32),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kDarkBorder),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Photo hero area ───────────────────────────────────────────
            _PhotoHero(card: card, tierColor: _tierColor()),

            // ── Info panel ───────────────────────────────────────────────
            Container(
              color: _kDark,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Club row
                  _ClubRow(card: card),
                  const SizedBox(height: 10),

                  // Player name
                  Text(
                    card.playerName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Position + league label
                  _PositionRow(card: card),
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

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.card, required this.tierColor});
  final PlayerCardData card;
  final Color tierColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          if (card.playerPhoto != null)
            Image.network(
              card.playerPhoto!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, _) => const _PhotoFallback(),
            )
          else
            const _PhotoFallback(),

          // Gradient overlay — dark at top and bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    _kDark,
                  ],
                ),
              ),
            ),
          ),

          // OVR — bottom left
          Positioned(
            left: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${card.ovr}',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 48,
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
            bottom: 24,
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
          child: Icon(LucideIcons.user, size: 64, color: Colors.white12),
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
  const _PositionRow({required this.card});
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
