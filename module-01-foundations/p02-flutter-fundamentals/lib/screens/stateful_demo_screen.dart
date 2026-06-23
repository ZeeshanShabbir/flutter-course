// ============================================================
// P02 — Flutter Fundamentals
// File: lib/screens/stateful_demo_screen.dart
//
// TOPIC: StatefulWidget — setState, counter, toggle
//
// Slide reference: "StatelessWidget vs. StatefulWidget"
// Key quote: "StatefulWidget: pick it when UI needs to change
//              in response to user interaction."
//
// HOW STATEFUL WORKS:
// 1. Flutter calls build() → widget renders
// 2. User taps a button → you call setState()
// 3. Flutter calls build() AGAIN → UI updates with new state
//
// RULE: Keep StatefulWidgets as SMALL as possible.
// Only lift state up to the LOWEST common ancestor.
// (This is why we'll move to Riverpod in P03.)
// ============================================================

import 'package:flutter/material.dart';

class StatefulDemoScreen extends StatefulWidget {
  const StatefulDemoScreen({super.key});

  // createState() links the widget to its State object
  @override
  State<StatefulDemoScreen> createState() => _StatefulDemoScreenState();
}

// The state class — private, prefixed with underscore by convention
class _StatefulDemoScreenState extends State<StatefulDemoScreen> {
  // -------------------------------------------------------
  // STATE VARIABLES — every variable that affects the UI
  // -------------------------------------------------------
  int _counter = 0;
  bool _isFavourited = false;
  String _selectedMood = 'Happy';
  double _sliderValue = 0.5;
  int _tabIndex = 0;

  // -------------------------------------------------------
  // LIFECYCLE (brief intro — full coverage in P03)
  // -------------------------------------------------------
  @override
  void initState() {
    super.initState(); // always call super first
    // Runs ONCE when widget is first inserted into the tree.
    // Good for: loading initial data, starting animations.
    debugPrint('initState called');
  }

  @override
  void dispose() {
    // Runs when widget is REMOVED from the tree.
    // Good for: cancelling timers, closing streams, disposing controllers.
    debugPrint('dispose called');
    super.dispose(); // always call super last
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StatefulWidget')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---------------------------------------------------
          // 1. COUNTER — simplest stateful example
          // ---------------------------------------------------
          _DemoCard(
            title: '1. Counter',
            child: Column(
              children: [
                Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0397D6),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrement
                    IconButton.filled(
                      onPressed: () => setState(() => _counter--),
                      icon: const Icon(Icons.remove),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[100],
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Reset
                    TextButton(
                      onPressed: () => setState(() => _counter = 0),
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 16),
                    // Increment
                    IconButton.filled(
                      onPressed: () => setState(() => _counter++),
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0397D6).withOpacity(0.1),
                        foregroundColor: const Color(0xFF0397D6),
                      ),
                    ),
                  ],
                ),
                // Comment explains the pattern
                const Text(
                  'setState() tells Flutter to call build() again',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------------------------------------------------
          // 2. TOGGLE — boolean state
          // ---------------------------------------------------
          _DemoCard(
            title: '2. Toggle (bool state)',
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isFavourited
                        ? Colors.red[100]
                        : Colors.grey[200],
                  ),
                  child: Icon(
                    _isFavourited ? Icons.favorite : Icons.favorite_outline,
                    color: _isFavourited ? Colors.red : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isFavourited ? 'Favourited! ❤️' : 'Not favourited',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        // setState takes a callback. Flutter calls it, then rebuilds.
                        setState(() {
                          _isFavourited = !_isFavourited;
                        });
                      },
                      child: Text(_isFavourited ? 'Remove' : 'Add to favourites'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------------------------------------------------
          // 3. STRING STATE — radio buttons
          // ---------------------------------------------------
          _DemoCard(
            title: '3. String State (selection)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ['Happy', 'Focused', 'Tired', 'Excited']
                  .map((mood) => RadioListTile<String>(
                        title: Text(mood),
                        value: mood,
                        groupValue: _selectedMood,
                        onChanged: (value) {
                          if (value != null) {
                            // Never modify state directly — always use setState
                            setState(() => _selectedMood = value);
                          }
                        },
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ---------------------------------------------------
          // 4. DOUBLE STATE — slider
          // ---------------------------------------------------
          _DemoCard(
            title: '4. Double State (slider)',
            child: Column(
              children: [
                Text(
                  '${(_sliderValue * 100).round()}%',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _sliderValue,
                  onChanged: (value) => setState(() => _sliderValue = value),
                  divisions: 10,
                  label: '${(_sliderValue * 100).round()}%',
                ),
                Text(
                  'Progress: ${_sliderValue < 0.5 ? 'Just starting' : _sliderValue < 0.8 ? 'Getting there' : 'Almost done!'}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Reusable card wrapper for this screen
// ============================================================
class _DemoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DemoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0397D6),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
