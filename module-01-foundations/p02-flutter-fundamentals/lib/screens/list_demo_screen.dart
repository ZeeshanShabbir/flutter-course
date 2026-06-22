// ============================================================
// P02 — Flutter Fundamentals
// File: lib/screens/list_demo_screen.dart
//
// TOPIC: ListView, GridView, ListTile
//
// Slide reference: "Lists and grids: ListView, GridView"
// Key rule: "ALWAYS use ListView.builder for long lists."
//
// WHY BUILDER VARIANTS?
// ListView([child1, child2, ...]) builds ALL children upfront.
// ListView.builder only builds children visible on screen.
// For 10 items: doesn't matter.
// For 1000 items: HUGE performance difference.
// ============================================================

import 'package:flutter/material.dart';

class ListDemoScreen extends StatelessWidget {
  const ListDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lists & Grids'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'ListView'),
              Tab(text: 'GridView'),
              Tab(text: 'Custom'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListViewDemo(),
            _GridViewDemo(),
            _CustomListDemo(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LISTVIEW TAB
// ============================================================
class _ListViewDemo extends StatelessWidget {
  const _ListViewDemo();

  // Simulated data — in real app this comes from API/Firebase
  static final List<Map<String, dynamic>> _students = List.generate(
    25,
    (i) => {
      'name': ['Ali', 'Fatima', 'Hassan', 'Zainab', 'Bilal',
               'Ayesha', 'Omar', 'Sana', 'Tariq', 'Nadia'][i % 10],
      'score': 60 + (i * 7 % 40),
      'course': ['Flutter', 'Firebase', 'Dart', 'REST APIs', 'UI/UX'][i % 5],
    },
  );

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // ALWAYS use ListView.builder for dynamic lists
      // Only builds items that are visible on screen
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final score = student['score'] as int;

        return ListTile(
          // Leading widget (left side)
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF0397D6).withOpacity(0.15),
            child: Text(
              student['name'][0], // First letter
              style: const TextStyle(
                color: Color(0xFF0397D6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Main content
          title: Text(
            student['name'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(student['course']),

          // Trailing widget (right side)
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _scoreColor(score).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score',
              style: TextStyle(
                color: _scoreColor(score),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tap handler
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${student['name']} — ${student['course']}'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF6CB33E);
    if (score >= 60) return const Color(0xFFDDB307);
    return const Color(0xFFD31145);
  }
}

// ============================================================
// GRIDVIEW TAB
// ============================================================
class _GridViewDemo extends StatelessWidget {
  const _GridViewDemo();

  static const List<Map<String, dynamic>> _topics = [
    {'icon': Icons.code, 'title': 'Dart', 'color': Color(0xFF0397D6)},
    {'icon': Icons.phone_android, 'title': 'Widgets', 'color': Color(0xFF544DCF)},
    {'icon': Icons.route, 'title': 'Navigation', 'color': Color(0xFF6CB33E)},
    {'icon': Icons.storage, 'title': 'State Mgmt', 'color': Color(0xFFDDB307)},
    {'icon': Icons.cloud_outlined, 'title': 'Firebase', 'color': Color(0xFFD31145)},
    {'icon': Icons.api, 'title': 'REST APIs', 'color': Color(0xFF897966)},
    {'icon': Icons.notifications_outlined, 'title': 'Push Notif.', 'color': Color(0xFFF15C22)},
    {'icon': Icons.smart_toy_outlined, 'title': 'AI Tools', 'color': Color(0xFF77278B)},
    {'icon': Icons.bug_report_outlined, 'title': 'Testing', 'color': Color(0xFF0081C6)},
    {'icon': Icons.publish, 'title': 'Publishing', 'color': Color(0xFF544DCF)},
    {'icon': Icons.work_outline, 'title': 'Freelancing', 'color': Color(0xFF6CB33E)},
    {'icon': Icons.emoji_events_outlined, 'title': 'Capstone', 'color': Color(0xFFDDB307)},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      // SliverGridDelegateWithFixedCrossAxisCount = N columns
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,   // 3 columns
        crossAxisSpacing: 8, // horizontal gap
        mainAxisSpacing: 8,  // vertical gap
        childAspectRatio: 0.9, // width / height ratio
      ),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        final color = topic['color'] as Color;

        return Card(
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      topic['icon'] as IconData,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topic['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// CUSTOM LIST TAB — mixed content, section headers
// ============================================================
class _CustomListDemo extends StatelessWidget {
  const _CustomListDemo();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader('This Week'),
        const _TaskTile(title: 'Complete Dart exercises', isDone: true, priority: 'low'),
        const _TaskTile(title: 'Build first Flutter app', isDone: true, priority: 'medium'),
        const _TaskTile(title: 'Study null safety', isDone: false, priority: 'high'),

        _SectionHeader('Next Week'),
        const _TaskTile(title: 'Learn GoRouter', isDone: false, priority: 'high'),
        const _TaskTile(title: 'Riverpod basics', isDone: false, priority: 'medium'),
        const _TaskTile(title: 'Build navigation demo', isDone: false, priority: 'medium'),

        _SectionHeader('Month 2'),
        const _TaskTile(title: 'REST APIs with Dio', isDone: false, priority: 'high'),
        const _TaskTile(title: 'Firebase setup', isDone: false, priority: 'high'),
        const _TaskTile(title: 'Mini-project', isDone: false, priority: 'high'),
      ],
    );
  }

  Widget _SectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0397D6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final String priority; // 'low', 'medium', 'high'

  const _TaskTile({
    required this.title,
    required this.isDone,
    required this.priority,
  });

  Color get _priorityColor => switch (priority) {
        'high' => const Color(0xFFD31145),
        'medium' => const Color(0xFFDDB307),
        _ => const Color(0xFF6CB33E),
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? const Color(0xFF6CB33E) : Colors.grey[400],
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : null,
          ),
        ),
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _priorityColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
