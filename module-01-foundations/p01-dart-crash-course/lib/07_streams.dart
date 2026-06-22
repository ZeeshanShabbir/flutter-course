// ============================================================
// P01 — Dart Crash Course
// File: 07_streams.dart
//
// TOPIC: Streams — StreamController, broadcast, transformations
//
// Slide reference: "Streams & Null Safety"
// Key quote: "Single-subscription vs. broadcast streams and
//             when to pick each."
//
// THINK OF A STREAM LIKE:
// Future = a letter arriving once in the mailbox
// Stream = a live news ticker — values arrive over time
//
// In Flutter, Streams power:
//   • Firestore real-time listeners (StreamBuilder)
//   • Search-as-you-type (debounced streams)
//   • WebSocket messages
//   • State management (BLoC uses streams internally)
// ============================================================

import 'dart:async';

void main() async {
  // ----------------------------------------------------------
  // 1. SIMPLE STREAM — from an iterable or generator
  // ----------------------------------------------------------
  print('=== 1. Simple Stream ===');

  // Stream.fromIterable — emits each item, then closes
  Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5]);

  // Listen with await for (the cleanest syntax for simple cases)
  await for (final n in numbers) {
    print('Got: $n');
  }
  print('Stream closed');

  // ----------------------------------------------------------
  // 2. SINGLE-SUBSCRIPTION vs BROADCAST
  //
  // Single-subscription (default):
  //   - Can only have ONE listener
  //   - Buffers events until listener connects
  //   - Use for: file reads, HTTP response body
  //
  // Broadcast:
  //   - Multiple listeners allowed
  //   - Events are NOT buffered (missed if no listener)
  //   - Use for: UI events, Firestore snapshots
  // ----------------------------------------------------------
  print('\n=== 2. Broadcast Stream ===');

  // Create a broadcast StreamController
  final controller = StreamController<String>.broadcast();

  // Listener 1 — subscribes early
  final sub1 = controller.stream.listen(
    (event) => print('[Listener 1] Got: $event'),
    onError: (e) => print('[Listener 1] Error: $e'),
    onDone: () => print('[Listener 1] Stream closed'),
  );

  // Listener 2 — subscribes a bit later
  final sub2 = controller.stream.listen(
    (event) => print('[Listener 2] Got: $event'),
  );

  // Add events to the stream
  controller.sink.add('Hello');
  controller.sink.add('Flutter');

  await Future.delayed(Duration(milliseconds: 10));

  // Cancel listener 2
  sub2.cancel();
  controller.sink.add('Only listener 1 sees this');

  await Future.delayed(Duration(milliseconds: 10));

  // Close the stream — triggers onDone
  controller.close();

  await Future.delayed(Duration(milliseconds: 10));
  sub1.cancel();

  // ----------------------------------------------------------
  // 3. SINGLE-SUBSCRIPTION StreamController
  // Used when there's exactly one consumer.
  // ----------------------------------------------------------
  print('\n=== 3. Single-Subscription Controller ===');

  await demonstrateSingleSubscription();

  // ----------------------------------------------------------
  // 4. STREAM TRANSFORMATIONS
  // Streams have many of the same operators as List:
  // map, where, take, skip, distinct, etc.
  // ----------------------------------------------------------
  print('\n=== 4. Stream Transformations ===');

  Stream<int> rawScores = Stream.fromIterable([45, 82, 67, 95, 55, 88, 70]);

  // Chain transformations:
  await rawScores
      .where((score) => score >= 60)          // filter: only passing
      .map((score) => score >= 90 ? 'A' : 'B') // transform to grade
      .distinct()                              // remove consecutive duplicates
      .forEach((grade) => print('Grade: $grade'));

  // ----------------------------------------------------------
  // 5. REAL-WORLD PATTERN: debounced search stream
  // The student types "flutter" → we don't hit the API on every
  // keystroke; we wait 500ms after they stop typing.
  // This is simulated below.
  // ----------------------------------------------------------
  print('\n=== 5. Debounced Search (simulated) ===');

  await demonstrateDebounce();

  // ----------------------------------------------------------
  // 6. StreamBuilder — brief preview (full usage in P02/P03)
  // In Flutter widgets you use StreamBuilder to rebuild the UI
  // each time the stream emits a new value.
  // ----------------------------------------------------------
  print('\n=== 6. StreamBuilder Pattern (Dart version) ===');

  // This is the Dart equivalent of what StreamBuilder does:
  Stream<int> counter = tickingCounter(5);
  await for (final tick in counter) {
    // In Flutter: setState() or rebuild widget with new data
    print('UI update: tick=$tick');
  }
}

// ============================================================
// HELPER FUNCTIONS & CLASSES
// ============================================================

Future<void> demonstrateSingleSubscription() async {
  final ctrl = StreamController<int>();

  // Listen BEFORE adding events (required for single-sub)
  ctrl.stream.listen(
    (n) => print('Processing: $n'),
    onDone: () => print('Batch complete'),
  );

  // Simulate batch processing
  for (int i = 1; i <= 5; i++) {
    ctrl.sink.add(i);
    await Future.delayed(Duration(milliseconds: 50));
  }

  await ctrl.close();
}

// Simulates a search stream with debouncing
Future<void> demonstrateDebounce() async {
  final searchController = StreamController<String>();

  // Simulate keystrokes arriving quickly
  void simulateTyping(String text) {
    for (int i = 1; i <= text.length; i++) {
      searchController.sink.add(text.substring(0, i));
    }
  }

  // Set up debounced listener
  // In production: use rxdart's debounceTime() or throttleTime()
  // Here we simulate with a simple timer approach
  Timer? debounce;
  searchController.stream.listen((query) {
    debounce?.cancel();
    debounce = Timer(Duration(milliseconds: 300), () {
      print('🔍 API call for: "$query"');
    });
  });

  // User types "flutter" letter by letter
  simulateTyping('flutter');

  // Wait for debounce to fire
  await Future.delayed(Duration(milliseconds: 500));

  // User types "dart" quickly
  simulateTyping('dart');
  await Future.delayed(Duration(milliseconds: 500));

  debounce?.cancel();
  await searchController.close();
}

// Emits a tick every 200ms, up to [count] times
Stream<int> tickingCounter(int count) async* {
  for (int i = 1; i <= count; i++) {
    await Future.delayed(Duration(milliseconds: 200));
    yield i;
  }
}
