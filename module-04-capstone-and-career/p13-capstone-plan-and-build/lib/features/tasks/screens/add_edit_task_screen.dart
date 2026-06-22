// ============================================================
// P13 — Capstone: Add/Edit Task Screen
// File: lib/features/tasks/screens/add_edit_task_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../../../core/theme/app_theme.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final String? taskId; // null = add, non-null = edit
  const AddEditTaskScreen({super.key, this.taskId});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.personal;
  TaskStatus _status = TaskStatus.todo;
  DateTime? _dueDate;
  bool _saving = false;

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tasks = ref.read(tasksProvider).valueOrNull ?? [];
        final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;
        if (task != null) {
          _titleCtrl.text = task.title;
          _descCtrl.text = task.description;
          setState(() {
            _priority = task.priority;
            _category = task.category;
            _status = task.status;
            _dueDate = task.dueDate;
          });
        }
      });
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final tasks = ref.read(tasksProvider).valueOrNull ?? [];
        final existing = tasks.firstWhere((t) => t.id == widget.taskId!);
        await ref.read(tasksProvider.notifier).updateTask(existing.copyWith(
          title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
          priority: _priority, category: _category, dueDate: _dueDate, status: _status));
      } else {
        await ref.read(tasksProvider.notifier).addTask(Task(
          id: const Uuid().v4(), title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(), priority: _priority,
          category: _category, dueDate: _dueDate, createdAt: DateTime.now()));
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [TextButton(onPressed: _saving ? null : _save,
          child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(controller: _titleCtrl, autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Task Title *',
                hintText: 'What needs to be done?', prefixIcon: Icon(Icons.task_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _descCtrl, maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Description (optional)',
                alignLabelWithHint: true, prefixIcon: Padding(padding: EdgeInsets.only(bottom: 44),
                  child: Icon(Icons.notes_outlined)))),
            const SizedBox(height: 24),

            // Priority
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: TaskPriority.values.map((p) {
              final color = switch (p) {
                TaskPriority.urgent => const Color(0xFFDC2626),
                TaskPriority.high => AppTheme.danger,
                TaskPriority.medium => AppTheme.warning,
                TaskPriority.low => AppTheme.success,
              };
              return ChoiceChip(label: Text(p.label), selected: _priority == p,
                onSelected: (_) => setState(() => _priority = p),
                selectedColor: color.withOpacity(0.15),
                labelStyle: TextStyle(color: _priority == p ? color : null));
            }).toList()),
            const SizedBox(height: 16),

            // Category
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: TaskCategory.values.map((c) =>
              ChoiceChip(label: Text(c.name), selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
                selectedColor: AppTheme.primary.withOpacity(0.15))).toList()),
            const SizedBox(height: 16),

            if (_isEditing) ...[
              const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: TaskStatus.values.map((s) =>
                ChoiceChip(label: Text(s.label), selected: _status == s,
                  onSelected: (_) => setState(() => _status = s),
                  selectedColor: AppTheme.primary.withOpacity(0.15))).toList()),
              const SizedBox(height: 16),
            ],

            // Due date
            ListTile(contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.primary),
              title: Text(_dueDate == null ? 'Set due date (optional)'
                : 'Due: ${DateFormat('MMMM d, y').format(_dueDate!)}'),
              trailing: _dueDate != null ? IconButton(icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _dueDate = null)) : null,
              onTap: () async {
                final d = await showDatePicker(context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setState(() => _dueDate = d);
              }),

            const SizedBox(height: 32),
            ElevatedButton(onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(height: 22, width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_isEditing ? 'Save Changes' : 'Add Task')),
          ],
        ),
      ),
    );
  }
}
