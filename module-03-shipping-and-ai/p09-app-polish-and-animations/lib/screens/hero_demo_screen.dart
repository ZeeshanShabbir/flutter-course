// ============================================================
// P09 — Hero and Responsive demo screens
// File: lib/screens/hero_demo_screen.dart
// ============================================================

import 'package:flutter/material.dart';

class HeroDemoScreen extends StatelessWidget {
  const HeroDemoScreen({super.key});

  static const List<Map<String, dynamic>> _items = [
    {'id': '1', 'title': 'Dart Basics', 'color': Color(0xFF0397D6), 'icon': '🎯'},
    {'id': '2', 'title': 'Flutter UI', 'color': Color(0xFF544DCF), 'icon': '📱'},
    {'id': '3', 'title': 'Navigation', 'color': Color(0xFF6CB33E), 'icon': '🧭'},
    {'id': '4', 'title': 'Firebase', 'color': Color(0xFFDDB307), 'icon': '🔥'},
    {'id': '5', 'title': 'REST APIs', 'color': Color(0xFFD31145), 'icon': '🌐'},
    {'id': '6', 'title': 'AI Tools', 'color': Color(0xFF897966), 'icon': '🤖'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Animations')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tap any card to see the Hero animation.\n'
              'The tag MUST match on both screens.\n'
              'Use the item\'s ID — never a static string.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HeroDetailScreen(item: item),
                    ),
                  ),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // ── Hero tag matches the detail screen ──
                        Positioned.fill(
                          child: Hero(
                            tag: 'card-bg-${item['id']}',
                            child: Container(
                              decoration: BoxDecoration(
                                color: (item['color'] as Color)
                                    .withOpacity(0.15),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Hero(
                                tag: 'icon-${item['id']}',
                                child: Text(
                                  item['icon'] as String,
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Hero(
                                tag: 'title-${item['id']}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    item['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HeroDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  const HeroDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item['color'] as Color;
    return Scaffold(
      appBar: AppBar(title: Text(item['title'] as String)),
      body: Column(
        children: [
          // Full-width hero banner
          Hero(
            tag: 'card-bg-${item['id']}',
            child: Container(
              width: double.infinity,
              height: 200,
              color: color.withOpacity(0.15),
              child: Center(
                child: Hero(
                  tag: 'icon-${item['id']}',
                  child: Text(
                    item['icon'] as String,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'title-${item['id']}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This is the detail screen for ${item['title']}. '
                  'The icon, background, and title all flew here '
                  'smoothly using Hero widgets with matching tags.',
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
