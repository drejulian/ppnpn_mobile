// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ppnpm_dpr/app.dart';
import 'package:ppnpm_dpr/app/router.dart';

void main() {
  testWidgets('AppContent builds with a minimal router override', (
    WidgetTester tester,
  ) async {
    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('OK')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWith((ref) => testRouter)],
        child: const AppContent(),
      ),
    );

    await tester.pump();

    expect(find.text('OK'), findsOneWidget);
  });
}
