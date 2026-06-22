// ============================================================
// P04 — Forms & Local Storage
// File: lib/main.dart
//
// Slide reference: "Forms, Validation & User Input" +
//                  "Local Storage — SharedPrefs, SQLite & Hive"
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/form_demo_screen.dart';
import 'screens/hive_demo_screen.dart';
import 'screens/prefs_demo_screen.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized() must be called before
  // any async setup code that needs Flutter bindings (Hive, Firebase, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive — must happen before opening any box
  await Hive.initFlutter();
  // Register type adapters BEFORE opening boxes that use them
  // In production: Hive.registerAdapter(NoteAdapter());

  // Open boxes we need — like opening a database connection
  await Hive.openBox('preferences');
  await Hive.openBox('notes');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P04 — Forms & Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0397D6),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0397D6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P04 — Forms & Storage')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Covered in this part:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _NavCard(
              icon: Icons.assignment_outlined,
              title: 'Form Validation',
              subtitle: 'TextFormField, GlobalKey, validators, custom input',
              color: const Color(0xFF0397D6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FormDemoScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.tune,
              title: 'SharedPreferences',
              subtitle: 'Key-value storage — user settings, dark mode toggle',
              color: const Color(0xFF544DCF),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrefsDemoScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.storage_outlined,
              title: 'Hive NoSQL',
              subtitle: 'Fast local database — notes, tasks, offline-first',
              color: const Color(0xFF6CB33E),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HiveDemoScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
