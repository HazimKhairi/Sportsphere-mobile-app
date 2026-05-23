import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/sphere_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _index = 0;
  late AnimationController _fadeCtrl;

  static const _slides = [
    _Slide(
      bgWord: 'TRAIN',
      headline: 'Train Smart,\nGrow Faster',
      subtitle: 'AI-powered drills and real-time feedback built for serious athletes.',
      image: 'assets/onboarding/player1.png',
    ),
    _Slide(
      bgWord: 'PERFORM',
      headline: 'Track Every\nSession Live',
      subtitle: 'Coaches rate your performance. Your card improves in real time.',
      image: 'assets/onboarding/player2.png',
    ),
    _Slide(
      bgWord: 'EXCEL',
      headline: 'One App.\nTwo Roles.',
      subtitle: 'Player or coach — everything you need is right here.',
      image: 'assets/onboarding/player3.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      context.go('/role-pick');
    } else {
      _fadeCtrl.reverse().then((_) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
        _fadeCtrl.forward();
      });
    }
  }

  void _skip() => context.go('/role-pick');

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final isLast = _index == _slides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F0A),
        body: Stack(
          children: [
            // ── Page content ────────────────────────────────────────────────
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => _SlidePage(slide: _slides[i]),
            ),

            // ── Bottom overlay (dots + button) ───────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomPanel(
                slide: slide,
                index: _index,
                total: _slides.length,
                isLast: isLast,
                onNext: _next,
                onSkip: _skip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SLIDE DATA ───────────────────────────────────────────────────────────────

class _Slide {
  const _Slide({
    required this.bgWord,
    required this.headline,
    required this.subtitle,
    required this.image,
  });
  final String bgWord;
  final String headline;
  final String subtitle;
  final String image;
}

// ─── SLIDE PAGE ───────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomPanelH = 240.0;

    return Container(
      color: const Color(0xFF0A0F0A),
      child: Stack(
        children: [
          // ── Giant background word ──────────────────────────────────────
          Positioned(
            top: size.height * 0.12,
            left: -24,
            right: -24,
            child: Text(
              slide.bgWord,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: size.width * 0.32,
                fontWeight: FontWeight.w900,
                color: SphereColors.primary.withValues(alpha: 0.18),
                letterSpacing: -4,
                height: 1.0,
              ),
            ),
          ),

          // ── Athlete photo (cutout PNG, overlaps bg word) ───────────────
          Positioned(
            top: size.height * 0.04,
            left: 0,
            right: 0,
            bottom: bottomPanelH - 60,
            child: Image.asset(
              slide.image,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
            ),
          ),

          // ── Green glow behind player ───────────────────────────────────
          Positioned(
            bottom: bottomPanelH,
            left: size.width * 0.2,
            right: size.width * 0.2,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: SphereColors.primary.withValues(alpha: 0.25),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BOTTOM PANEL ─────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.slide,
    required this.index,
    required this.total,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });
  final _Slide slide;
  final int index;
  final int total;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111811),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(28, 24, 28, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline
          Text(
            slide.headline,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF5F5F5),
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            slide.subtitle,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7A8A7A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Dots + Skip row
          Row(
            children: [
              // Progress dots
              for (var i = 0; i < total; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(right: 6),
                  width: i == index ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == index
                        ? SphereColors.primary
                        : const Color(0xFF2A3A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              const Spacer(),
              if (!isLast)
                GestureDetector(
                  onTap: onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A5A4A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // CTA button
          _PillButton(
            label: isLast ? 'Get Started' : 'Next',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// ─── PILL BUTTON ──────────────────────────────────────────────────────────────

class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
  });
  final String label;
  final VoidCallback onTap;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _press;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: 58,
          decoration: BoxDecoration(
            color: SphereColors.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: SphereColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF071A02),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
