// ============================================================
// P09 — Responsive Design Demo
// File: lib/screens/responsive_demo_screen.dart
//
// Slide reference: "Width-based layout switching"
// Key quote: "Most users in Pakistan are on 360-400 px wide phones.
//             Always test on small screens first."
// Breakpoints: Phone < 600 < Tablet < 1200 < Desktop
// ============================================================

import 'package:flutter/material.dart';

class ResponsiveDemoScreen extends StatelessWidget {
  const ResponsiveDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery.of(context).size.width — the screen's total width
    final width = MediaQuery.of(context).size.width;

    // Current breakpoint label for display
    final breakpoint = width >= 1200
        ? 'Desktop (≥1200px)'
        : width >= 600
            ? 'Tablet (≥600px)'
            : 'Phone (<600px)';

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Design')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Width indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0397D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📐 Screen Width: ${width.toStringAsFixed(0)}px',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('Breakpoint: $breakpoint'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MediaQuery example
            const Text('1. MediaQuery — full screen width',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Switch layout based on total screen width
            if (width >= 600)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _InfoCard(
                      title: 'Left Panel',
                      subtitle: 'Only shown on tablet/desktop',
                      color: const Color(0xFF544DCF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _InfoCard(
                      title: 'Main Content',
                      subtitle: 'Takes 2/3 of the width',
                      color: const Color(0xFF0397D6),
                    ),
                  ),
                ],
              )
            else
              _InfoCard(
                title: 'Single Column',
                subtitle: 'Phone layout — full width',
                color: const Color(0xFF0397D6),
              ),

            const SizedBox(height: 20),

            // LayoutBuilder example
            const Text('2. LayoutBuilder — local constraints',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
              'LayoutBuilder reacts to the PARENT\'s constraints,\n'
              'not the full screen width. Useful for cards and panels.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                // constraints.maxWidth = available width FOR THIS WIDGET
                if (constraints.maxWidth > 500) {
                  return Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          child: _StatCard(value: '${(i + 1) * 10}', label: 'Stat ${i + 1}'),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _StatCard(
                          value: '${(i + 1) * 10}',
                          label: 'Stat ${i + 1}',
                          fullWidth: true,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            // Responsive grid
            const Text('3. Adaptive Grid',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // More columns on wider screens
                crossAxisCount: width >= 1200
                    ? 4
                    : width >= 600
                        ? 3
                        : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: [
                      const Color(0xFF0397D6),
                      const Color(0xFF544DCF),
                      const Color(0xFF6CB33E),
                      const Color(0xFFDDB307),
                    ][index % 4]
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Item ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool fullWidth;

  const _StatCard({
    required this.value,
    required this.label,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0397D6))),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
