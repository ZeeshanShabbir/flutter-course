// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/shared/widgets/app_shell.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _destinations = [
    (path: '/', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Tasks'),
    (path: '/profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _destinations.indexWhere(
      (d) => location == d.path,
    ).clamp(0, _destinations.length - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_destinations[index].path);
        },
        destinations: _destinations.map((d) => NavigationDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.activeIcon, color: AppTheme.primary),
          label: d.label,
        )).toList(),
      ),
    );
  }
}
