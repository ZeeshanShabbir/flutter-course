// ============================================================
// P03 — Navigation & State Management
// File: lib/main.dart
//
// TOPICS: GoRouter, Riverpod, ProviderScope
//
// Slide reference: "Navigation & Routing" + "State Management"
// Key quotes:
//   "GoRouter — the Router API made practical."
//   "Riverpod — reactive, compile-safe state management."
//
// ARCHITECTURE:
// main() → ProviderScope (Riverpod root) → MaterialApp.router
//                                         → GoRouter handles navigation
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/details_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  // ProviderScope is REQUIRED at the root of every Riverpod app.
  // It creates the "container" that holds all provider state.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ============================================================
// GoRouter SETUP
// Define all routes in ONE place — easier to maintain and test.
//
// Key concept: GoRouter uses a "redirect" function to protect routes.
// This is better than checking auth inside every widget.
// ============================================================

// We make the router a Provider so it can read other providers
// (specifically: authProvider to check if user is logged in).
//
// In a simple app you can define it as a global final; in larger
// apps make it a Provider so it rebuilds on auth state changes.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state — router rebuilds when auth changes
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // prints route changes in debug console

    // -----------------------------------------------------------
    // REDIRECT — runs before every navigation event
    // This is where you protect authenticated routes.
    // -----------------------------------------------------------
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final goingToLogin = state.matchedLocation == '/login';

      // Not logged in AND not going to login → send to login
      if (!isLoggedIn && !goingToLogin) return '/login';

      // Logged in AND going to login → send to home
      if (isLoggedIn && goingToLogin) return '/';

      // Otherwise → no redirect needed
      return null;
    },

    // -----------------------------------------------------------
    // ROUTES — the map of URL paths to screens
    // -----------------------------------------------------------
    routes: [
      // Login screen (public)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell route — wraps child routes with a persistent BottomNavBar
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            // Nested route — detail page for a course item
            routes: [
              GoRoute(
                path: 'details/:id', // :id is a path parameter
                builder: (context, state) {
                  // Extract the path parameter
                  final id = state.pathParameters['id']!;
                  return DetailsScreen(itemId: id);
                },
              ),
            ],
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Settings tab
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],

    // -----------------------------------------------------------
    // ERROR PAGE — shown when a route doesn't exist
    // -----------------------------------------------------------
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Route not found: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ============================================================
// APP ROOT — uses MaterialApp.router (not MaterialApp)
// MaterialApp.router hands navigation control to GoRouter
// ============================================================
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // ConsumerWidget = StatelessWidget + access to Riverpod providers
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the router from the provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'D4WEE — Navigation & State',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0397D6),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0397D6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      // routerConfig wires GoRouter to MaterialApp
      routerConfig: router,
    );
  }
}

// ============================================================
// APP SHELL — Persistent bottom navigation bar
// The [child] is swapped by GoRouter when the route changes
// ============================================================
class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    (path: '/', icon: Icons.home_outlined, label: 'Home'),
    (path: '/profile', icon: Icons.person_outline, label: 'Profile'),
    (path: '/settings', icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine which tab is active based on current URL
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _tabs.indexWhere(
      (tab) => location.startsWith(tab.path) && tab.path != '/' ||
                location == tab.path,
    ).clamp(0, _tabs.length - 1);

    return Scaffold(
      body: child, // GoRouter fills this with the current screen
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          // GoRouter's context.go() — navigates without pushing to stack
          context.go(_tabs[index].path);
        },
        destinations: _tabs
            .map((tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}
