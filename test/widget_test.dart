// Quality & smoke tests for Innings / Cricapp.
// Run: flutter test test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportbet/main.dart';

void main() {
  group('App smoke tests', () {
    testWidgets('App builds and shows splash scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(const CricbuzzApp());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('MaterialApp has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const CricbuzzApp());
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Innings'));
    });

    testWidgets('App uses DefaultPageBackground in builder', (WidgetTester tester) async {
      await tester.pumpWidget(const CricbuzzApp());
      expect(find.byType(MaterialApp), findsOneWidget);
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.builder, isNotNull);
    });
  });
}
