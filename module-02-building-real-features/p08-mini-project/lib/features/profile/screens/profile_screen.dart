// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/features/profile/screens/profile_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/tasks/providers/tasks_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final stats = ref.watch(taskStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.danger),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(authProvider.notifier).signOut();
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primary.withOpacity(0.15),
              child: Text(
                user?.initials ?? 'U',
                style: const TextStyle(
                  fontSize: 32,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.displayName ?? 'Student',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ),

          const SizedBox(height: 32),

          // Stats cards
          Row(
            children: [
              _StatCard(
                label: 'Total',
                value: stats['total'].toString(),
                icon: Icons.task_outlined,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Completed',
                value: stats['completed'].toString(),
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Active',
                value: stats['active'].toString(),
                icon: Icons.pending_outlined,
                color: AppTheme.warning,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Completion rate
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Completion Rate',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: stats['total']! > 0
                                ? stats['completed']! / stats['total']!
                                : 0,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation(
                                AppTheme.success),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        stats['total']! > 0
                            ? '${((stats['completed']! / stats['total']!) * 100).round()}%'
                            : '0%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Course info
          Card(
            child: ListTile(
              leading: const Icon(Icons.school_outlined, color: AppTheme.primary),
              title: const Text('Mobile Development with Flutter'),
              subtitle: const Text('D4WEE · Code for Pakistan · 2026'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
