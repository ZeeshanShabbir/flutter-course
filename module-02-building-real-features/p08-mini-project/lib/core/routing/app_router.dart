// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/core/routing/app_router.dart
//
// GoRouter with auth redirect guard.
// Slide reference: "GoRouter with redirect for auth"
// Key quote: "Auth-state guard at the router level. UI never
//             has to check 'is the user logged in'."
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/tasks/screens/add_task_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/app_shell.dart';

// Route path constants — prevents typos across the codebase
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:id';
  static const addTask = '/tasks/new';
  static const profile = '/profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state for reactive redirects
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,

    // --------------------------------------------------------
    // REDIRECT — runs before every navigation
    // --------------------------------------------------------
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isPublicRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isPublicRoute) return AppRoutes.login;
      if (isLoggedIn && isPublicRoute) return AppRoutes.home;
      return null;
    },

    // --------------------------------------------------------
    // ROUTES
    // --------------------------------------------------------
    routes: [
      // Public routes
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Protected routes inside the shell (bottom nav)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'tasks/new',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const AddTaskScreen(),
                  transitionsBuilder: (context, animation, _, child) {
                    // Slide up from bottom — feels native for a "new item" sheet
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                ),
              ),
              GoRoute(
                path: 'tasks/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TaskDetailScreen(taskId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
