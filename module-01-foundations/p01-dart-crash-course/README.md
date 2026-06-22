# P01 — Dart Crash Course

**Module 01 · Part 01 · Week 1**

This part is **pure Dart** — no Flutter yet. Run every file with the Dart CLI:

```bash
dart run lib/01_variables.dart
dart run lib/02_null_safety.dart
# ...and so on
```

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
| `08_exercises.dart` | Practice problems — do these yourself first! |

## Key Insight from the Slides

> Use `final` for runtime constants, `const` for compile-time.  
> Only use `!` when you are **100% certain** a value cannot be null.  
> Prefer `??` and `?.` for safety.
