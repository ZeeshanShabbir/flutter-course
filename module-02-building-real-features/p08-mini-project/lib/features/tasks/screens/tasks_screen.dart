// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/features/tasks/screens/tasks_screen.dart
//
// Main tasks screen — shows task list with filters.
// Covers: AsyncValue.when(), filter chips, pull-to-refresh,
//         dismissible swipe-to-delete, empty state.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/tasks_provider.dart';
import '../models/task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final stats = ref.watch(taskStatsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.displayName ?? 'Student'}! 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              '${stats['active']} tasks remaining',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(tasksProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // -----------------------------------------------
          // PROGRESS BAR — shows completion percentage
          // -----------------------------------------------
          if ((stats['total'] ?? 0) > 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${stats['completed']}/${stats['total']} done',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stats['total']! > 0
                          ? stats['completed']! / stats['total']!
                          : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(AppTheme.success),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // -----------------------------------------------
          // FILTER CHIPS
          // -----------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: TaskFilter.values
                  .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(switch (filter) {
                            TaskFilter.all => 'All (${stats['total']})',
                            TaskFilter.active => 'Active (${stats['active']})',
                            TaskFilter.completed => 'Done (${stats['completed']})',
                          }),
                          selected: currentFilter == filter,
                          onSelected: (_) => ref
                              .read(taskFilterProvider.notifier)
                              .state = filter,
                          selectedColor:
                              AppTheme.primary.withOpacity(0.15),
                          checkmarkColor: AppTheme.primary,
                        ),
                      ))
                  .toList(),
            ),
          ),

          // -----------------------------------------------
          // TASK LIST — handles all async states
          // -----------------------------------------------
          Expanded(
            child: filteredTasks.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(tasksProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),

              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentFilter == TaskFilter.completed
                              ? Icons.celebration_outlined
                              : Icons.task_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentFilter == TaskFilter.completed
                              ? 'No completed tasks yet'
                              : currentFilter == TaskFilter.active
                                  ? 'All tasks done! 🎉'
                                  : 'No tasks yet',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (currentFilter != TaskFilter.completed)
                          const Text(
                            'Tap the + button to add your first task',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(tasksProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _TaskCard(task: tasks[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}

// ============================================================
// TASK CARD — individual task item
// Dismissible = swipe left to delete
// ============================================================
class _TaskCard extends ConsumerWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = switch (task.priority) {
      TaskPriority.high => AppTheme.priorityHigh,
      TaskPriority.medium => AppTheme.priorityMedium,
      TaskPriority.low => AppTheme.priorityLow,
    };

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Task?'),
            content: Text('Delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(tasksProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted: ${task.title}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(tasksProvider.notifier).addTask(task);
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/tasks/${task.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => ref
                      .read(tasksProvider.notifier)
                      .toggleComplete(task.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppTheme.success
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppTheme.success
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            task.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (task.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: task.dueDate!.isBefore(DateTime.now())
                                    ? AppTheme.danger
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d').format(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: task.dueDate!.isBefore(DateTime.now())
                                      ? AppTheme.danger
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Priority dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: priorityColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
