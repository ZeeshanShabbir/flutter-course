// ============================================================
// P13 — Capstone
// File: lib/features/tasks/models/task.dart
// ============================================================

import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { todo, inProgress, done, cancelled }
enum TaskCategory { personal, work, study, health, finance, other }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
    TaskPriority.low => 'Low', TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High', TaskPriority.urgent => 'Urgent',
  };
}

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
    TaskStatus.todo => 'To Do', TaskStatus.inProgress => 'In Progress',
    TaskStatus.done => 'Done', TaskStatus.cancelled => 'Cancelled',
  };
  bool get isComplete => this == TaskStatus.done;
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final String? projectId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? userId;
  final List<String> tags;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.category = TaskCategory.personal,
    this.projectId,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.userId,
    this.tags = const [],
  });

  factory Task.create({required String title, String? userId}) => Task(
    id: const Uuid().v4(),
    title: title,
    createdAt: DateTime.now(),
    userId: userId,
  );

  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !status.isComplete;
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year && dueDate!.month == now.month && dueDate!.day == now.day;
  }

  Task copyWith({String? title, String? description, TaskPriority? priority,
    TaskStatus? status, TaskCategory? category, DateTime? dueDate, List<String>? tags}) {
    return Task(id: id, title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority, status: status ?? this.status,
      category: category ?? this.category, projectId: projectId,
      createdAt: createdAt, dueDate: dueDate ?? this.dueDate,
      completedAt: status?.isComplete == true ? DateTime.now() : completedAt,
      userId: userId, tags: tags ?? this.tags);
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'priority': priority.name, 'status': status.name,
    'category': category.name, 'projectId': projectId,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'userId': userId, 'tags': tags,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    priority: TaskPriority.values.firstWhere((p) => p.name == json['priority'],
      orElse: () => TaskPriority.medium),
    status: TaskStatus.values.firstWhere((s) => s.name == json['status'],
      orElse: () => TaskStatus.todo),
    category: TaskCategory.values.firstWhere((c) => c.name == json['category'],
      orElse: () => TaskCategory.personal),
    projectId: json['projectId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    userId: json['userId'] as String?,
    tags: (json['tags'] as List?)?.cast<String>() ?? [],
  );

  @override bool operator ==(Object other) => other is Task && other.id == id;
  @override int get hashCode => id.hashCode;
  @override String toString() => 'Task(id: $id, title: $title, status: ${status.name})';
}
