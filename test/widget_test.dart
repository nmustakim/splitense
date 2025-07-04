import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitense/main.dart';

void main() {
  testWidgets('Splitense app launches successfully', (
    WidgetTester tester,
  ) async {
    // Override animation behavior for testing
    await tester.binding.setSurfaceSize(const Size(800, 600));

    // Build the app
    await tester.pumpWidget(const Splitense());

    // Just pump once to build the initial frame
    await tester.pump();

    // Test that the app structure exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
