// ============================================================
// P10 — Testing & Crash Reporting
// File: test/unit/calculator_test.dart
//
// UNIT TESTS — test pure Dart logic in isolation.
// No Flutter, no widgets, no BuildContext.
// Fast: runs in milliseconds. Write many.
//
// Slide reference: "Unit tests for Dart logic with flutter_test"
// Key quote: "A practical introduction to test-driven development"
//
// RUN: flutter test test/unit/calculator_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:p10_testing_and_crash_reporting/main.dart';

void main() {
  // group() — organise related tests together
  group('Calculator', () {
    // Create a fresh Calculator for each test
    late Calculator calc;

    setUp(() {
      // setUp runs BEFORE each test in this group
      calc = Calculator();
    });

    // ── Addition ─────────────────────────────────────────────
    group('add()', () {
      test('adds two positive numbers', () {
        // Arrange - Act - Assert (AAA pattern)
        final result = calc.add(3, 5);
        expect(result, equals(8));
      });

      test('adds a positive and negative number', () {
        expect(calc.add(10, -3), equals(7));
      });

      test('adds two negative numbers', () {
        expect(calc.add(-4, -6), equals(-10));
      });

      test('adding zero returns the same number', () {
        expect(calc.add(42, 0), equals(42));
      });
    });

    // ── Subtraction ──────────────────────────────────────────
    group('subtract()', () {
      test('subtracts two numbers', () {
        expect(calc.subtract(10, 4), equals(6));
      });

      test('returns negative when result is negative', () {
        expect(calc.subtract(3, 7), equals(-4));
      });
    });

    // ── Multiplication ────────────────────────────────────────
    group('multiply()', () {
      test('multiplies two positive numbers', () {
        expect(calc.multiply(6, 7), equals(42));
      });

      test('multiplying by zero returns zero', () {
        expect(calc.multiply(100, 0), equals(0));
      });
    });

    // ── Division ─────────────────────────────────────────────
    group('divide()', () {
      test('divides evenly', () {
        expect(calc.divide(10, 2), equals(5.0));
      });

      test('returns decimal for non-even division', () {
        expect(calc.divide(7, 2), closeTo(3.5, 0.001));
      });

      test('throws ArgumentError when dividing by zero', () {
        // expect with throwsA — tests that an exception is thrown
        expect(
          () => calc.divide(10, 0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError with correct message', () {
        expect(
          () => calc.divide(10, 0),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Cannot divide by zero',
            ),
          ),
        );
      });
    });
  });
}
