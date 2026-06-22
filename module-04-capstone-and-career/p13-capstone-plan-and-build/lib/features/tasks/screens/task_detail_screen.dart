// ============================================================
// P13 — Capstone: Task Detail, Add/Edit, Settings, Shell
// ============================================================

// ── TASK DETAIL ─────────────────────────────────────────────
// File: lib/features/tasks/screens/task_detail_screen.dart

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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text(e.toString()))),
      data: (tasks) {
        final task = tasks.where((t) => t.id == taskId).firstOrNull;
        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Task not found'),
              TextButton(onPressed: () => context.go('/'), child: const Text('Back')),
            ])),
          );
        }

        final priorityColor = switch (task.priority) {
          TaskPriority.urgent => const Color(0xFFDC2626),
          TaskPriority.high => AppTheme.danger,
          TaskPriority.medium => AppTheme.warning,
          TaskPriority.low => AppTheme.success,
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Detail'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/tasks/$taskId/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                onPressed: () async {
                  final ok = await showDialog<bool>(context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Task?'),
                      content: Text('Delete "${task.title}"? This cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
                          onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                      ],
                    ));
                  if (ok == true && context.mounted) {
                    ref.read(tasksProvider.notifier).deleteTask(taskId);
                    context.pop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Status + priority chips
              Wrap(spacing: 8, children: [
                _Chip(label: task.status.label,
                  color: task.status.isComplete ? AppTheme.success : AppTheme.primary),
                _Chip(label: task.priority.label, color: priorityColor),
                _Chip(label: task.category.name, color: AppTheme.textSecondary),
              ]),
              const SizedBox(height: 16),

              Text(task.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                decoration: task.status.isComplete ? TextDecoration.lineThrough : null)),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(task.description, style: const TextStyle(fontSize: 16,
                  color: AppTheme.textSecondary, height: 1.5)),
              ],

              const Divider(height: 32),

              // Meta
              _MetaRow(icon: Icons.calendar_today_outlined, label: 'Created',
                value: DateFormat('MMMM d, y').format(task.createdAt)),
              if (task.dueDate != null)
                _MetaRow(icon: Icons.event_outlined, label: 'Due',
                  value: DateFormat('MMMM d, y').format(task.dueDate!),
                  valueColor: task.isOverdue ? AppTheme.danger : null),
              if (task.completedAt != null)
                _MetaRow(icon: Icons.check_circle_outline, label: 'Completed',
                  value: DateFormat('MMMM d, y').format(task.completedAt!),
                  valueColor: AppTheme.success),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () => ref.read(tasksProvider.notifier).updateStatus(
                  taskId, task.status.isComplete ? TaskStatus.todo : TaskStatus.done),
                icon: Icon(task.status.isComplete ? Icons.refresh : Icons.check),
                label: Text(task.status.isComplete ? 'Mark as Incomplete' : 'Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.status.isComplete ? Colors.grey : AppTheme.success),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final Color color;
  const _Chip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12)));
}

class _MetaRow extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color? valueColor;
  const _MetaRow({required this.icon, required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 16, color: AppTheme.textMuted),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
      Text(value, style: TextStyle(fontWeight: FontWeight.w500,
        color: valueColor ?? AppTheme.textPrimary, fontSize: 14)),
    ]));
}
