import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../domain/player_card_data.dart';
import 'player_card_providers.dart';

class PlayerCardScreen extends ConsumerWidget {
  const PlayerCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerCardProvider);

    return Scaffold(
      backgroundColor: context.sc.background,
      appBar: AppBar(
        title: const Text('My Card'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.invalidate(playerCardProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(onRetry: () => ref.invalidate(playerCardProvider)),
        data: (data) => _CardBody(card: data.card, summary: data.summary),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.card, this.summary});
  final PlayerCardData card;
  final TrainingSummary? summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _FifaCard(card: card),
        const SizedBox(height: 20),
        _AttributesGrid(card: card),
        if (summary != null && summary!.totalRatedSessions > 0) ...[
          const SizedBox(height: 20),
          _TrainingSummaryCard(summary: summary!),
        ],
        const SizedBox(height: 20),
        _TipsCard(),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── FIFA-STYLE CARD ──────────────────────────────────────────────────────────

class _FifaCard extends StatelessWidget {
  const _FifaCard({required this.card});
  final PlayerCardData card;

  static const _cardAspect = 280.0 / 380.0;

  @override
  Widget build(BuildContext context) {
    final colors = _rarityColors(card.rarityTier);
    final screenW = MediaQuery.sizeOf(context).width - 32;
    final cardW = screenW.clamp(240.0, 340.0);
    final cardH = cardW / _cardAspect;

    return Center(
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.glow.withAlpha(100),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle pattern overlay
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
                  // Top row: OVR + position left, name right
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
                              color: colors.text.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.text.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.text.withAlpha(60)),
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
                          color: colors.text.withAlpha(120),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Player photo
                  Expanded(
                    child: _PlayerPhoto(photoUrl: card.playerPhoto, colors: colors),
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
                  // Stats row
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

class _PlayerPhoto extends StatelessWidget {
  const _PlayerPhoto({this.photoUrl, required this.colors});
  final String? photoUrl;
  final _RarityColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.text.withAlpha(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _silhouette(colors),
            )
          : _silhouette(colors),
    );
  }

  Widget _silhouette(_RarityColors c) {
    return Center(
      child: Icon(LucideIcons.user, size: 72, color: c.text.withAlpha(60)),
    );
  }
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
                color: colors.text.withAlpha(160),
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── ATTRIBUTES GRID ─────────────────────────────────────────────────────────

class _AttributesGrid extends StatelessWidget {
  const _AttributesGrid({required this.card});
  final PlayerCardData card;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final stats = card.activeStats;
    if (stats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.isGoalkeeper ? 'Goalkeeper Attributes' : 'Player Attributes',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: stats.map((s) => _AttrTile(stat: s)).toList(),
        ),
      ],
    );
  }
}

class _AttrTile extends StatelessWidget {
  const _AttrTile({required this.stat});
  final StatEntry stat;

  Color _barColor(BuildContext context, int v) {
    if (v >= 80) return context.sc.primary;
    if (v >= 65) return context.sc.accentBlue;
    if (v >= 50) return context.sc.accentAmber;
    return context.sc.danger;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pct = (stat.value / 100).clamp(0.0, 1.0);
    final barColor = _barColor(context, stat.value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.sc.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(stat.key,
                  style: tt.labelSmall
                      ?.copyWith(color: context.sc.onSurfaceMuted, letterSpacing: 0.8)),
              const Spacer(),
              Text('${stat.value}',
                  style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800, color: barColor)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: context.sc.surfaceElev1,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TRAINING SUMMARY ─────────────────────────────────────────────────────────

class _TrainingSummaryCard extends StatelessWidget {
  const _TrainingSummaryCard({required this.summary});
  final TrainingSummary summary;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final lastRated = summary.lastRatedAt != null
        ? _formatDate(summary.lastRatedAt!)
        : 'Never';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.sc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.barChart2, size: 16, color: context.sc.primary),
              const SizedBox(width: 8),
              Text('Training Summary',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SummaryTile(label: 'Rated Sessions', value: '${summary.totalRatedSessions}')),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile(label: 'Last Rated', value: lastRated)),
            ],
          ),
          if (summary.perAttribute.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Last 6 Ratings per Attribute',
                style: tt.labelSmall
                    ?.copyWith(color: context.sc.onSurfaceMuted, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            ...summary.perAttribute.map((a) => _SparklineRow(attr: a)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day} ${_months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '–';
    }
  }

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.bodySmall),
          const SizedBox(height: 4),
          Text(value,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SparklineRow extends StatelessWidget {
  const _SparklineRow({required this.attr});
  final AttributeSummary attr;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final trendColor = switch (attr.trend) {
      'up' => context.sc.primary,
      'down' => context.sc.danger,
      _ => context.sc.onSurfaceMuted,
    };
    final trendIcon = switch (attr.trend) {
      'up' => LucideIcons.trendingUp,
      'down' => LucideIcons.trendingDown,
      _ => LucideIcons.minus,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(attr.key,
                style: tt.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: context.sc.onSurface)),
          ),
          Expanded(
            child: _Sparkline(values: attr.history),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              attr.latest != null ? '${attr.latest}' : '–',
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          Icon(trendIcon, size: 14, color: trendColor),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Text('No ratings yet',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: context.sc.onSurfaceSubtle));
    }
    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final pct = (v / 5).clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: pct.clamp(0.08, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.sc.primary.withAlpha(160),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── TIPS ─────────────────────────────────────────────────────────────────────

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  static const _tips = [
    'Train consistently — even 20 minutes a day compounds over time.',
    'Focus on your lowest-rated attributes first for fastest OVR growth.',
    'Attend all coach-rated sessions to keep your card up to date.',
    'Work with your coaches on specific skill drills for your position.',
    'Perform consistently in matches to build your overall rating.',
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.sc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lightbulb, size: 16, color: context.sc.accentAmber),
              const SizedBox(width: 8),
              Text('Development Tips',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ..._tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.circleCheck,
                        size: 14, color: context.sc.primary),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(tip,
                            style: tt.bodySmall
                                ?.copyWith(color: context.sc.onSurfaceMuted))),
                  ],
                ),
              )),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.idCard, size: 56, color: context.sc.onSurfaceMuted),
            const SizedBox(height: 16),
            Text('Card not available',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Your player card appears when a coach has rated your attributes at least once.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.sc.onSurfaceMuted),
            ),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─── RARITY COLORS ───────────────────────────────────────────────────────────

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

// ─── CARD PATTERN PAINTER ────────────────────────────────────────────────────

class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i < 12; i++) {
      final y = size.height * i / 12;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 20), paint);
    }
  }

  @override
  bool shouldRepaint(_CardPatternPainter old) => old.color != color;
}
