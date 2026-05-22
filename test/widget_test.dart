// Smoke test: SphereApp renders the brand mark.

import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/app/app.dart';

void main() {
  testWidgets('SphereApp renders brand mark', (WidgetTester tester) async {
    await tester.pumpWidget(const SphereApp());

    expect(find.text('SportSphere'), findsOneWidget);
  });
}
