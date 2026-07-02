// ============================================================
// P02 — Flutter Fundamentals
// File: lib/screens/home_screen.dart
//
// TOPIC: Scaffold, AppBar, Column, navigation
// ============================================================

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) pulls values from ThemeData in main.dart
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // -------------------------------------------------------
      // AppBar — the top bar
      // -------------------------------------------------------
      appBar: AppBar(
        title: const Text('P02 — Flutter Fundamentals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
            tooltip: 'About this demo',
          ),
        ],
      ),

      // -------------------------------------------------------
      // Body — the main content area
      // SafeArea ensures content doesn't go behind notches/status bars
      // -------------------------------------------------------
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header text
              Text(
                'D4WEE Learning App',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 4), Text(
                'Mobile Development with Flutter · 2026',
              
               style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // -----------------------------------------------
              // Navigation cards — tap to go to each demo screen
              // -----------------------------------------------
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _DemoCard(
                      icon: Icons.widgets_outlined,
                      title: 'Basic Widgets',
                      subtitle: 'Text, Image, Container, Icon',
                      color: colorScheme.primary,
                      onTap: () => Navigator.pushNamed(context, '/widgets'),
                    ),
                    _DemoCard(
                      icon: Icons.sync_outlined,
                      title: 'Stateful Widget',
                      subtitle: 'setState, counter, toggle',
                      color: const Color(0xFF544DCF),
                      onTap: () => Navigator.pushNamed(context, '/stateful'),
                    ),
                    _DemoCard(
                      icon: Icons.list_alt_outlined,
                      title: 'Lists & Grids',
                      subtitle: 'ListView, GridView, builders',
                      color: const Color(0xFF6CB33E),
                      onTap: () => Navigator.pushNamed(context, '/list'),
                    ),
                    _DemoCard(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle: 'Colors, typography, dark mode',
                      color: const Color(0xFFDDB307),
                      onTap: () => _showThemeInfo(context, theme),
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // -------------------------------------------------------
      // FloatingActionButton — primary action
      // -------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Flutter! 👋'),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        icon: const Icon(Icons.waving_hand),
        label: const Text('Say Hello'),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'D4WEE Flutter Course',
      applicationVersion: '1.0.0',
      children: const [
        Text('Module 01 · Part 02 · Flutter Fundamentals\n\n'
            'Instructor: Muhammad Zeeshan Shabbir\n'
            'Code for Pakistan · 2026'),
      ],
    );
  }

  void _showThemeInfo(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Theme System'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ColorRow('Primary', theme.colorScheme.primary),
            _ColorRow('Secondary', theme.colorScheme.secondary),
            _ColorRow('Surface', theme.colorScheme.surface),
            _ColorRow('Background', theme.scaffoldBackgroundColor),
            const SizedBox(height: 12),
            const Text('Colors come from ThemeData in main.dart.\n'
                'Widgets inherit them — never hardcode colors!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// REUSABLE PRIVATE WIDGETS
// Underscore prefix = private to this file
// ============================================================
class _DemoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DemoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon in a coloured circle
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Demo2 extends StatelessWidget {

  final String name;
  final VoidCallback onTap;

  const _Demo2({
      required this.name,
      required this.onTap
    }
  );


  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: onTap,
        child: Text("Please Tap me here!"),
      ),
    );
  }

}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  const _ColorRow(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 24, height: 24, color: color),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
