// ============================================================
// P01 — Dart Crash Course
// File: 03_functions.dart
//
// TOPIC: Functions — Arrow syntax, named params, optional params
//
// Slide reference: "Function syntax in Dart"
// Key quote: "Three styles you will use every day in Flutter code."
// ============================================================

void main() {
  // ----------------------------------------------------------
  // 1. BASIC FUNCTIONS
  // ----------------------------------------------------------
  print('=== Basic Functions ===');

  int sum = add(10, 20);
  print('10 + 20 = $sum');

  print(greetStudent('Fatima'));

  // ----------------------------------------------------------
  // 2. ARROW SYNTAX (=>)
  // For single-expression functions — you'll see this EVERYWHERE
  // in Flutter (widget builders, list operations, etc.)
  // ----------------------------------------------------------
  print('\n=== Arrow Syntax ===');

  // These two are identical:
  // Regular:
  int multiplyRegular(int a, int b) {
    return a * b;
  }
  // Arrow (single expression only):

  print('5 × 6 = ${multiply(5, 6)}');
  print('Is even: ${isEven(4)}');
  print('Is even: ${isEven(7)}');

  // Arrow functions with lists — very common in Flutter:
  List<int> numbers = [1, 2, 3, 4, 5];
  List<int> doubled = numbers.map((n) => n * 2).toList();
  print('Doubled: $doubled');

  // ----------------------------------------------------------
  // 3. NAMED PARAMETERS
  // Parameters passed by name — order doesn't matter.
  // This is THE most common pattern in Flutter widget constructors.
  //
  // Example from Flutter: Text('Hello', fontSize: 18, color: blue)
  // ----------------------------------------------------------
  print('\n=== Named Parameters ===');

  // required — must always be provided
  String msg1 = createMessage(title: 'Welcome', body: 'To D4WEE!');
  print(msg1);

  // Default values — optional to provide
  String msg2 = createMessage(title: 'Notice');
  print(msg2);

  // Named params can be passed in any order:
  String msg3 = createMessage(
    body: 'Enrolment is open',
    title: 'Announcement',
    isUrgent: true,
  );
  print(msg3);

  // ----------------------------------------------------------
  // 4. OPTIONAL POSITIONAL PARAMETERS [ ]
  // In square brackets — can be omitted, position matters.
  // Less common than named params in Flutter.
  // ----------------------------------------------------------
  print('\n=== Optional Positional Parameters ===');

  print(buildUrl('api.example.com'));
  print(buildUrl('api.example.com', '/users'));
  print(buildUrl('api.example.com', '/users', 'https'));

  // ----------------------------------------------------------
  // 5. HIGHER-ORDER FUNCTIONS
  // Functions that accept or return other functions.
  // Used heavily with List, Stream, Future in Flutter.
  // ----------------------------------------------------------
  print('\n=== Higher-Order Functions ===');

  List<String> students = ['Ali', 'Bilal', 'Fatima', 'Zainab', 'Hassan'];

  // map — transform each item
  List<String> upper = students.map((s) => s.toUpperCase()).toList();
  print('Uppercase: $upper');

  // where — filter items
  List<String> longNames = students.where((s) => s.length > 4).toList();
  print('Long names: $longNames');

  // any / every
  bool anyStartsWithF = students.any((s) => s.startsWith('F'));
  print('Any starts with F: $anyStartsWithF'); // true

  // forEach — side effects only, doesn't return
  print('All students:');
  students.forEach((s) => print('  → $s'));

  // fold — reduce to a single value
  int totalLength = students.fold(0, (sum, s) => sum + s.length);
  print('Total chars in all names: $totalLength');

  // sort (mutates in place)
  List<String> sorted = List.from(students)..sort();
  print('Sorted: $sorted');

  // ----------------------------------------------------------
  // 6. ANONYMOUS FUNCTIONS & CLOSURES
  // ----------------------------------------------------------
  print('\n=== Closures ===');

  // A closure "captures" variables from its surrounding scope.
  // This is how callbacks work in Flutter (onPressed, onChanged, etc.)
  Function makeCounter() {
    int count = 0;
    return () {
      count++;
      return count;
    };
  }

  var counter = makeCounter();
  print(counter()); // 1
  print(counter()); // 2
  print(counter()); // 3

  // ----------------------------------------------------------
  // 7. TYPEDEF — naming function types
  // Useful for callbacks in widget APIs (like onChanged)
  // ----------------------------------------------------------
  print('\n=== typedef ===');

  Validator emailValidator = (value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null; // null = valid
  };

  print(emailValidator(null));           // Email is required
  print(emailValidator('notanemail'));   // Enter a valid email
  print(emailValidator('a@b.com'));      // null (valid)
}

// ----------------------------------------------------------
// FUNCTION DEFINITIONS
// ----------------------------------------------------------

// Regular function
int add(int a, int b) {
  return a + b;
}

// Arrow function — single expression, implicit return
int multiply(int a, int b) => a * b;
bool isEven(int n) => n % 2 == 0;
String greetStudent(String name) => 'Welcome, $name!';

// Named parameters:
// - required String title → MUST be provided (no default)
// - String body → optional, defaults to empty string
// - bool isUrgent → optional, defaults to false
String createMessage({
  required String title,
  String body = '',
  bool isUrgent = false,
}) {
  final prefix = isUrgent ? '🚨 URGENT: ' : '';
  final bodyPart = body.isNotEmpty ? '\n  $body' : '';
  return '$prefix$title$bodyPart';
}

// Optional positional parameters — wrapped in [ ]
// Parameters after [ ] have defaults and can be skipped
String buildUrl(String host, [String path = '/', String scheme = 'http']) {
  return '$scheme://$host$path';
}

// typedef — a named type for a function signature
// This matches the same signature as TextFormField's validator
typedef Validator = String? Function(String? value);
