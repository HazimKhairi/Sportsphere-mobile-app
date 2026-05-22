// Smoke test: SphereApp boots into the splash screen.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/app/app.dart';

void main() {
  testWidgets('SphereApp boots into splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SphereApp()));
    await tester.pump();
    // Splash shows the brand icon.
    expect(find.byType(Image), findsOneWidget);
    // Drain the 1200ms post-splash navigation timer + 600ms animation so the
    // test tree disposes cleanly without leaking timers. We can't pumpAndSettle
    // after navigation lands on /onboarding because the SphereOnboardingIllustration
    // runs an infinite pulse animation. Use a fixed pump instead.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
