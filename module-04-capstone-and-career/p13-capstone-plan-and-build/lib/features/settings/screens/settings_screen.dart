// ============================================================
// P13 — Capstone: Settings Screen
// File: lib/features/settings/screens/settings_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/tasks/providers/tasks_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final stats = ref.watch(taskStatsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: Text(user?.initials ?? 'U',
                  style: const TextStyle(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.displayName ?? 'Student',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user?.email ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ]),
            ]),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _StatPill(value: '${stats['total']}', label: 'Total'),
              const SizedBox(width: 8),
              _StatPill(value: '${stats['completed']}', label: 'Done', color: AppTheme.success),
              const SizedBox(width: 8),
              _StatPill(value: '${stats['active']}', label: 'Active', color: AppTheme.warning),
            ]),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // Theme
          ListTile(
            leading: Icon(switch (themeMode) {
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
              ThemeMode.system => Icons.brightness_auto,
            }),
            title: const Text('Appearance'),
            subtitle: Text(switch (themeMode) {
              ThemeMode.light => 'Light', ThemeMode.dark => 'Dark', ThemeMode.system => 'System default',
            }),
            onTap: () => showModalBottomSheet(context: context, builder: (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(leading: const Icon(Icons.light_mode), title: const Text('Light'),
                  trailing: themeMode == ThemeMode.light ? const Icon(Icons.check, color: AppTheme.primary) : null,
                  onTap: () { ref.read(themeModeProvider.notifier).set(ThemeMode.light); Navigator.pop(ctx); }),
                ListTile(leading: const Icon(Icons.dark_mode), title: const Text('Dark'),
                  trailing: themeMode == ThemeMode.dark ? const Icon(Icons.check, color: AppTheme.primary) : null,
                  onTap: () { ref.read(themeModeProvider.notifier).set(ThemeMode.dark); Navigator.pop(ctx); }),
                ListTile(leading: const Icon(Icons.brightness_auto), title: const Text('System'),
                  trailing: themeMode == ThemeMode.system ? const Icon(Icons.check, color: AppTheme.primary) : null,
                  onTap: () { ref.read(themeModeProvider.notifier).set(ThemeMode.system); Navigator.pop(ctx); }),
              ],
            )),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('D4WEE Capstone · Flutter 3 · Riverpod + GoRouter'),
            onTap: () => showAboutDialog(context: context, applicationName: 'D4WEE Capstone',
              applicationVersion: '1.0.0',
              children: const [Text('Built with Flutter, Firebase, and Riverpod.\nCode for Pakistan · 2026.')]),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.danger),
            title: const Text('Sign Out', style: TextStyle(color: AppTheme.danger)),
            onTap: () => showDialog(context: context, builder: (ctx) => AlertDialog(
              title: const Text('Sign Out?'),
              content: const Text('You will be redirected to the login screen.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
                  onPressed: () { Navigator.pop(ctx); ref.read(authProvider.notifier).signOut(); },
                  child: const Text('Sign Out')),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatPill({required this.value, required this.label, this.color = AppTheme.primary});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ])));
}
