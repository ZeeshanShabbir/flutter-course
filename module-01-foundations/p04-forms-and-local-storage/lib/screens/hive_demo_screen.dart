// ============================================================
// P04 — Forms & Local Storage
// File: lib/screens/prefs_demo_screen.dart + hive_demo_screen.dart
//
// SharedPreferences — simple key-value data that survives restarts
// Hive — fast NoSQL box-based storage for structured data
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================================
// SHARED PREFERENCES DEMO
// Use for: user preferences, settings, dark mode toggle,
//          first-launch flag, last seen screen, etc.
// NOT for: large data, sensitive data (use flutter_secure_storage)
// ============================================================
class PrefsDemoScreen extends StatefulWidget {
  const PrefsDemoScreen({super.key});

  @override
  State<PrefsDemoScreen> createState() => _PrefsDemoScreenState();
}

class _PrefsDemoScreenState extends State<PrefsDemoScreen> {
  // Prefs keys — define as constants to avoid typos
  static const _kDarkMode = 'dark_mode';
  static const _kFontSize = 'font_size';
  static const _kUserName = 'user_name';
  static const _kLaunchCount = 'launch_count';

  bool _darkMode = false;
  double _fontSize = 16.0;
  String _userName = '';
  int _launchCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPrefs(); // Load saved prefs when screen opens
  }

  Future<void> _loadPrefs() async {
    // SharedPreferences.getInstance() is async — always await
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _darkMode = prefs.getBool(_kDarkMode) ?? false;
      _fontSize = prefs.getDouble(_kFontSize) ?? 16.0;
      _userName = prefs.getString(_kUserName) ?? '';
      _launchCount = prefs.getInt(_kLaunchCount) ?? 0;
    });

    // Increment and save launch count
    await prefs.setInt(_kLaunchCount, _launchCount + 1);
    setState(() => _launchCount = _launchCount + 1);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // wipes everything
    _loadPrefs(); // reload defaults
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all prefs',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          Card(
            color: const Color(0xFF0397D6).withOpacity(0.08),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '💡 SharedPreferences stores data as key-value pairs '
                'in the device\'s local storage. Data persists across '
                'app restarts. Use for lightweight settings only.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Launch count
          ListTile(
            leading: const Icon(Icons.launch_outlined),
            title: const Text('App Launch Count'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0397D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_launchCount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0397D6),
                ),
              ),
            ),
            subtitle: const Text('Persisted as int'),
          ),

          const Divider(),

          // Dark mode toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Persisted as bool'),
            secondary: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              _saveBool(_kDarkMode, value);
            },
          ),

          const Divider(),

          // Font size slider
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: Text('${_fontSize.round()}pt — persisted as double'),
          ),
          Slider(
            value: _fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: '${_fontSize.round()}pt',
            onChanged: (value) {
              setState(() => _fontSize = value);
              _saveDouble(_kFontSize, value);
            },
          ),

          const Divider(),

          // Username
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Display Name'),
            subtitle: Text(
              _userName.isEmpty ? 'Not set' : _userName,
              style: TextStyle(
                color: _userName.isEmpty ? Colors.grey : null,
              ),
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () async {
              final ctrl = TextEditingController(text: _userName);
              final result = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Set Display Name'),
                  content: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, ctrl.text),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (result != null) {
                setState(() => _userName = result);
                await _saveString(_kUserName, result);
              }
            },
          ),

          // Preview text with font size
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _userName.isEmpty
                    ? 'Welcome to D4WEE!'
                    : 'Welcome, $_userName!',
                style: TextStyle(fontSize: _fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HIVE DEMO SCREEN
// Hive is faster than SharedPreferences for structured data.
// Think of a Box like a Map<String, dynamic> stored on disk.
// ============================================================
class HiveDemoScreen extends StatefulWidget {
  const HiveDemoScreen({super.key});

  @override
  State<HiveDemoScreen> createState() => _HiveDemoScreenState();
}

class _HiveDemoScreenState extends State<HiveDemoScreen> {
  // Get reference to the 'notes' box (opened in main.dart)
  late final Box _notesBox = Hive.box('notes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive NoSQL Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all notes',
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Clear All Notes?'),
                content: const Text('This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      _notesBox.clear();
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info card
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              color: const Color(0xFF6CB33E).withOpacity(0.08),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '💡 Hive stores data in "boxes" — like named databases. '
                  'Data is written to disk asynchronously and survives '
                  'app restarts. Supports any JSON-serializable type.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),

          // ValueListenableBuilder — rebuilds when Hive box changes
          // This is the reactive way to use Hive (like StreamBuilder)
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _notesBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_add_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No notes yet — tap + to add one'),
                      ],
                    ),
                  );
                }

                // box.keys returns all stored keys
                final keys = box.keys.toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    final note = box.get(key) as Map?;
                    if (note == null) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          note['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          note['content'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            box.delete(key); // Hive deletes by key
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                // Store as a Map with a timestamp key
                // In production you'd use a proper model with a Hive TypeAdapter
                _notesBox.put(
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  {
                    'title': titleCtrl.text,
                    'content': contentCtrl.text,
                    'createdAt': DateTime.now().toIso8601String(),
                  },
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
