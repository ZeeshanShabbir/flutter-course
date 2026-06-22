// ============================================================
// P03 — Navigation & State Management
// File: lib/providers/app_providers.dart
//
// TOPIC: Riverpod — StateProvider, FutureProvider, Provider
//
// Slide reference: "StateProvider, FutureProvider, StreamProvider"
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';

// ============================================================
// 1. StateProvider — simplest state for a single value
// Perfect for: counter, toggle, selected tab index, slider value
// ============================================================

// Counter — read with ref.watch(counterProvider)
// Increment with ref.read(counterProvider.notifier).state++
final counterProvider = StateProvider<int>((ref) => 0);

// Dark mode toggle
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Selected course filter
final selectedFilterProvider = StateProvider<String>((ref) => 'All');

// ============================================================
// 2. Provider — computed/derived value, no mutation
// Runs once; rebuilds automatically when its dependencies change.
// ============================================================

// Derived from counter — no extra state needed
final isCounterEvenProvider = Provider<bool>((ref) {
  final count = ref.watch(counterProvider);
  return count % 2 == 0;
});

// ============================================================
// 3. FutureProvider — wraps an async operation
// Returns AsyncValue<T> which has three states:
//   .loading → show a spinner
//   .data    → show the data
//   .error   → show an error message
//
// Use .when() to handle all three cases in the widget.
// ============================================================
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  // In production this would be: dio.get('/courses') or Firestore query
  // Here we simulate a network delay
  await Future.delayed(const Duration(milliseconds: 800));

  // Simulated course data — matches P03 slide examples
  return [
    Course(
      id: '1',
      title: 'Dart Crash Course',
      description: 'Variables, OOP, async/await, null safety',
      duration: '1 week',
      icon: '🎯',
      isCompleted: true,
    ),
    Course(
      id: '2',
      title: 'Flutter Fundamentals',
      description: 'Widget tree, Stateless/Stateful, Text, ListView',
      duration: '1 week',
      icon: '📱',
      isCompleted: true,
    ),
    Course(
      id: '3',
      title: 'Navigation & State',
      description: 'GoRouter, Riverpod, FutureProvider',
      duration: '1 week',
      icon: '🧭',
      isCompleted: false,
    ),
    Course(
      id: '4',
      title: 'Forms & Local Storage',
      description: 'Validation, Hive, SharedPreferences',
      duration: '1 week',
      icon: '📋',
      isCompleted: false,
    ),
    Course(
      id: '5',
      title: 'REST APIs & HTTP',
      description: 'Dio, JSON models, loading states',
      duration: '1 week',
      icon: '🌐',
      isCompleted: false,
    ),
    Course(
      id: '6',
      title: 'Firebase Full-Stack',
      description: 'Auth, Firestore, Storage, Security Rules',
      duration: '2 weeks',
      icon: '🔥',
      isCompleted: false,
    ),
  ];
});

// ============================================================
// 4. FILTERED PROVIDER — combines two providers
// This is where Riverpod shines: providers can depend on
// other providers. Flutter rebuilds ONLY what needs to change.
// ============================================================
final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final courses = ref.watch(coursesProvider);
  final filter = ref.watch(selectedFilterProvider);

  return courses.whenData((list) {
    if (filter == 'All') return list;
    if (filter == 'Completed') return list.where((c) => c.isCompleted).toList();
    return list.where((c) => !c.isCompleted).toList();
  });
});
