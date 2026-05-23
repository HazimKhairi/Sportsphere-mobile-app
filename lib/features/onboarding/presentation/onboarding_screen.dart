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

  static const _slides = [
    _Slide(
      image: 'assets/onboarding/player.webp',
      alignment: Alignment.topCenter,
      headline: 'Train Smart,\nGrow Faster',
      subtitle: 'AI-powered drills and real-time feedback built for serious athletes.',
    ),
    _Slide(
      image: 'assets/onboarding/coach.webp',
      alignment: Alignment.topCenter,
      headline: 'Track Every\nSession Live',
      subtitle: 'Coaches rate your performance. Your card improves in real time.',
    ),
    _Slide(
      image: 'assets/onboarding/admin.webp',
      alignment: Alignment.centerRight,
      headline: 'One App.\nTwo Roles.',
      subtitle: 'Player or coach — everything you need is right here.',
    ),
  ];

  void _next() {
    if (_index == _slides.length - 1) {
      context.go('/role-pick');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _skip() => context.go('/role-pick');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF080D08),
        body: Stack(
          children: [
            // ── Full-screen page view ────────────────────────────────────
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
            ),

            // ── Bottom overlay ───────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomPanel(
                slide: _slides[_index],
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
    required this.image,
    required this.alignment,
    required this.headline,
    required this.subtitle,
  });
  final String image;
  final Alignment alignment;
  final String headline;
  final String subtitle;
}

// ─── SLIDE PAGE ───────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Image covers the top ~70% of screen, bottom panel sits over the gradient
    const panelH = 280.0;

    return Stack(
      children: [
        // ── Photo background (top portion, full-bleed) ─────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: panelH - 80,
          child: Image.asset(
            slide.image,
            fit: BoxFit.cover,
            alignment: slide.alignment,
            filterQuality: FilterQuality.high,
          ),
        ),

        // ── Gradient overlay: dark vignette from top + strong from bottom
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.25, 0.55, 0.78, 1.0],
                colors: [
                  const Color(0xFF080D08).withValues(alpha: 0.45),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF080D08).withValues(alpha: 0.7),
                  const Color(0xFF080D08),
                ],
              ),
            ),
          ),
        ),

        // ── Left-edge green accent line ────────────────────────────────
        Positioned(
          top: size.height * 0.18,
          bottom: panelH + 40,
          left: 0,
          child: Container(
            width: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  SphereColors.primary.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
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
        color: Color(0xFF0D120D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(28, 28, 28, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              slide.headline,
              key: ValueKey(slide.headline),
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF5F5F5),
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              slide.subtitle,
              key: ValueKey(slide.subtitle),
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF7A8A7A),
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Dots + Skip
          Row(
            children: [
              for (var i = 0; i < total; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(right: 6),
                  width: i == index ? 24 : 7,
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
  const _PillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

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
        scale: _press,
        child: Container(
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
