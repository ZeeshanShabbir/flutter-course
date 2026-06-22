// ============================================================
// P10 — Testing & Crash Reporting
// File: test/widget/task_card_test.dart
//
// WIDGET TESTS — test Flutter widgets in isolation.
// Uses WidgetTester to pump widgets, find elements, and tap.
// Faster than integration tests, slower than unit tests.
//
// Slide reference: "Widget tests — pumping widgets and using
//                  the finder API"
//
// RUN: flutter test test/widget/task_card_test.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p10_testing_and_crash_reporting/main.dart';

void main() {
  group('TaskCard widget', () {
    // Helper to pump a TaskCard in a minimal app
    Future<void> pumpTaskCard(
      WidgetTester tester, {
      required String title,
      required bool isCompleted,
      VoidCallback? onToggle,
      VoidCallback? onDelete,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: title,
              isCompleted: isCompleted,
              onToggle: onToggle ?? () {},
              onDelete: onDelete ?? () {},
            ),
          ),
        ),
      );
    }

    // ── Rendering ─────────────────────────────────────────────
    testWidgets('displays the task title', (tester) async {
      await pumpTaskCard(
        tester,
        title: 'Learn Flutter testing',
        isCompleted: false,
      );

      // find.text() — locate widgets by text content
      expect(find.text('Learn Flutter testing'), findsOneWidget);
    });

    testWidgets('shows check icon when completed', (tester) async {
      await pumpTaskCard(
        tester,
        title: 'Done task',
        isCompleted: true,
      );

      // find.byIcon() — locate widgets by icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows unchecked icon when not completed', (tester) async {
      await pumpTaskCard(
        tester,
        title: 'Pending task',
        isCompleted: false,
      );

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('shows strikethrough text when completed', (tester) async {
      await pumpTaskCard(
        tester,
        title: 'Completed task',
        isCompleted: true,
      );

      // find.byKey() — locate by semantic key
      final titleWidget = tester.widget<Text>(find.byKey(const Key('task_title')));
      expect(
        titleWidget.style?.decoration,
        equals(TextDecoration.lineThrough),
      );
    });

    // ── Interactions ──────────────────────────────────────────
    testWidgets('calls onToggle when toggle button is tapped', (tester) async {
      bool toggled = false;

      await pumpTaskCard(
        tester,
        title: 'Toggle test',
        isCompleted: false,
        onToggle: () => toggled = true,
      );

      // tester.tap() — simulate a tap
      await tester.tap(find.byKey(const Key('toggle_button')));
      await tester.pump(); // rebuild after state change

      expect(toggled, isTrue);
    });

    testWidgets('calls onDelete when delete button is tapped', (tester) async {
      bool deleted = false;

      await pumpTaskCard(
        tester,
        title: 'Delete test',
        isCompleted: false,
        onDelete: () => deleted = true,
      );

      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pump();

      expect(deleted, isTrue);
    });

    // ── Accessibility ─────────────────────────────────────────
    testWidgets('meets accessibility contrast requirements',
        (tester) async {
      await pumpTaskCard(
        tester,
        title: 'Accessibility test',
        isCompleted: false,
      );

      // Verify the widget tree has no accessibility issues
      // (contrast, tap target size, etc.)
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  });

  // ── Testing a screen with async data ─────────────────────
  group('TestingHomeScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: TestingHomeScreen(),
      ));

      // pumpAndSettle waits for all animations and futures to complete
      await tester.pumpAndSettle();

      // Verify the screen title is present
      expect(find.text('P10 — Testing'), findsOneWidget);
    });

    testWidgets('shows initial task list', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: TestingHomeScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Write unit tests'), findsOneWidget);
      expect(find.text('Write widget tests'), findsOneWidget);
      expect(find.text('Write integration tests'), findsOneWidget);
    });
  });
}
