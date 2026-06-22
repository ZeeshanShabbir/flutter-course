// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/features/tasks/repositories/task_repository.dart
//
// Repository layer — sits between the data source and the UI.
// Slide reference: P13 "Separation of Concerns"
// Key quote: "1. Data source — talks to Firestore/API directly
//             2. Repository — caching, error handling
//             3. Notifier — UI state"
//
// WHY A REPOSITORY?
// - Swappable: change from JSONPlaceholder to Firestore
//   without touching any UI code
// - Testable: mock the repository in widget tests
// - Single source of truth for data operations
// ============================================================

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../../../core/services/dio_service.dart';

// ============================================================
// TASK REPOSITORY — abstract contract
// ============================================================
abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task> getTaskById(String id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleComplete(String id);
}

// ============================================================
// IMPLEMENTATION — uses JSONPlaceholder + Hive cache
// In P06, swap this with FirestoreTaskRepository
// ============================================================
class ApiTaskRepository implements TaskRepository {
  final Dio _dio;
  final Box _cache;
  static const _cacheKey = 'cached_tasks';

  ApiTaskRepository(this._dio, this._cache);

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      // Try network first
      final response = await _dio.get('/todos', queryParameters: {'_limit': 20});
      final List data = response.data;

      // Map API response to our Task model
      final tasks = data.map((json) {
        return Task(
          id: json['id'].toString(),
          title: json['title'] as String,
          isCompleted: json['completed'] as bool,
          createdAt: DateTime.now().subtract(Duration(days: data.indexOf(json))),
          userId: json['userId'].toString(),
        );
      }).toList();

      // Cache to Hive for offline use
      _cache.put(
        _cacheKey,
        tasks.map((t) => t.toJson()).toList(),
      );

      return tasks;
    } on DioException catch (e) {
      // Network failed — try cache
      final cached = _cache.get(_cacheKey);
      if (cached != null) {
        final List cachedList = cached;
        return cachedList.map((json) => Task.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      // No cache either — rethrow with friendly message
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<Task> getTaskById(String id) async {
    try {
      final response = await _dio.get('/todos/$id');
      final json = response.data;
      return Task(
        id: json['id'].toString(),
        title: json['title'] as String,
        isCompleted: json['completed'] as bool,
        createdAt: DateTime.now(),
        userId: json['userId'].toString(),
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post(
        '/todos',
        data: {
          'title': task.title,
          'completed': task.isCompleted,
          'userId': 1,
        },
      );
      // JSONPlaceholder returns fake ID 201 — use our local UUID instead
      return task.copyWith(id: const Uuid().v4());
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      await _dio.put(
        '/todos/${task.id}',
        data: {'title': task.title, 'completed': task.isCompleted},
      );
      return task;
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('/todos/$id');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> toggleComplete(String id) async {
    // For JSONPlaceholder this is a PATCH request
    try {
      final current = await getTaskById(id);
      await _dio.patch(
        '/todos/$id',
        data: {'completed': !current.isCompleted},
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }
}

// ============================================================
// PROVIDERS — expose repository to the widget tree
// ============================================================
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final cache = Hive.box('tasks_cache');
  return ApiTaskRepository(dio, cache);
});

// ============================================================
// FIRESTORE REPOSITORY (Template — activate in P06)
// ============================================================
// class FirestoreTaskRepository implements TaskRepository {
//   final FirebaseFirestore _firestore;
//   final String userId;
//
//   FirestoreTaskRepository(this._firestore, this.userId);
//
//   // Collection reference for this user's tasks
//   CollectionReference get _tasks =>
//       _firestore.collection('users').doc(userId).collection('tasks');
//
//   @override
//   Future<List<Task>> getAllTasks() async {
//     final snapshot = await _tasks
//         .orderBy('createdAt', descending: true)
//         .get();
//     return snapshot.docs.map((doc) {
//       return Task.fromJson({...doc.data() as Map, 'id': doc.id});
//     }).toList();
//   }
//
//   @override
//   Future<Task> createTask(Task task) async {
//     final doc = await _tasks.add(task.toJson());
//     return task.copyWith(id: doc.id);
//   }
//
//   // ... implement others similarly
// }
