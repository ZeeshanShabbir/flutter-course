// ============================================================
// P01 — Dart Crash Course
// File: 05_collections.dart
//
// TOPIC: List, Map, Set — Generics and Functional Operations
//
// Slide reference: "Working with Collections"
// ============================================================

void main() {
  // ----------------------------------------------------------
  // 1. LIST — ordered, indexed, allows duplicates
  // Like an array in other languages.
  // ----------------------------------------------------------
  print('=== List ===');

  // Type-safe: List<String> can only hold Strings
  List<String> students = ['Ali', 'Fatima', 'Hassan'];

  // Add / remove
  students.add('Zainab');
  students.addAll(['Bilal', 'Ayesha']);
  students.remove('Hassan');
  print('Students: $students');

  // Access by index
  print('First: ${students[0]}');
  print('Last: ${students.last}');

  // Check existence
  print('Contains Fatima: ${students.contains('Fatima')}');

  // Length
  print('Count: ${students.length}');

  // Iterate
  for (int i = 0; i < students.length; i++) {
    print('  [$i] ${students[i]}');
  }

  // For-in (cleaner)
  for (final student in students) {
    print('  → $student');
  }

  // Spread operator — merge lists
  List<String> seniors = ['Dr. Iqbal', 'Dr. Perveen'];
  List<String> allPeople = [...students, ...seniors];
  print('All: $allPeople');

  // ----------------------------------------------------------
  // 2. LIST FUNCTIONAL OPERATIONS
  // These are used CONSTANTLY in Flutter (building widget lists,
  // filtering API responses, transforming data, etc.)
  // ----------------------------------------------------------
  print('\n=== Functional Operations ===');

  List<int> scores = [85, 92, 67, 95, 78, 45, 88];

  // map() — transform every item, returns Iterable
  List<String> grades = scores
      .map((s) => s >= 90 ? 'A' : s >= 80 ? 'B' : s >= 70 ? 'C' : 'F')
      .toList();
  print('Grades: $grades');

  // where() — filter items (like SQL WHERE)
  List<int> passing = scores.where((s) => s >= 60).toList();
  print('Passing scores: $passing');

  // any() — true if ANY item matches
  bool hasFailure = scores.any((s) => s < 60);
  print('Has failure: $hasFailure');

  // every() — true if ALL items match
  bool allPassing = scores.every((s) => s >= 60);
  print('All passing: $allPassing');

  // fold() — reduce to a single accumulated value
  int total = scores.fold(0, (sum, score) => sum + score);
  double average = total / scores.length;
  print('Average: ${average.toStringAsFixed(1)}');

  // reduce() — simpler fold when start value = first item
  int maxScore = scores.reduce((a, b) => a > b ? a : b);
  print('Highest score: $maxScore');

  // sort() — mutates in-place
  List<int> sorted = List.from(scores)..sort();
  print('Sorted: $sorted');

  // sort with custom comparator (descending)
  List<int> descending = List.from(scores)
    ..sort((a, b) => b.compareTo(a));
  print('Descending: $descending');

  // ----------------------------------------------------------
  // 3. MAP — key-value pairs, unordered
  // The most common data structure for JSON and configs.
  // ----------------------------------------------------------
  print('\n=== Map ===');

  Map<String, int> scoreMap = {
    'Ali': 85,
    'Fatima': 92,
    'Hassan': 67,
  };

  // Access by key
  print('Ali\'s score: ${scoreMap['Ali']}');

  // Safe access (returns null if key missing)
  print('Bilal\'s score: ${scoreMap['Bilal'] ?? 'Not found'}');

  // Add / update
  scoreMap['Zainab'] = 95;
  scoreMap['Ali'] = 90; // update existing key

  // Check key/value existence
  print('Has Fatima: ${scoreMap.containsKey('Fatima')}');
  print('Has score 95: ${scoreMap.containsValue(95)}');

  // Iterate entries
  scoreMap.forEach((name, score) {
    print('  $name: $score');
  });

  // Keys and values as lists
  List<String> names = scoreMap.keys.toList();
  List<int> allScores = scoreMap.values.toList();
  print('Names: $names');
  print('Scores: $allScores');

  // Map.entries — gives you MapEntry objects
  List<String> formatted = scoreMap.entries
      .map((e) => '${e.key}: ${e.value}')
      .toList();
  print('Formatted: $formatted');

  // ----------------------------------------------------------
  // 4. SET — unordered, no duplicates
  // Great for checking membership quickly.
  // ----------------------------------------------------------
  print('\n=== Set ===');

  Set<String> enrolledCourses = {'Flutter', 'Firebase', 'Dart'};
  enrolledCourses.add('Flutter'); // ignored — already exists
  enrolledCourses.add('REST APIs');
  print('Courses: $enrolledCourses');
  print('Count: ${enrolledCourses.length}'); // 4, not 5

  // Membership check — O(1), faster than List.contains
  print('Has Dart: ${enrolledCourses.contains('Dart')}');

  // Set operations
  Set<String> moreCourses = {'REST APIs', 'ML Kit', 'Testing'};
  print('Union: ${enrolledCourses.union(moreCourses)}');
  print('Intersection: ${enrolledCourses.intersection(moreCourses)}');
  print('Difference: ${enrolledCourses.difference(moreCourses)}');

  // Remove duplicates from a list (convert to Set and back)
  List<String> withDuplicates = ['a', 'b', 'a', 'c', 'b'];
  List<String> unique = withDuplicates.toSet().toList();
  print('Unique: $unique');

  // ----------------------------------------------------------
  // 5. GENERICS
  // Type parameters make your code reusable AND type-safe.
  // ----------------------------------------------------------
  print('\n=== Generics ===');

  // Generic class — works with any type
  final intStack = Stack<int>();
  intStack.push(1);
  intStack.push(2);
  intStack.push(3);
  print('Pop: ${intStack.pop()}'); // 3
  print('Peek: ${intStack.peek()}'); // 2

  final stringStack = Stack<String>();
  stringStack.push('first');
  stringStack.push('second');
  print('String pop: ${stringStack.pop()}'); // second

  // Generic function
  List<T> repeat<T>(T value, int times) {
    return List.generate(times, (_) => value);
  }

  print(repeat('Flutter', 3));  // [Flutter, Flutter, Flutter]
  print(repeat(0, 5));          // [0, 0, 0, 0, 0]
}

// ============================================================
// Generic Stack — demonstrates generics with a real data structure
// ============================================================
class Stack<T> {
  // The internal storage — private (leading underscore)
  final List<T> _items = [];

  void push(T item) => _items.add(item);

  T pop() {
    if (_items.isEmpty) throw StateError('Stack is empty');
    return _items.removeLast();
  }

  T peek() {
    if (_items.isEmpty) throw StateError('Stack is empty');
    return _items.last;
  }

  bool get isEmpty => _items.isEmpty;
  int get size => _items.length;

  @override
  String toString() => 'Stack($_items)';
}
