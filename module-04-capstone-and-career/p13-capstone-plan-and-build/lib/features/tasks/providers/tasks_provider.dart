// ============================================================
// P13 — Capstone
// File: lib/features/tasks/providers/tasks_provider.dart
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

// Simulated in-memory task store (replace with Firestore in production)
final _sampleTasks = [
  Task(id: '1', title: 'Set up Firebase project', status: TaskStatus.done,
    priority: TaskPriority.high, category: TaskCategory.work,
    createdAt: DateTime.now().subtract(const Duration(days: 7))),
  Task(id: '2', title: 'Implement auth screens', status: TaskStatus.done,
    priority: TaskPriority.high, category: TaskCategory.work,
    createdAt: DateTime.now().subtract(const Duration(days: 5))),
  Task(id: '3', title: 'Build task CRUD with Firestore', status: TaskStatus.inProgress,
    priority: TaskPriority.high, category: TaskCategory.work,
    dueDate: DateTime.now().add(const Duration(days: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 3))),
  Task(id: '4', title: 'Add push notifications', status: TaskStatus.todo,
    priority: TaskPriority.medium, category: TaskCategory.work,
    dueDate: DateTime.now().add(const Duration(days: 5)),
    createdAt: DateTime.now().subtract(const Duration(days: 2))),
  Task(id: '5', title: 'Write unit tests', status: TaskStatus.todo,
    priority: TaskPriority.medium, category: TaskCategory.study,
    createdAt: DateTime.now().subtract(const Duration(days: 1))),
  Task(id: '6', title: 'Prepare for mock interview', status: TaskStatus.todo,
    priority: TaskPriority.urgent, category: TaskCategory.personal,
    dueDate: DateTime.now().add(const Duration(days: 1)),
    createdAt: DateTime.now()),
];

class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_sampleTasks);
  }

  Future<void> addTask(Task task) async {
    final prev = state.valueOrNull ?? [];
    state = AsyncData([task, ...prev]);
    // TODO: await _firestoreRepo.create(task);
  }

  Future<void> updateTask(Task task) async {
    final prev = state.valueOrNull ?? [];
    state = AsyncData(prev.map((t) => t.id == task.id ? task : t).toList());
    // TODO: await _firestoreRepo.update(task);
  }

  Future<void> deleteTask(String id) async {
    final prev = state.valueOrNull ?? [];
    state = AsyncData(prev.where((t) => t.id != id).toList());
    // TODO: await _firestoreRepo.delete(id);
  }

  Future<void> updateStatus(String id, TaskStatus status) async {
    final tasks = state.valueOrNull ?? [];
    final task = tasks.firstWhere((t) => t.id == id);
    await updateTask(task.copyWith(status: status));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 800));
    state = AsyncData(List.from(_sampleTasks));
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

enum TaskFilter { all, active, completed, overdue }
final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);
  return tasks.whenData((list) => switch (filter) {
    TaskFilter.all => list,
    TaskFilter.active => list.where((t) => !t.status.isComplete).toList(),
    TaskFilter.completed => list.where((t) => t.status.isComplete).toList(),
    TaskFilter.overdue => list.where((t) => t.isOverdue).toList(),
  });
});

final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return {
    'total': tasks.length,
    'completed': tasks.where((t) => t.status.isComplete).length,
    'active': tasks.where((t) => !t.status.isComplete).length,
    'overdue': tasks.where((t) => t.isOverdue).length,
    'dueToday': tasks.where((t) => t.isDueToday && !t.status.isComplete).length,
  };
});
