// Widget test for ContactScreen.
// Run: flutter test test/widget/contact_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportbet/screens/contact_screen.dart';

void main() {
  group('ContactScreen', () {
    testWidgets('builds and shows app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContactScreen(),
        ),
      );
      expect(find.text('Contact cricheroes'), findsOneWidget);
    });

    testWidgets('shows Write and Chat tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContactScreen(),
        ),
      );
      expect(find.text('Write'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
    });
  });
}
