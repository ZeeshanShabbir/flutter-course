// ============================================================
// P13 — Capstone
// File: lib/core/routing/app_router.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/tasks/screens/add_edit_task_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';

class Routes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const addTask = '/tasks/new';
  static const taskDetail = '/tasks/:id';
  static const editTask = '/tasks/:id/edit';
  static const settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authAsync.valueOrNull != null;
      final isPublic = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register;

      if (!isLoggedIn && !isPublic) return Routes.login;
      if (isLoggedIn && isPublic) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, __) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'tasks/new',
                pageBuilder: (_, __) => const MaterialPage(
                  fullscreenDialog: true,
                  child: AddEditTaskScreen(),
                ),
              ),
              GoRoute(
                path: 'tasks/:id',
                builder: (context, state) => TaskDetailScreen(
                  taskId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => MaterialPage(
                      fullscreenDialog: true,
                      child: AddEditTaskScreen(
                        taskId: state.pathParameters['id'],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text('Route not found: ${state.matchedLocation}'),
            TextButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
