// ============================================================
// P01 — Dart Crash Course
// File: 01_variables.dart
//
// TOPIC: Variables, Type Inference, final vs const
//
// Slide reference: "Variables & Type Inference"
// Key quote: "Use final for runtime constants, const for
//             compile-time. Prefer var when the type is
//             obvious from context."
// ============================================================

void main() {
  // ----------------------------------------------------------
  // 1. EXPLICIT TYPE DECLARATIONS
  // You tell Dart exactly what type a variable holds.
  // ----------------------------------------------------------
  int age = 25;
  double pi = 3.14159;
  String name = 'Ayesha';
  bool isEnrolled = true;

  print('=== Explicit Types ===');
  print('age: $age');          // int
  print('pi: $pi');            // double
  print('name: $name');        // String
  print('isEnrolled: $isEnrolled'); // bool

  // ----------------------------------------------------------
  // 2. TYPE INFERENCE WITH var
  // Dart figures out the type automatically from the value.
  // Use var when the type is obvious — less typing, same safety.
  // ----------------------------------------------------------
  var studentName = 'Bilal';   // Dart infers: String
  var score = 98;              // Dart infers: int
  var gpa = 3.8;               // Dart infers: double

  print('\n=== Type Inference ===');
  print('$studentName scored $score with GPA $gpa');

  // Once inferred, the type is FIXED. This would be an error:
  // studentName = 42; // ❌ A value of type 'int' can't be assigned to 'String'

  // ----------------------------------------------------------
  // 3. final — SET ONCE AT RUNTIME
  // Use final when the value is assigned once and never changes,
  // but you don't know the value until the program runs.
  // ----------------------------------------------------------
  final DateTime courseStartDate = DateTime.now();
  final String courseName = 'Mobile Development with Flutter';

  // This would fail at compile time:
  // courseStartDate = DateTime(2025); // ❌ final variable can't be reassigned

  print('\n=== final ===');
  print('Course: $courseName');
  print('Started: $courseStartDate');

  // ----------------------------------------------------------
  // 4. const — COMPILE-TIME CONSTANT
  // Use const when the value is known BEFORE the program runs.
  // const is slightly more efficient than final because Dart
  // can bake the value right into the compiled binary.
  // ----------------------------------------------------------
  const int maxStudents = 30;
  const String appName = 'D4WEE Learning App';
  const double taxRate = 0.17;

  print('\n=== const ===');
  print('App: $appName');
  print('Max students: $maxStudents');
  print('Tax rate: ${taxRate * 100}%');

  // ----------------------------------------------------------
  // 5. DYNAMIC — AVOID IN PRODUCTION CODE
  // dynamic lets you change the type at runtime, but you lose
  // all type safety. Only use it when you truly need it
  // (e.g., parsing unknown JSON structures).
  // ----------------------------------------------------------
  dynamic anything = 'Start as String';
  print('\n=== dynamic (use sparingly) ===');
  print(anything); // String

  anything = 42;   // Now it's an int — no error
  print(anything); // int

  // ----------------------------------------------------------
  // 6. STRING INTERPOLATION
  // Use $ for simple variable insertion, ${} for expressions.
  // ----------------------------------------------------------
  String city = 'Islamabad';
  int population = 1090000;

  print('\n=== String Interpolation ===');
  print('City: $city');
  // Expression inside ${}:
  print('Population in millions: ${population / 1000000}');
  print('Uppercase: ${city.toUpperCase()}');

  // Multi-line strings use triple quotes:
  String multiLine = '''
  Welcome to $appName!
  We have $maxStudents spots available.
  Enrolment is currently: $isEnrolled
  ''';
  print(multiLine);
}
