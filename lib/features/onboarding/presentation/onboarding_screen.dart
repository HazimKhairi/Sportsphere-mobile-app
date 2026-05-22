import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_spacing.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    (
      title: 'Selamat datang ke SportSphere',
      body: 'Satu app untuk training, scheduling, dan analytics akademi kau.',
    ),
    (
      title: 'Train smart with Sphere AI',
      body: 'Drill analyzer dalam phone, AI coach yang faham game kau.',
    ),
    (
      title: 'Satu otak. Dua interface.',
      body: 'Player atau staff, semua dalam satu app.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie placeholder; replace in Phase 5.
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: SphereColors.surfaceElev1,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        const SizedBox(height: SphereSpacing.x32),
                        Text(
                          s.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SphereSpacing.x12),
                        Text(
                          s.body,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: SphereColors.onSurfaceMuted,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x24,
                vertical: SphereSpacing.x16,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? SphereColors.primary
                            : SphereColors.borderSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/role-pick'),
                    child: Text(
                      isLast ? '' : 'Skip',
                      style: const TextStyle(color: SphereColors.onSurfaceMuted),
                    ),
                  ),
                  const SizedBox(width: SphereSpacing.x8),
                  ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        context.go('/role-pick');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 48),
                    ),
                    child: Text(isLast ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
