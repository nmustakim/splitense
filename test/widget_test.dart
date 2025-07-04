import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitense/main.dart';

void main() {
  testWidgets('Splitense app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Splitense());

    // Verify that the app launches without crashing
    expect(find.byType(MaterialApp), findsOneWidget);

    // You can add more specific checks here based on your app's main screen
    // For example, if your main screen has a title:
    // expect(find.text('Splitense'), findsOneWidget);
  });
}