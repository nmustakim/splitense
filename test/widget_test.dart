import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitense/main.dart';

void main() {
  testWidgets('Splitense app launches successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Splitense());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
