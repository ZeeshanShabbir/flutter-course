# P03 — Navigation & State Management

**Module 01 · Part 03 · Weeks 2–3**

Introduces the two packages you will use in every project from here on:
**GoRouter** for navigation and **Riverpod** for state management.

---

## Prerequisites

- Completed P01 and P02
- Flutter SDK installed — [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- A device or emulator ready

---

## Setup

### 1. Navigate to this project

```bash
cd module-01-foundations/p03-navigation-and-state
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

---

## Project Structure

```
p03-navigation-and-state/
├── lib/
│   ├── main.dart               ← GoRouter setup, ProviderScope, AppShell (BottomNav)
│   ├── models/
│   │   └── course.dart         ← Simple data model
│   ├── providers/
│   │   ├── auth_provider.dart  ← StateNotifier for login/logout
│   │   └── app_providers.dart  ← StateProvider, FutureProvider, derived providers
│   └── screens/
│       ├── login_screen.dart   ← Public route (no auth required)
│       ├── home_screen.dart    ← Course list with filter chips
│       ├── details_screen.dart ← Detail page with path parameter (:id)
│       ├── profile_screen.dart ← Counter demo with StateProvider
│       └── settings_screen.dart← Dark mode toggle
└── pubspec.yaml
```

---

## What You Will Learn

| Concept | Where to look |
|---------|--------------|
| GoRouter setup + named routes | `main.dart` → `routerProvider` |
| Route redirect for auth guard | `main.dart` → `redirect:` callback |
| Persistent BottomNav with `ShellRoute` | `main.dart` → `AppShell` |
| Path parameters (`/details/:id`) | `main.dart` + `details_screen.dart` |
| `StateNotifierProvider` for auth | `providers/auth_provider.dart` |
| `StateProvider` for simple values | `providers/app_providers.dart` |
| `FutureProvider` + `AsyncValue` | `providers/app_providers.dart` |
| Derived/computed providers | `providers/app_providers.dart` → `filteredCoursesProvider` |

---

## Key Concepts

**Wrap `main()` in `ProviderScope`**

```dart
void main() => runApp(const ProviderScope(child: MyApp()));
```

**Use `MaterialApp.router` with GoRouter**

```dart
// routerConfig wires GoRouter to MaterialApp — replaces the old routes: {}
return MaterialApp.router(routerConfig: ref.watch(routerProvider));
```

**Navigate with `context.go()` / `context.push()`**

```dart
context.go('/profile');           // replace current route
context.push('/details/42');      // push onto the stack
context.pop();                    // go back
```

**Watch vs Read**

```dart
// watch — subscribe; widget rebuilds when value changes
final count = ref.watch(counterProvider);

// read — one-time access; use inside callbacks, never in build()
ref.read(counterProvider.notifier).state++;
```

**Handle `AsyncValue` with `.when()`**

```dart
final courses = ref.watch(coursesProvider);
courses.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
  data: (list) => ListView(...),
);
```

---

*Next up: P04 — Forms & Local Storage (Hive + SharedPreferences)*
