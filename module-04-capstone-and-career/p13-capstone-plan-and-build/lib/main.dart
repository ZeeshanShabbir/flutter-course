// ============================================================
// P13 — Capstone: Plan & Build
// File: lib/main.dart
//
// THE CAPSTONE APP — A production-quality task/project manager
// that combines everything from the course.
//
// Slide reference: "Capstone Definition of Done" checklist:
//   ☑ Firebase Auth (email + Google)
//   ☑ Firestore real-time CRUD
//   ☑ GoRouter with auth redirect
//   ☑ Riverpod state management
//   ☑ Offline support (Hive cache)
//   ☑ Push notifications
//   ☑ Dark mode
//   ☑ Responsive layout
//   ☑ Error handling for all async operations
//   ☑ Unit + widget tests
//   ☑ Analytics events logged
//   ☑ Crash reporting enabled
//
// ARCHITECTURE (Three-Layer):
// ┌────────────────────────────────────────┐
// │  UI Layer (Screens / Widgets)          │
// │  Reads providers, shows async states   │
// ├────────────────────────────────────────┤
// │  Domain Layer (Providers / Notifiers)  │
// │  Business logic, optimistic updates    │
// ├────────────────────────────────────────┤
// │  Data Layer (Repositories / Services)  │
// │  Firestore, Hive, Dio — swap freely    │
// └────────────────────────────────────────┘
//
// FEATURE-FIRST FOLDER STRUCTURE (from slides):
// lib/
// ├── core/           ← theme, routing, services, di
// ├── features/
// │   ├── auth/       ← login, register, auth state
// │   ├── tasks/      ← task CRUD, filtering, details
// │   ├── projects/   ← project grouping for tasks
// │   ├── notifications/ ← FCM + local notifications
// │   └── settings/   ← profile, dark mode, logout
// └── shared/         ← reusable widgets + utils
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ───────────────────────────────────────────────
  // STEP 1: Run `flutterfire configure` then uncomment:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // FlutterError.onError =
  //     FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (e, s) {
  //   FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
  //   return true;
  // };

  // ── Local Storage ──────────────────────────────────────────
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('tasks_cache'),
    Hive.openBox('projects_cache'),
    Hive.openBox('user_prefs'),
  ]);

  // ── Notifications ──────────────────────────────────────────
  await NotificationService.instance.initialize();

  runApp(
    // ProviderScope = Riverpod's root — wraps the entire app
    const ProviderScope(
      child: CapstoneApp(),
    ),
  );
}

class CapstoneApp extends ConsumerWidget {
  const CapstoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Capstone — D4WEE Flutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

// Theme mode provider — persisted to SharedPreferences
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
        (ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final box = Hive.box('user_prefs');
    final index = box.get('theme_mode', defaultValue: 0) as int;
    state = ThemeMode.values[index];
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    Hive.box('user_prefs').put('theme_mode', mode.index);
  }
}
