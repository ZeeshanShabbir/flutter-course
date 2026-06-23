# P02 — Flutter Fundamentals

**Module 01 · Part 02 · Week 2**

Your first Flutter app. It covers the core widgets and layout system you will use
in every project throughout the course.

---

## Prerequisites

- Flutter SDK installed (stable channel)
  — [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- A device or emulator set up (Android or iOS)
- VS Code with the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) installed

Verify your setup:

```bash
flutter doctor
```

All ticks should be green (or at least the platform you plan to run on).

---

## Setup

### 1. Navigate to this project

```bash
cd module-01-foundations/p02-flutter-fundamentals
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

Plug in a device or start an emulator, then:

```bash
flutter run
```

To run on a specific device when multiple are connected:

```bash
flutter devices          # list available devices
flutter run -d <device-id>
```

---

## Project Structure

```
p02-flutter-fundamentals/
├── lib/
│   ├── main.dart                    ← App entry point, ThemeData
│   └── screens/
│       ├── home_screen.dart         ← Grid menu, Scaffold, AppBar
│       ├── widgets_demo_screen.dart ← Text, Container, Row/Column, Stack, Image
│       ├── stateful_demo_screen.dart← setState, counter, toggle
│       └── list_demo_screen.dart    ← ListView, GridView, builders
├── assets/
│   └── images/                      ← Add local images here
└── pubspec.yaml
```

---

## What You Will Learn

| Screen | Topic |
|--------|-------|
| Home | `Scaffold`, `AppBar`, `GridView`, named routes, `ThemeData` |
| Basic Widgets | `Text`, `Container`, `Row`, `Column`, `Stack`, `Image.network`, buttons |
| Stateful Widget | `StatefulWidget`, `setState`, counter, toggle switches |
| Lists & Grids | `ListView.builder`, `GridView.builder`, `ListTile` |

---

## Key Concepts

**Stateless vs Stateful**

```dart
// StatelessWidget — UI never changes after build
class MyWidget extends StatelessWidget { ... }

// StatefulWidget — call setState() to rebuild with new data
class MyWidget extends StatefulWidget { ... }
class _MyWidgetState extends State<MyWidget> {
  int count = 0;
  void increment() => setState(() => count++);
}
```

**Theme — never hardcode colours**

```dart
// Bad
color: Color(0xFF0397D6)

// Good — inherits from ThemeData in main.dart
color: Theme.of(context).colorScheme.primary
```

**Layout rules**

- `Row` → horizontal, `Column` → vertical
- `Expanded` fills remaining space; use `flex:` to set proportions
- `Stack` overlaps children (like CSS `position: absolute`)
- `SafeArea` keeps content away from notches and status bars

---

*Next up: P03 — Navigation & State with GoRouter + Riverpod*
