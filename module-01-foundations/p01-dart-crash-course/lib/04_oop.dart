// ============================================================
// P01 — Dart Crash Course
// File: 04_oop.dart
//
// TOPIC: Object-Oriented Programming
//        Classes, constructors, inheritance, mixins, interfaces
//
// Slide reference: "Object-Oriented Programming"
// ============================================================

void main() {
  print('=== Basic Class ===');
  final student = Student(name: 'Ayesha', age: 22);
  print(student); // uses toString()
  student.enroll('Flutter Course');
  student.printInfo();

  print('\n=== Named & Factory Constructors ===');
  final guest = Student.guest();
  print(guest);

  final fromJson = Student.fromJson({'name': 'Hassan', 'age': 25});
  print(fromJson);

  print('\n=== Inheritance ===');
  final gradStudent = GraduateStudent(
    name: 'Bilal',
    age: 28,
    thesis: 'AI in Mobile Apps',
  );
  gradStudent.printInfo();
  gradStudent.submitThesis();

  print('\n=== Abstract Class ===');
  // Cannot instantiate: final shape = Shape(); // ❌
  final circle = Circle(radius: 5);
  final rect = Rectangle(width: 4, height: 6);
  printShapeInfo(circle);
  printShapeInfo(rect);

  print('\n=== Mixin ===');
  final athlete = Athlete(name: 'Zainab');
  athlete.run();
  athlete.swim();
  athlete.printInfo();

  print('\n=== Interface (implements) ===');
  final emailNotifier = EmailNotifier();
  final smsNotifier = SmsNotifier();
  sendNotification(emailNotifier, 'Course starts Monday!');
  sendNotification(smsNotifier, 'Course starts Monday!');
}

// ============================================================
// 1. BASIC CLASS
// The blueprint for creating objects.
// ============================================================
class Student {
  // Instance variables (fields)
  final String name;
  final int age;
  List<String> enrolledCourses = [];

  // ----------------------------------------------------------
  // DEFAULT CONSTRUCTOR
  // The most common way to create an instance.
  // 'this.name' is shorthand for: name = name (parameter)
  // ----------------------------------------------------------
  Student({required this.name, required this.age});

  // ----------------------------------------------------------
  // NAMED CONSTRUCTOR
  // A class can have multiple named constructors.
  // Great for creating instances from different sources.
  // ----------------------------------------------------------
  Student.guest() : name = 'Guest', age = 0;

  // FACTORY CONSTRUCTOR
  // Returns an instance but runs custom logic first.
  // Commonly used for parsing JSON.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }

  // ----------------------------------------------------------
  // METHODS
  // ----------------------------------------------------------
  void enroll(String course) {
    enrolledCourses.add(course);
    print('$name enrolled in: $course');
  }

  void printInfo() {
    print('Student: $name (age $age) | Courses: $enrolledCourses');
  }

  // Override toString so print(student) shows useful info
  @override
  String toString() => 'Student(name: $name, age: $age)';
}

// ============================================================
// 2. INHERITANCE — extends
// GraduateStudent IS-A Student (inherits everything).
// Use super to call the parent constructor.
// ============================================================
class GraduateStudent extends Student {
  final String thesis;

  GraduateStudent({
    required super.name, // passes to parent constructor
    required super.age,
    required this.thesis,
  });

  void submitThesis() {
    print('$name submitted thesis: "$thesis"');
  }

  // Override a parent method to add/change behaviour
  @override
  void printInfo() {
    super.printInfo(); // call parent version first
    print('  Thesis: $thesis');
  }
}

// ============================================================
// 3. ABSTRACT CLASS
// A contract — defines what subclasses MUST implement.
// Cannot be instantiated directly.
// ============================================================
abstract class Shape {
  // Abstract methods have no body — subclasses must implement them
  double area();
  double perimeter();

  // Concrete method — subclasses inherit this for free
  void describe() {
    print('Area: ${area().toStringAsFixed(2)}, Perimeter: ${perimeter().toStringAsFixed(2)}');
  }
}

class Circle extends Shape {
  final double radius;
  Circle({required this.radius});

  @override
  double area() => 3.14159 * radius * radius;

  @override
  double perimeter() => 2 * 3.14159 * radius;

  @override
  String toString() => 'Circle(r=$radius)';
}

class Rectangle extends Shape {
  final double width, height;
  Rectangle({required this.width, required this.height});

  @override
  double area() => width * height;

  @override
  double perimeter() => 2 * (width + height);

  @override
  String toString() => 'Rectangle(${width}x$height)';
}

void printShapeInfo(Shape shape) {
  print(shape);
  shape.describe();
}

// ============================================================
// 4. MIXINS
// Add capabilities to a class WITHOUT inheritance.
// A class can mix in multiple mixins (solves multi-inheritance).
// Flutter uses mixins for things like TickerProviderStateMixin.
// ============================================================
mixin Runnable {
  void run() => print('$runtimeType is running!');
}

mixin Swimmable {
  void swim() => print('$runtimeType is swimming!');
}

// Athlete gets BOTH run() and swim() without any inheritance chain
class Athlete extends Student with Runnable, Swimmable {
  Athlete({required super.name}) : super(age: 20);
}

// ============================================================
// 5. INTERFACES (implements)
// In Dart, every class implicitly defines an interface.
// 'implements' forces you to implement ALL members.
// Use when you want a strict contract without shared code.
// ============================================================
abstract class Notifier {
  void send(String message);
  String get channelName;
}

class EmailNotifier implements Notifier {
  @override
  String get channelName => 'Email';

  @override
  void send(String message) {
    print('[$channelName] Sending: "$message"');
  }
}

class SmsNotifier implements Notifier {
  @override
  String get channelName => 'SMS';

  @override
  void send(String message) {
    print('[$channelName] Sending: "$message"');
  }
}

// This function accepts ANY Notifier — polymorphism at work
void sendNotification(Notifier notifier, String message) {
  notifier.send(message);
}
