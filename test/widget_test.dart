import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:splitense/main.dart';

void main() {
  testWidgets('Splitense app launches successfully', (
    WidgetTester tester,
  ) async {
    // Set animation duration to nearly zero
    Animate.defaultDuration = const Duration(milliseconds: 1);

    await tester.pumpWidget(const Splitense());

    // Pump with a very short duration to let animations complete quickly
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byType(MaterialApp), findsOneWidget);

    // Final pump to clean up
    await tester.pump();
  });
}
