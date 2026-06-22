// ============================================================
// P13 — Capstone
// File: lib/features/tasks/screens/tasks_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routing/app_router.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final stats = ref.watch(taskStatsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Sticky app bar ────────────────────────────────
          SliverAppBar(
            floating: true,
            pinned: false,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF8183F4)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.displayName ?? 'Student'}! 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats['active']} active · ${stats['overdue']} overdue · ${stats['dueToday']} due today',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => ref.read(tasksProvider.notifier).refresh(),
              ),
            ],
          ),

          // ── Filter chips ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in TaskFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(switch (f) {
                            TaskFilter.all => 'All (${stats['total']})',
                            TaskFilter.active => 'Active (${stats['active']})',
                            TaskFilter.completed => 'Done (${stats['completed']})',
                            TaskFilter.overdue => 'Overdue (${stats['overdue']})',
                          }),
                          selected: filter == f,
                          onSelected: (_) =>
                            ref.read(taskFilterProvider.notifier).state = f,
                          selectedColor: AppTheme.primary.withOpacity(0.15),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Task list ─────────────────────────────────────
          filtered.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => ref.read(tasksProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ]))),
            data: (tasks) => tasks.isEmpty
              ? SliverFillRemaining(
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.task_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(filter == TaskFilter.overdue ? 'No overdue tasks! 🎉'
                      : filter == TaskFilter.completed ? 'No completed tasks yet'
                      : 'No tasks — tap + to add one',
                      style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                  ])))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: _CapstoneTaskCard(task: tasks[index]),
                    ),
                    childCount: tasks.length,
                  ),
                ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.addTask),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CapstoneTaskCard extends ConsumerWidget {
  final Task task;
  const _CapstoneTaskCard({required this.task});

  Color _priorityColor() => switch (task.priority) {
    TaskPriority.urgent => const Color(0xFFDC2626),
    TaskPriority.high => AppTheme.danger,
    TaskPriority.medium => AppTheme.warning,
    TaskPriority.low => AppTheme.success,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status.isComplete;
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(tasksProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted: ${task.title}'), behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'Undo',
              onPressed: () => ref.read(tasksProvider.notifier).addTask(task))));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/tasks/${task.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Status toggle
                GestureDetector(
                  onTap: () => ref.read(tasksProvider.notifier).updateStatus(
                    task.id, isDone ? TaskStatus.todo : TaskStatus.done),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppTheme.success : Colors.transparent,
                      border: Border.all(
                        color: isDone ? AppTheme.success : Colors.grey[400]!,
                        width: 2),
                    ),
                    child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(task.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? AppTheme.textMuted : AppTheme.textPrimary),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(task.description, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 11,
                          color: task.isOverdue ? AppTheme.danger : AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(DateFormat('MMM d').format(task.dueDate!),
                          style: TextStyle(fontSize: 11,
                            color: task.isOverdue ? AppTheme.danger : AppTheme.textMuted,
                            fontWeight: task.isOverdue ? FontWeight.w600 : null)),
                        if (task.isOverdue) ...[
                          const SizedBox(width: 4),
                          const Text('OVERDUE', style: TextStyle(fontSize: 10,
                            color: AppTheme.danger, fontWeight: FontWeight.bold)),
                        ],
                      ]),
                    ],
                  ]),
                ),
                // Priority indicator
                Container(
                  width: 4, height: 40,
                  decoration: BoxDecoration(
                    color: _priorityColor(),
                    borderRadius: BorderRadius.circular(2),
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
