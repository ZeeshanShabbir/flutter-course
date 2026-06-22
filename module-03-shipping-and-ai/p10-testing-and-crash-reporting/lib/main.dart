// ============================================================
// P10 — Testing & Crash Reporting
// File: lib/main.dart  (the app being tested)
//
// Slide reference: "Writing Tests You Will Actually Run"
// Key quote: "A practical introduction to test-driven development"
//
// The REAL learning in P10 is in the test/ folder.
// This file is the simple app we're testing.
// See:
//   test/unit/calculator_test.dart     ← pure Dart logic tests
//   test/unit/task_validator_test.dart ← business rule tests
//   test/widget/task_card_test.dart    ← widget render tests
//   test/widget/login_form_test.dart   ← form validation tests
//   integration_test/app_test.dart     ← end-to-end tests
//
// RUN TESTS:
//   flutter test                           (all tests)
//   flutter test test/unit/               (unit tests only)
//   flutter test --coverage               (with coverage)
//   flutter drive --target=integration_test/app_test.dart
// ============================================================

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P10 — Testing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0397D6)),
        useMaterial3: true,
      ),
      home: const TestingHomeScreen(),
    );
  }
}

// ── Business Logic (what unit tests cover) ─────────────────
class Calculator {
  int add(int a, int b) => a + b;
  int subtract(int a, int b) => a - b;
  int multiply(int a, int b) => a * b;

  double divide(int a, int b) {
    if (b == 0) throw ArgumentError('Cannot divide by zero');
    return a / b;
  }
}

class TaskValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length < 3) return 'Title too short (min 3 chars)';
    if (value.trim().length > 100) return 'Title too long (max 100 chars)';
    return null;
  }

  static String? validateDueDate(DateTime? date) {
    if (date == null) return null; // optional
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  static bool isOverdue(DateTime? dueDate, {bool isCompleted = false}) {
    if (dueDate == null || isCompleted) return false;
    return dueDate.isBefore(DateTime.now());
  }
}

// ── Simple widget (what widget tests cover) ────────────────
class TaskCard extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: IconButton(
          key: const Key('toggle_button'),
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          title,
          key: const Key('task_title'),
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          key: const Key('delete_button'),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class TestingHomeScreen extends StatefulWidget {
  const TestingHomeScreen({super.key});

  @override
  State<TestingHomeScreen> createState() => _TestingHomeScreenState();
}

class _TestingHomeScreenState extends State<TestingHomeScreen> {
  final _calc = Calculator();
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Write unit tests', 'done': true},
    {'title': 'Write widget tests', 'done': false},
    {'title': 'Write integration tests', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P10 — Testing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0397D6).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📁 Test Files',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'test/unit/calculator_test.dart\n'
                  'test/unit/task_validator_test.dart\n'
                  'test/widget/task_card_test.dart\n'
                  'test/widget/login_form_test.dart\n'
                  'integration_test/app_test.dart',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Run: flutter test',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFF6CB33E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('The App Being Tested:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          ...List.generate(_tasks.length, (i) {
            return TaskCard(
              title: _tasks[i]['title'],
              isCompleted: _tasks[i]['done'],
              onToggle: () => setState(
                () => _tasks[i]['done'] = !_tasks[i]['done'],
              ),
              onDelete: () => setState(() => _tasks.removeAt(i)),
            );
          }),
        ],
      ),
    );
  }
}
