// ============================================================
// P01 — Dart Crash Course
// File: 08_exercises.dart
//
// PRACTICE PROBLEMS — Try to solve these BEFORE looking
// at the solution functions below.
//
// Run: dart run lib/08_exercises.dart
// ============================================================

void main() async {
  print('===== P01 EXERCISES =====\n');

  // Exercise 1
  print('--- Exercise 1: Fizz Buzz ---');
  fizzBuzz(20);

  // Exercise 2
  print('\n--- Exercise 2: Palindrome Check ---');
  print(isPalindrome('racecar'));     // true
  print(isPalindrome('flutter'));     // false
  print(isPalindrome('A man a plan a canal Panama'.replaceAll(' ', '').toLowerCase())); // true

  // Exercise 3
  print('\n--- Exercise 3: Student Grade Report ---');
  printGradeReport({
    'Ali': 85,
    'Fatima': 92,
    'Hassan': 47,
    'Zainab': 73,
    'Bilal': 60,
  });

  // Exercise 4
  print('\n--- Exercise 4: Fibonacci ---');
  print(fibonacci(10)); // [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

  // Exercise 5
  print('\n--- Exercise 5: Async Retry ---');
  try {
    final result = await retryAsync(() => mightFail(), maxAttempts: 3);
    print('Final result: $result');
  } catch (e) {
    print('Failed after all retries: $e');
  }

  // Exercise 6
  print('\n--- Exercise 6: Word Count ---');
  wordCount('the quick brown fox jumps over the lazy dog the fox');
}

// ============================================================
// EXERCISE 1: FizzBuzz
// Print numbers 1 to n.
// Multiple of 3 → print "Fizz"
// Multiple of 5 → print "Buzz"
// Multiple of both → print "FizzBuzz"
// ============================================================
void fizzBuzz(int n) {
  for (int i = 1; i <= n; i++) {
    if (i % 15 == 0) {
      print('FizzBuzz');
    } else if (i % 3 == 0) {
      print('Fizz');
    } else if (i % 5 == 0) {
      print('Buzz');
    } else {
      print(i);
    }
  }
}

// ============================================================
// EXERCISE 2: Palindrome
// Return true if the string reads the same forwards and backwards.
// ============================================================
bool isPalindrome(String s) {
  // Strategy: compare string with its reverse
  String reversed = s.split('').reversed.join('');
  return s == reversed;
}

// ============================================================
// EXERCISE 3: Grade Report
// Given a Map<String, int> of student scores:
// - Print each student's name, score, and letter grade
// - Print class average
// - Print top student
// ============================================================
void printGradeReport(Map<String, int> scores) {
  String letterGrade(int score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  // Print each student
  scores.forEach((name, score) {
    final grade = letterGrade(score);
    final status = score >= 60 ? '✓' : '✗';
    print('$status $name: $score (${grade})');
  });

  // Average
  final avg = scores.values.fold(0, (a, b) => a + b) / scores.length;
  print('Class average: ${avg.toStringAsFixed(1)}');

  // Top student
  final top = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
  print('Top student: ${top.key} with ${top.value}');
}

// ============================================================
// EXERCISE 4: Fibonacci Sequence
// Return the first n Fibonacci numbers as a list.
// ============================================================
List<int> fibonacci(int n) {
  if (n <= 0) return [];
  if (n == 1) return [0];

  List<int> seq = [0, 1];
  while (seq.length < n) {
    seq.add(seq[seq.length - 1] + seq[seq.length - 2]);
  }
  return seq;
}

// ============================================================
// EXERCISE 5: Async Retry
// Write a function that retries an async operation up to
// maxAttempts times before giving up.
// ============================================================
int _failCount = 0;

// Simulates an operation that fails twice then succeeds
Future<String> mightFail() async {
  await Future.delayed(Duration(milliseconds: 100));
  _failCount++;
  if (_failCount < 3) {
    throw Exception('Operation failed (attempt $_failCount)');
  }
  return 'Success on attempt $_failCount!';
}

Future<T> retryAsync<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
}) async {
  int attempt = 0;
  while (true) {
    attempt++;
    try {
      return await operation();
    } catch (e) {
      print('Attempt $attempt failed: $e');
      if (attempt >= maxAttempts) rethrow; // give up
      await Future.delayed(Duration(milliseconds: 200 * attempt)); // backoff
    }
  }
}

// ============================================================
// EXERCISE 6: Word Count
// Count how many times each word appears in a string.
// Print results sorted by frequency (most common first).
// ============================================================
void wordCount(String text) {
  final words = text.toLowerCase().split(RegExp(r'\s+'));
  final counts = <String, int>{};

  for (final word in words) {
    counts[word] = (counts[word] ?? 0) + 1;
  }

  // Sort by count descending
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sorted) {
    print('  "${entry.key}": ${entry.value} time(s)');
  }
}
