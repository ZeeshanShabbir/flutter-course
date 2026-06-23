// ============================================================
// P02 — Flutter Fundamentals
// File: lib/screens/widgets_demo_screen.dart
//
// TOPIC: Text, Image, Container, Icon, Row, Column, Stack
//
// Slide reference: "The Widgets You Will Use Every Day"
// Key concept: "Every pixel on screen is drawn by a widget"
// ============================================================

import 'package:flutter/material.dart';

class WidgetsDemoScreen extends StatelessWidget {
  const WidgetsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Widgets')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          // Use SectionHeader to group related demos
          _SectionHeader('Text Widget'),
          _TextDemo(),
          SizedBox(height: 24),

          _SectionHeader('Container Widget'),
          _ContainerDemo(),
          SizedBox(height: 24),

          _SectionHeader('Row & Column'),
          _RowColumnDemo(),
          SizedBox(height: 24),

          _SectionHeader('Stack & Positioned'),
          _StackDemo(),
          SizedBox(height: 24),

          _SectionHeader('Network Image'),
          _ImageDemo(),
          SizedBox(height: 24),

          _SectionHeader('Icons'),
          _IconDemo(),
          SizedBox(height: 24),

          _SectionHeader('Buttons'),
          _ButtonDemo(),
        ],
      ),
    );
  }
}

// ============================================================
// TEXT DEMO
// Text is the most-used widget. Learn all its properties.
// ============================================================
class _TextDemo extends StatelessWidget {
  const _TextDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic text — uses theme's bodyLarge style
        const Text('Basic text — inherits theme style'),

        const SizedBox(height: 8),

        // Custom style — override only what you need
        const Text(
          'Bold & coloured text',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0397D6),
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 8),

        // overflow — how to handle text that's too long
        const Text(
          'This is a very long text that will eventually overflow '
          'the available space and be cut off with an ellipsis at the end.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis, // ... at the end
        ),

        const SizedBox(height: 8),

        // RichText — multiple styles in one paragraph
        RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(text: 'Flutter '),
              TextSpan(
                text: 'is ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0397D6),
                ),
              ),
              TextSpan(text: 'awesome! '),
              TextSpan(
                text: '🚀',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CONTAINER DEMO
// Container = the most versatile layout widget.
// padding, margin, color, decoration, width, height, alignment
// ============================================================
class _ContainerDemo extends StatelessWidget {
  const _ContainerDemo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Simple container
        Container(
          width: 80,
          height: 80,
          color: const Color(0xFF0397D6),
          child: const Center(
            child: Text('Simple', style: TextStyle(color: Colors.white)),
          ),
        ),

        const SizedBox(width: 12),

        // Container with decoration (rounded, gradient-like border)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF544DCF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF544DCF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('Decorated', style: TextStyle(color: Colors.white)),
          ),
        ),

        const SizedBox(width: 12),

        // Container with padding & margin
        Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF6CB33E), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Padded\n& Bordered',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ROW & COLUMN DEMO
// Row = horizontal, Column = vertical
// mainAxisAlignment = along the main axis
// crossAxisAlignment = perpendicular to the main axis
// ============================================================
class _RowColumnDemo extends StatelessWidget {
  const _RowColumnDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row with different main-axis alignments
        const Text('Row — spaceEvenly:'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (i) => CircleAvatar(
              backgroundColor: [
                const Color(0xFF0397D6),
                const Color(0xFF544DCF),
                const Color(0xFF6CB33E),
                const Color(0xFFDDB307),
              ][i],
              child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Expanded — fills remaining space in a Row/Column
        const Text('Row with Expanded:'),
        const SizedBox(height: 8),
        Row(
          children: [
            // Expanded takes all available horizontal space
            Expanded(
              flex: 2, // twice as wide as the next Expanded
              child: Container(
                height: 40,
                color: const Color(0xFF0397D6).withOpacity(0.2),
                child: const Center(child: Text('flex: 2')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
                color: const Color(0xFF544DCF).withOpacity(0.2),
                child: const Center(child: Text('flex: 1')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// STACK DEMO
// Stack overlaps children — like CSS position: absolute
// Use Positioned to control where each child sits
// ============================================================
class _StackDemo extends StatelessWidget {
  const _StackDemo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          // Background layer — fills the Stack
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0397D6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Bottom-right circle (decorative)
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0397D6).withOpacity(0.15),
              ),
            ),
          ),

          // Main content — positioned in the centre
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.layers_outlined, size: 32, color: Color(0xFF0397D6)),
                SizedBox(height: 8),
                Text('Stack overlaps widgets', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Background · Content · Badge', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),

          // Badge — top right corner
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD31145),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// IMAGE DEMO
// ============================================================
class _ImageDemo extends StatelessWidget {
  const _ImageDemo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Network image with error fallback
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'https://picsum.photos/80/80?random=1',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            // Always provide an error builder — network can fail
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
            // Show a loading placeholder
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child; // loaded
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        // Circular image (avatar style)
        ClipOval(
          child: Image.network(
            'https://picsum.photos/80/80?random=2',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Asset image note
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_outlined, color: Colors.grey),
              Text('Add images\nto assets/',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ICON DEMO
// ============================================================
class _IconDemo extends StatelessWidget {
  const _IconDemo();

  @override
  Widget build(BuildContext context) {
    final icons = [
      (Icons.home_outlined, 'Home', const Color(0xFF0397D6)),
      (Icons.person_outline, 'Profile', const Color(0xFF544DCF)),
      (Icons.notifications_outlined, 'Alerts', const Color(0xFFDDB307)),
      (Icons.settings_outlined, 'Settings', const Color(0xFF6CB33E)),
      (Icons.favorite_outline, 'Like', const Color(0xFFD31145)),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: icons.map((entry) {
        final (icon, label, color) = entry;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        );
      }).toList(),
    );
  }
}

// ============================================================
// BUTTON DEMO
// ============================================================
class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text('ElevatedButton'),
        ),
        OutlinedButton(
          onPressed: () {},
          child: const Text('OutlinedButton'),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('TextButton'),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.star_outline),
          tooltip: 'Favourite',
        ),
        FilledButton(
          onPressed: () {},
          child: const Text('FilledButton'),
        ),
      ],
    );
  }
}

// ============================================================
// SECTION HEADER — reusable in this file
// ============================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: const Color(0xFF0397D6),
          fontSize: 16,
        ),
      ),
    );
  }
}
