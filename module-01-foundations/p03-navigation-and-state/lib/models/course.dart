// ============================================================
// P03 — Navigation & State Management
// File: lib/models/course.dart
//
// A simple immutable data model.
// In P05 we add json_serializable to auto-generate fromJson/toJson.
// In P05+ we use Freezed to add copyWith, equality, etc.
// ============================================================

class Course {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String icon;
  final bool isCompleted;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
    this.isCompleted = false,
  });

  Course copyWith({bool? isCompleted}) => Course(
        id: id,
        title: title,
        description: description,
        duration: duration,
        icon: icon,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  String toString() => 'Course(id: $id, title: $title)';
}
