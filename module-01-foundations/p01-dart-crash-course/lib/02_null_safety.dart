// ============================================================
// P01 — Dart Crash Course
// File: 02_null_safety.dart
//
// TOPIC: Null Safety — The Five Operators
//
// Slide reference: "Null Safety — The Five Operators"
// Key quote: "Only use ! when you are 100% certain a value
//             cannot be null. Prefer ?? and ?. for safety."
//
// WHY NULL SAFETY MATTERS:
// Before null safety, apps crashed with
// "Null check operator used on a null value" at runtime.
// Dart's null safety catches these bugs at COMPILE TIME.
// ============================================================

// A class we'll use for examples
class Student {
  final String name;
  final String? email; // nullable — student may not have email yet

  Student({required this.name, this.email});

  String greet() => 'Hello, $name!';
}

void main() {
  // ----------------------------------------------------------
  // OPERATOR 1: ? — Nullable Type Declaration
  // Adding ? after a type means "this variable CAN be null".
  // Without ?, null is not allowed.
  // ----------------------------------------------------------
  print('=== ? — Nullable Type ===');

  String nonNullable = 'I must have a value'; // cannot be null
  String? nullable;   // starts as null — perfectly fine

  print('nonNullable: $nonNullable');
  print('nullable before assignment: $nullable'); // prints: null

  nullable = 'Now I have a value';
  print('nullable after assignment: $nullable');

  // ----------------------------------------------------------
  // OPERATOR 2: ?? — Null Fallback (if-null operator)
  // "Give me the left side; if it's null, give me the right."
  // This is the SAFEST and most common pattern.
  // ----------------------------------------------------------
  print('\n=== ?? — Null Fallback ===');

  String? userName;
  String displayName = userName ?? 'Guest';
  print('Display name: $displayName'); // Guest

  userName = 'Fatima';
  displayName = userName ?? 'Guest';
  print('Display name: $displayName'); // Fatima

  // ??= assigns only if the variable is currently null:
  String? city;
  city ??= 'Islamabad'; // assigns because city is null
  print('City: $city');  // Islamabad

  city ??= 'Lahore'; // does NOT assign because city is already set
  print('City: $city');  // still Islamabad

  // ----------------------------------------------------------
  // OPERATOR 3: ?. — Safe Navigation (null-aware access)
  // "Access this property/method, but only if the object isn't null."
  // Returns null instead of crashing if the object is null.
  // ----------------------------------------------------------
  print('\n=== ?. — Safe Navigation ===');

  String? optionalName = 'Muhammad';
  int? nameLength = optionalName?.length; // 8
  print('Length: $nameLength');

  optionalName = null;
  nameLength = optionalName?.length; // null — no crash!
  print('Length when null: $nameLength');

  // Chain multiple ?. calls safely:
  Student? student;
  // Without safe navigation this would crash:
  // String greeting = student.greet(); // ❌ crash
  String? greeting = student?.greet(); // null — safe
  print('Greeting: $greeting');

  student = Student(name: 'Zainab', email: null);
  greeting = student.greet();
  print('Greeting: $greeting'); // Hello, Zainab!

  // ----------------------------------------------------------
  // OPERATOR 4: ! — Force Unwrap (null assertion)
  // "I PROMISE this is not null — trust me, Dart."
  // If you're wrong, the app CRASHES at runtime.
  // Only use ! when you are 100% certain.
  // ----------------------------------------------------------
  print('\n=== ! — Force Unwrap (use sparingly) ===');

  String? definitelyHasValue = 'I will not be null';

  // When you KNOW it's not null:
  int length = definitelyHasValue!.length; // safe here
  print('Length: $length');

  // ⚠️ DANGER — never do this without being certain:
  // String? mightBeNull;
  // print(mightBeNull!.length); // ❌ CRASH: Null check operator on null

  // A safer approach — check first:
  String? mightBeNull = fetchUserName(); // might return null
  if (mightBeNull != null) {
    // Inside this block, Dart KNOWS it's not null (type promotion)
    print('Name length: ${mightBeNull.length}'); // no ! needed!
  }

  // ----------------------------------------------------------
  // OPERATOR 5: late — Deferred Initialisation
  // "I promise I'll set this before I read it."
  // Used for variables that can't be set in the constructor
  // but are guaranteed to be set before first use.
  // ----------------------------------------------------------
  print('\n=== late — Deferred Init ===');

  late String token; // not set yet — no null type needed

  // Imagine an async operation sets this:
  token = fetchAuthToken();

  // Now it's safe to use:
  print('Token: $token');

  // ⚠️ If you read a late variable before setting it:
  // late String unset;
  // print(unset); // ❌ LateInitializationError at runtime

  // ----------------------------------------------------------
  // PRACTICAL PATTERNS — combining operators
  // ----------------------------------------------------------
  print('\n=== Practical Patterns ===');

  Student? currentUser = Student(name: 'Ali');

  // Pattern 1: safe access with fallback
  String email = currentUser?.email ?? 'no-email@placeholder.com';
  print('Email: $email');

  // Pattern 2: check and use (type promotion — no ! needed)
  if (currentUser != null) {
    print(currentUser.greet()); // Dart promotes type to Student (non-null)
  }

  // Pattern 3: early return guard
  String result = processStudent(null);
  print('Result: $result');

  result = processStudent(Student(name: 'Hassan'));
  print('Result: $result');
}

// Simulates fetching from a database — might return null
String? fetchUserName() => null;

// Simulates auth token retrieval
String fetchAuthToken() => 'eyJhbGciOiJIUzI1NiJ9.abc123';

// Early return guard pattern — very common in Flutter code
String processStudent(Student? student) {
  // Guard clause: exit early if null
  if (student == null) return 'No student provided';

  // From here on, student is guaranteed non-null
  return student.greet();
}
