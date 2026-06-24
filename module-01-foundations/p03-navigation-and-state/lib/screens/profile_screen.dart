// ============================================================
// P03 — Navigation & State Management
// File: lib/screens/profile_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final counter = ref.watch(counterProvider);
    final isEven = ref.watch(isCounterEvenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Logout button in AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              // ref.read for event handlers — not ref.watch
              ref.read(authProvider.notifier).logout();
              // GoRouter's redirect will handle navigation automatically
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
              backgroundColor: const Color(0xFF0397D6).withValues(alpha: 0.15),
              child: Text(
                (authState.displayName ?? 'G')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  color: Color(0xFF0397D6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              authState.displayName ?? 'Guest',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'User ID: ${authState.userId ?? 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 32),

          // Riverpod state demo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riverpod State Demo',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$counter',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0397D6),
                              ),
                            ),
                            Text(
                              isEven ? 'Even number' : 'Odd number',
                              style: TextStyle(
                                color: isEven ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              ref.read(counterProvider.notifier).state++;
                            },
                            child: const Text('+1'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              ref.read(counterProvider.notifier).state = 0;
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⬆ This counter is shared with the Home screen AppBar.\n'
                    'Both widgets read from the same counterProvider.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
