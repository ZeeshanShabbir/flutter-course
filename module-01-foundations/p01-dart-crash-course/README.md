# P01 — Dart Crash Course

**Module 01 · Part 01 · Week 1**

This part is **pure Dart** — no Flutter yet. You will run each file directly with
the Dart CLI to learn the language before we touch any UI.

---

## Prerequisites

You need the **Dart SDK** installed. The easiest way is to install Flutter (which
bundles Dart), or install Dart on its own.

### Option A — Install Flutter (recommended, needed later anyway)

Follow the official guide for your OS:
[https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

Flutter comes with Dart built in. After installation, verify:

```bash
flutter --version
dart --version
```

### Option B — Install Dart only

[https://dart.dev/get-dart](https://dart.dev/get-dart)

After installation, verify:

```bash
dart --version
```

---

## Setup

### 1. Clone the repo (if you haven't already)

```bash
git clone <repo-url>
cd flutter-course-d4wee
```

### 2. Open the project folder

```bash
cd module-01-foundations/p01-dart-crash-course
```

This project has **no `pubspec.yaml`** because it uses only the Dart standard
library — no dependencies to install.

---

## Running the Files

Each file in `lib/` is a standalone Dart script with its own `main()` function.
Run them one at a time from inside the `p01-dart-crash-course` folder:

```bash
dart run lib/01_variables.dart
dart run lib/02_null_safety.dart
dart run lib/03_functions.dart
dart run lib/04_oop.dart
dart run lib/05_collections.dart
dart run lib/06_async.dart
dart run lib/07_streams.dart
dart run lib/08_exercises.dart
```

Work through them **in order** — each file builds on the concepts from the one
before it.

---

## What You Will Learn

| File | Topic |
|------|-------|
| `01_variables.dart` | Variables, type inference, `final` vs `const` |
| `02_null_safety.dart` | `?`, `??`, `?.`, `!`, `late` |
| `03_functions.dart` | Arrow syntax, named params, optional params |
| `04_oop.dart` | Classes, constructors, inheritance, mixins |
| `05_collections.dart` | List, Map, Set, generics, functional ops |
| `06_async.dart` | Future, async/await, try/catch |
| `07_streams.dart` | Stream, StreamController, broadcast |
| `08_exercises.dart` | Practice problems — attempt these yourself first! |

---

## Key Takeaways

> Use `final` for runtime constants, `const` for compile-time constants.
>
> Only use `!` when you are **100% certain** a value cannot be null.
>
> Prefer `??` and `?.` — they are safer and more idiomatic Dart.

---

## Recommended Editor

**VS Code** with the [Dart extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) installed gives you syntax highlighting, auto-complete, and inline errors.

After installing the extension, open the folder:

```bash
code .
```

---

*Next up: P02 — Flutter Fundamentals (released in Week 2)*
