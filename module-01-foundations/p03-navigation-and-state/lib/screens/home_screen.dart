// ============================================================
// P03 — Navigation & State Management
// File: lib/screens/home_screen.dart
//
// TOPIC: FutureProvider.when(), filtering, navigation
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../models/course.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered courses — rebuilds automatically when
    // selectedFilterProvider or coursesProvider changes
    final filteredCourses = ref.watch(filteredCoursesProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Modules'),
        actions: [
          // Counter in AppBar — shows Riverpod state update
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                'Taps: $counter',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Completed', 'Pending']
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: selectedFilter == filter,
                            onSelected: (_) {
                              // ref.read for event handlers
                              ref.read(selectedFilterProvider.notifier).state = filter;
                            },
                            selectedColor: const Color(0xFF0397D6).withValues(alpha: 0.2),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          // Course list — handles loading/error/data with .when()
          Expanded(
            child: filteredCourses.when(
              // Loading state — show a shimmer placeholder
              loading: () => const Center(child: CircularProgressIndicator()),

              // Error state — show message + retry
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Failed to load courses: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(coursesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),

              // Data state — build the list
              data: (courses) => courses.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No courses in this category'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _CourseCard(
                          course: courses[index],
                          onTap: () {
                            // Increment tap counter
                            ref.read(counterProvider.notifier).state++;
                            // Navigate to details with path parameter
                            context.go('/details/${courses[index].id}');
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0397D6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(course.icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(course.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_outlined, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  course.duration,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: course.isCompleted
            ? const Icon(Icons.check_circle, color: Color(0xFF6CB33E))
            : const Icon(Icons.chevron_right, color: Colors.grey),
        isThreeLine: true,
      ),
    );
  }
}
