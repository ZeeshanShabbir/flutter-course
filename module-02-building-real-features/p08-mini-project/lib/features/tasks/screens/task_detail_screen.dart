// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/features/tasks/screens/task_detail_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../../../core/theme/app_theme.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(e.toString())),
      ),
      data: (tasks) {
        final task = tasks.where((t) => t.id == taskId).firstOrNull;

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Task not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to Tasks'),
                  ),
                ],
              ),
            ),
          );
        }

        final priorityColor = switch (task.priority) {
          TaskPriority.high => AppTheme.priorityHigh,
          TaskPriority.medium => AppTheme.priorityMedium,
          TaskPriority.low => AppTheme.priorityLow,
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Detail'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
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
                          style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.danger),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref
                        .read(tasksProvider.notifier)
                        .deleteTask(task.id);
                    context.pop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Completion badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppTheme.success.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: task.isCompleted
                              ? AppTheme.success
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.isCompleted ? 'Completed' : 'Pending',
                          style: TextStyle(
                            color: task.isCompleted
                                ? AppTheme.success
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${task.priority.label} Priority',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? AppTheme.textMuted
                      : AppTheme.textPrimary,
                ),
              ),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Meta info
              _MetaRow(
                icon: Icons.category_outlined,
                label: 'Category',
                value: task.category.label,
              ),
              _MetaRow(
                icon: Icons.calendar_today_outlined,
                label: 'Created',
                value: DateFormat('MMMM d, y').format(task.createdAt),
              ),
              if (task.dueDate != null)
                _MetaRow(
                  icon: Icons.event_outlined,
                  label: 'Due Date',
                  value: DateFormat('MMMM d, y').format(task.dueDate!),
                  valueColor: task.dueDate!.isBefore(DateTime.now()) &&
                          !task.isCompleted
                      ? AppTheme.danger
                      : null,
                ),

              const SizedBox(height: 32),

              // Toggle complete button
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(tasksProvider.notifier).toggleComplete(task.id),
                icon: Icon(
                  task.isCompleted
                      ? Icons.remove_done_outlined
                      : Icons.done_all,
                ),
                label: Text(
                  task.isCompleted
                      ? 'Mark as Incomplete'
                      : 'Mark as Complete',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      task.isCompleted ? Colors.grey : AppTheme.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
