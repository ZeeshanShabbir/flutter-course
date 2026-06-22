// ============================================================
// P09 — App Polish & Animations
// File: lib/main.dart
//
// Slide reference: "App Polish & Animations" + "Responsive Design"
// Key quotes from slides:
//   "Change a property — Flutter animates the change automatically."
//   "Smooth shared-element transition between two screens."
//   "Branch your layout based on screen width."
//   "Define light and dark themes once, let MaterialApp switch."
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'screens/hero_demo_screen.dart';
import 'screens/responsive_demo_screen.dart';

// ============================================================
// THEME PROVIDER — persists dark mode choice
// Slide: "Remember the user's theme choice across launches"
// ============================================================
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? 0;
    state = ThemeMode.values[index];
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'P09 — Polish & Animations',
      debugShowCheckedModeBanner: false,
      // ThemeMode.system follows OS — exactly what users expect
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0397D6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0397D6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0397D6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1D1D1F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1D1D1F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AnimationsHomeScreen(),
    );
  }
}

class AnimationsHomeScreen extends ConsumerWidget {
  const AnimationsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('P09 — Polish & Animations'),
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(switch (themeMode) {
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
              ThemeMode.system => Icons.brightness_auto,
            }),
            onPressed: () {
              final nextMode = switch (themeMode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              };
              ref.read(themeModeProvider.notifier).setMode(nextMode);
            },
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavCard(
            title: 'Implicit Animations',
            subtitle: 'AnimatedContainer, AnimatedOpacity, AnimatedSwitcher',
            icon: Icons.animation,
            color: const Color(0xFF0397D6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ImplicitAnimationsScreen()),
            ),
          ),
          _NavCard(
            title: 'Hero Animations',
            subtitle: 'Shared element transitions between screens',
            icon: Icons.open_in_full,
            color: const Color(0xFF544DCF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HeroDemoScreen()),
            ),
          ),
          _NavCard(
            title: 'Skeleton Loaders',
            subtitle: 'Shimmer placeholder while data loads',
            icon: Icons.view_stream_outlined,
            color: const Color(0xFF6CB33E),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SkeletonDemoScreen()),
            ),
          ),
          _NavCard(
            title: 'Responsive Design',
            subtitle: 'MediaQuery, LayoutBuilder, breakpoints',
            icon: Icons.devices,
            color: const Color(0xFFDDB307),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ResponsiveDemoScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// IMPLICIT ANIMATIONS SCREEN
// Slide: "Change a property — Flutter animates the change automatically"
// ============================================================
class ImplicitAnimationsScreen extends StatefulWidget {
  const ImplicitAnimationsScreen({super.key});

  @override
  State<ImplicitAnimationsScreen> createState() =>
      _ImplicitAnimationsScreenState();
}

class _ImplicitAnimationsScreenState
    extends State<ImplicitAnimationsScreen> {
  bool _expanded = false;
  bool _visible = true;
  bool _showCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Implicit Animations')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── AnimatedContainer ─────────────────────────────
          const Text('AnimatedContainer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Tween for free — just change a property',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: AnimatedContainer(
                // AnimatedContainer interpolates between old and new values
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _expanded ? 240 : 100,
                height: _expanded ? 240 : 100,
                decoration: BoxDecoration(
                  color: _expanded
                      ? const Color(0xFF0397D6)
                      : const Color(0xFF544DCF),
                  borderRadius: BorderRadius.circular(_expanded ? 24 : 50),
                  boxShadow: [
                    BoxShadow(
                      color: (_expanded
                              ? const Color(0xFF0397D6)
                              : const Color(0xFF544DCF))
                          .withOpacity(0.4),
                      blurRadius: _expanded ? 20 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _expanded ? Icons.compress : Icons.expand,
                    color: Colors.white,
                    size: _expanded ? 48 : 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
              child: Text('Tap to expand',
                  style: TextStyle(color: Colors.grey, fontSize: 12))),

          const SizedBox(height: 32),

          // ── AnimatedOpacity ───────────────────────────────
          const Text('AnimatedOpacity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _visible ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6CB33E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF6CB33E).withOpacity(0.3)),
              ),
              child: const Text('This fades in and out with AnimatedOpacity'),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _visible = !_visible),
            child: Text(_visible ? 'Fade Out' : 'Fade In'),
          ),

          const SizedBox(height: 32),

          // ── AnimatedSwitcher ──────────────────────────────
          const Text('AnimatedSwitcher',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Swap between two widgets smoothly',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: _showCard
                  ? Container(
                      key: const ValueKey('card'),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0397D6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '📱 Card View',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : Container(
                      key: const ValueKey('list'),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF544DCF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '📋 List View',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _showCard = !_showCard),
            child: const Text('Switch View'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SKELETON LOADER SCREEN
// Slide: "Designer-made animations + fast perceived loading"
// Key quote: "Skeletons feel faster because they show the layout shape"
// ============================================================
class SkeletonDemoScreen extends StatefulWidget {
  const SkeletonDemoScreen({super.key});

  @override
  State<SkeletonDemoScreen> createState() => _SkeletonDemoScreenState();
}

class _SkeletonDemoScreenState extends State<SkeletonDemoScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skeleton Loaders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) setState(() => _isLoading = false);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 6,
        itemBuilder: (context, index) {
          if (_isLoading) {
            // SKELETON — shimmer placeholder
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 12,
                              width: 180,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 12,
                              width: 120,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // REAL DATA
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      const Color(0xFF0397D6).withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Color(0xFF0397D6)),
                  ),
                ),
                title: Text('Course Module ${index + 1}'),
                subtitle: const Text('Click to open'),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            );
          }
        },
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
