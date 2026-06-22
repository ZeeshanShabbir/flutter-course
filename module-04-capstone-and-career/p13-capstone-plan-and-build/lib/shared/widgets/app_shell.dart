// ============================================================
// P13 — Capstone
// File: lib/shared/widgets/app_shell.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    (path: '/', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Tasks'),
    (path: '/settings', icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int selected = _tabs.indexWhere((t) => location == t.path);
    if (selected == -1) selected = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          selectedIcon: Icon(t.activeIcon, color: AppTheme.primary),
          label: t.label,
        )).toList(),
      ),
    );
  }
}
