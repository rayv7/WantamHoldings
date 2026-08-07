import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wantam_holdings/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard shows greeting and recent transactions', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.textContaining('Good Morning'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });
}
