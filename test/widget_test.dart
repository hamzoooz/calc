// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:modern_calculator/app.dart';

void main() {
  testWidgets('Calculator app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ModernCalculatorApp());
    await tester.pumpAndSettle();

    // Verify that the calculator displays initial state
    expect(find.text('0'), findsWidgets);
    expect(find.text('Standard'), findsOneWidget);
  });
}
