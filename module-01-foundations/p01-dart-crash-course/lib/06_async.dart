// ============================================================
// P01 — Dart Crash Course
// File: 06_async.dart
//
// TOPIC: Asynchronous Programming — Future, async/await, try/catch
//
// Slide reference: "Asynchronous Programming"
// Key quote: "The async/await pattern — writing async code that
//             reads like sync code."
//
// WHY ASYNC MATTERS:
// Network calls, database reads, and file I/O take time.
// If we blocked the UI thread waiting, the app would freeze.
// Dart's Future system lets work happen in the background.
// ============================================================

import 'dart:math';

void main() async {
  // async on main() lets us use await inside it

  print('=== 1. Future Basics ===');

  // A Future represents a value that will be available "later"
  Future<String> futureMessage = fetchGreeting();

  print('This prints BEFORE the future completes');

  // .then() — callback when Future resolves (old style)
  futureMessage.then((message) {
    print('Received: $message');
  });

  // Dart keeps running — the future runs in the background
  print('This might print before the message!');

  // ----------------------------------------------------------
  // 2. async / await — the MODERN way (use this always)
  // await "pauses" execution HERE until the Future resolves.
  // The rest of the app continues; only THIS function pauses.
  // ----------------------------------------------------------
  print('\n=== 2. async / await ===');

  // await MUST be inside an async function
  String greeting = await fetchGreeting();
  print('Greeted: $greeting');

  // Chain multiple async calls:
  String userId = await loginUser('ali@example.com', 'password123');
  print('Logged in, userId: $userId');

  String profile = await fetchUserProfile(userId);
  print('Profile: $profile');

  // ----------------------------------------------------------
  // 3. ERROR HANDLING with try / catch / finally
  // ALWAYS wrap async calls in try/catch — network can fail!
  // ----------------------------------------------------------
  print('\n=== 3. Error Handling ===');

  try {
    String data = await fetchWithPossibleError(shouldFail: false);
    print('Success: $data');
  } catch (e) {
    print('Caught error: $e');
  }

  try {
    String data = await fetchWithPossibleError(shouldFail: true);
    print('Success: $data');
  } on NetworkException catch (e) {
    // Catch specific exception type first
    print('Network error: ${e.message} (code: ${e.statusCode})');
  } catch (e) {
    // Generic catch — always put LAST
    print('Unknown error: $e');
  } finally {
    // Always runs — use for cleanup (hide loading spinner, etc.)
    print('Cleanup: hiding loading indicator');
  }

  // ----------------------------------------------------------
  // 4. MULTIPLE FUTURES IN PARALLEL
  // Don't await them one-by-one if they're independent!
  // ----------------------------------------------------------
  print('\n=== 4. Parallel Futures ===');

  final stopwatch = Stopwatch()..start();

  // ❌ Sequential (slow) — each waits for the previous:
  // final a = await slowOperation('A', 2);
  // final b = await slowOperation('B', 2);
  // Takes 4 seconds total

  // ✅ Parallel (fast) — all run simultaneously:
  final results = await Future.wait([
    slowOperation('A', 2),
    slowOperation('B', 2),
    slowOperation('C', 1),
  ]);
  // Takes ~2 seconds (the longest one), not 5

  stopwatch.stop();
  print('Results: $results');
  print('Time: ${stopwatch.elapsedMilliseconds}ms (would be ~5000ms sequential)');

  // Future.wait fails if ANY future throws — use with care
  // For independent operations that can fail separately, use
  // separate try/catch blocks.

  // ----------------------------------------------------------
  // 5. Future.timeout — don't wait forever
  // ----------------------------------------------------------
  print('\n=== 5. Timeout ===');

  try {
    // If slowOperation takes longer than 1 second, throw
    String result = await slowOperation('timeout-test', 3)
        .timeout(
          Duration(seconds: 1),
          onTimeout: () => 'Timed out! Using cached data.',
        );
    print('Result: $result');
  } catch (e) {
    print('Timed out: $e');
  }

  // ----------------------------------------------------------
  // 6. async* — async generators (returns a Stream)
  // Seen more in the streams file, but here's the bridge:
  // ----------------------------------------------------------
  print('\n=== 6. Async Generator (brief) ===');

  // asyncGenerator() returns a Stream<int>
  await for (final value in countUp(5)) {
    print('Async generated: $value');
  }
}

// ============================================================
// SIMULATED ASYNC FUNCTIONS
// In a real app these would be: dio.get(), firebase.read(), etc.
// ============================================================

// Simulates a network call that takes 500ms
Future<String> fetchGreeting() async {
  await Future.delayed(Duration(milliseconds: 500));
  return 'Hello from the server!';
}

// Simulates login — returns a user ID
Future<String> loginUser(String email, String password) async {
  await Future.delayed(Duration(seconds: 1));
  // In production: POST /auth/login → returns JWT token
  return 'user_${email.hashCode.abs()}';
}

// Simulates fetching a profile by ID
Future<String> fetchUserProfile(String userId) async {
  await Future.delayed(Duration(milliseconds: 800));
  return 'Ali Raza · Software Engineer · Islamabad';
}

// Simulates an operation that might fail (e.g., no internet)
Future<String> fetchWithPossibleError({required bool shouldFail}) async {
  await Future.delayed(Duration(milliseconds: 300));
  if (shouldFail) {
    throw NetworkException('Connection refused', 503);
  }
  return 'Data loaded successfully';
}

// Simulates a slow background operation
Future<String> slowOperation(String name, int seconds) async {
  await Future.delayed(Duration(seconds: seconds));
  return 'Done($name)';
}

// async* generator — yields values over time (bridges to Streams)
Stream<int> countUp(int to) async* {
  for (int i = 1; i <= to; i++) {
    await Future.delayed(Duration(milliseconds: 100));
    yield i; // yields one value, then pauses until next iteration
  }
}

// ============================================================
// CUSTOM EXCEPTION CLASS
// Always create typed exceptions — easier to catch specifically
// ============================================================
class NetworkException implements Exception {
  final String message;
  final int statusCode;

  NetworkException(this.message, this.statusCode);

  @override
  String toString() => 'NetworkException($statusCode): $message';
}
