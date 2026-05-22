// Smoke test: SphereApp boots into the onboarding placeholder.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/app/app.dart';

void main() {
  testWidgets('SphereApp boots into onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SphereApp()));
    await tester.pump(); // settle initial frame
    expect(find.text('Onboarding placeholder'), findsOneWidget);
  });
}
