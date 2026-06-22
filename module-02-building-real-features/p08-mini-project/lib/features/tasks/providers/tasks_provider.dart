// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/features/tasks/providers/tasks_provider.dart
//
// Riverpod AsyncNotifier — manages task list state.
// Slide reference: P13 "Riverpod Architecture"
// Key quote: "3. Notifier — UI state: each layer independently
//             mockable — swap the API in tests."
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

// ============================================================
// TASKS NOTIFIER
// AsyncNotifier<T>: the modern Riverpod v2 way to manage
// async state (replaces StateNotifier + FutureProvider combo).
//
// build() runs on first access and on invalidation (refresh).
// Methods can mutate state and call the repository.
// ============================================================
class TasksNotifier extends AsyncNotifier<List<Task>> {
  // build() = initial data load
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return repo.getAllTasks();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    final repo = ref.read(taskRepositoryProvider);

    // Optimistic update — show the task immediately
    // If the server call fails, we roll back
    final previousState = state;
    state = AsyncData([task, ...state.valueOrNull ?? []]);

    try {
      final created = await repo.createTask(task);
      // Replace the temporary task with the server-confirmed version
      state = AsyncData(
        state.valueOrNull
                ?.map((t) => t.id == task.id ? created : t)
                .toList() ??
            [],
      );
    } catch (e) {
      // Rollback on failure
      state = previousState;
      rethrow;
    }
  }

  // Toggle complete/incomplete
  Future<void> toggleComplete(String taskId) async {
    final repo = ref.read(taskRepositoryProvider);
    final tasks = state.valueOrNull ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    // Optimistic update
    state = AsyncData(
      tasks
          .map((t) => t.id == taskId
              ? t.copyWith(isCompleted: !t.isCompleted)
              : t)
          .toList(),
    );

    try {
      await repo.toggleComplete(taskId);
    } catch (e) {
      // Rollback
      state = AsyncData(tasks);
      rethrow;
    }
  }

  // Update a task
  Future<void> updateTask(Task updated) async {
    final repo = ref.read(taskRepositoryProvider);
    final previous = state.valueOrNull ?? [];

    state = AsyncData(
      previous.map((t) => t.id == updated.id ? updated : t).toList(),
    );

    try {
      await repo.updateTask(updated);
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final repo = ref.read(taskRepositoryProvider);
    final previous = state.valueOrNull ?? [];

    state = AsyncData(previous.where((t) => t.id != taskId).toList());

    try {
      await repo.deleteTask(taskId);
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  // Refresh from server
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(taskRepositoryProvider);
      return repo.getAllTasks();
    });
  }
}

// ============================================================
// PROVIDERS
// ============================================================

// Main tasks list
final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

// Filter options
enum TaskFilter { all, active, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

// Filtered list — derived from tasks + filter
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasks.whenData((list) {
    return switch (filter) {
      TaskFilter.all => list,
      TaskFilter.active => list.where((t) => !t.isCompleted).toList(),
      TaskFilter.completed => list.where((t) => t.isCompleted).toList(),
    };
  });
});

// Stats — also derived, used in profile/dashboard
final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return {
    'total': tasks.length,
    'completed': tasks.where((t) => t.isCompleted).length,
    'active': tasks.where((t) => !t.isCompleted).length,
  };
});
