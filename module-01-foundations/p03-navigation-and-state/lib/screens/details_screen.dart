// ============================================================
// P03 — Navigation & State Management
// File: lib/screens/details_screen.dart
//
// TOPIC: Receiving path parameters, GoRouter navigation
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';

class DetailsScreen extends ConsumerWidget {
  // The :id from the route /details/:id is passed as a constructor param
  final String itemId;
  const DetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the course list to find the one we want
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        // GoRouter-aware back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // or context.go('/')
        ),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (courses) {
          // Find the course by ID passed via path parameter
          final course = courses.where((c) => c.id == itemId).firstOrNull;

          if (course == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Course #$itemId not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course emoji icon
                Center(
                  child: Text(course.icon, style: const TextStyle(fontSize: 64)),
                ),
                const SizedBox(height: 20),

                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    _StatChip(icon: Icons.access_time, label: course.duration),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: course.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      label: course.isCompleted ? 'Completed' : 'Pending',
                      color: course.isCompleted
                          ? const Color(0xFF6CB33E)
                          : const Color(0xFF0397D6),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Path parameter demo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0397D6).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GoRouter Path Parameter',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Route: /details/$itemId\n'
                        'Extracted with: state.pathParameters[\'id\']',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF0397D6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
