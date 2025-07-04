import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitense/main.dart';

void main() {
  testWidgets('Splitense app launches successfully', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const Splitense());

    // Wait for all animations and timers to complete
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}