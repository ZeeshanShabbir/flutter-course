# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **D4WEE Flutter Course** mono-repo for Code for Pakistan — a 16-part, 12-week curriculum that takes students from zero Dart knowledge to a job-ready Flutter developer. Each `p0X-*` subdirectory is a **standalone Flutter project** with its own `pubspec.yaml`.

**Instructor:** Muhammad Zeeshan Shabbir

## Working with Individual Projects

Each project must be operated from its own directory. All commands below should be run from inside the relevant `pXX-*` folder.

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/calculator_test.dart

# Run integration tests
flutter test integration_test/

# Analyze for lint issues
flutter analyze

# Format code (80-char line length, as configured in the workspace)
dart format --line-length 80 lib/
```

### Code Generation (Freezed / Riverpod / Hive)

Projects that use `freezed`, `riverpod_generator`, `json_serializable`, or `hive_generator` require code generation:

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

Projects requiring code generation: `p04`, `p05`, `p06`, `p07`, `p08`, `p10`, `p13`.

## Architecture Patterns

All non-trivial projects share the same stack and conventions:

| Layer | Package | Notes |
|---|---|---|
| Navigation | `go_router` | Router defined as a `Provider<GoRouter>`, watches auth state for redirect guards |
| State | `flutter_riverpod` + `riverpod_annotation` | `ConsumerWidget` / `ConsumerStatefulWidget` throughout |
| HTTP | `dio` | Raw Dio with interceptors (not `http` package) |
| Models | `freezed` + `json_serializable` | Immutable, copyWith, JSON serialization |
| Local storage | `hive_flutter` or `shared_preferences` | Hive for structured data, SharedPrefs for simple key-value |
| Firebase | `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `firebase_crashlytics` | |
| Testing | `mockito` + `mocktail` | Use mocktail for null-safe mocking |

### GoRouter Pattern

The router is always a `Provider<GoRouter>` (not a global) so it can `ref.watch(authStateProvider)` and redirect unauthenticated users. Route constants live in a `Routes` class (see `p13`'s `lib/core/routing/app_router.dart`).

### Riverpod Entry Point

Every app wraps `main()` in `ProviderScope` before `MaterialApp.router`:

```dart
void main() => runApp(const ProviderScope(child: MyApp()));
```

`MyApp` extends `ConsumerWidget` to access `appRouterProvider`.

### Capstone Project Architecture (p13)

The most complete project uses feature-first folder structure:

```
lib/
├── core/
│   ├── routing/app_router.dart   ← GoRouter + route constants
│   ├── services/                 ← NotificationService, etc.
│   └── theme/app_theme.dart
├── features/
│   ├── auth/
│   │   ├── providers/            ← Riverpod providers
│   │   └── screens/
│   ├── tasks/
│   │   ├── models/task.dart      ← Freezed model
│   │   ├── providers/
│   │   └── screens/
│   └── settings/screens/
└── shared/widgets/app_shell.dart ← persistent BottomNav shell
```

Earlier projects (`p03`–`p08`) use a flat `screens/` + `providers/` + `models/` structure; migrate toward the feature-first layout for `p13`.

## Module Summaries

| Module | Projects | Key Additions |
|---|---|---|
| M01 Foundations | p01–p04 | Dart basics, widgets, GoRouter + Riverpod, Hive, SharedPrefs |
| M02 Real Features | p05–p08 | Dio + Freezed, Firebase full-stack, image_picker/FCM, mini-project |
| M03 Shipping & AI | p09–p12 | Animations/Lottie, unit/widget/integration tests, OpenAI API, ML Kit |
| M04 Capstone | p13–p16 | Production app, store publishing, freelancing, employment |

## VS Code Setup

Open `d4wee-flutter-course.code-workspace` to get the multi-root workspace with all projects visible, pre-configured launch targets (P02, P03, P08, P13), and workspace settings:
- `editor.formatOnSave: true` with the Dart formatter
- `dart.lineLength: 80`
- Generated files (`*.g.dart`, `*.freezed.dart`) excluded from search
