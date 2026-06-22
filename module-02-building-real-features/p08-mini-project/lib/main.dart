// ============================================================
// P08 — Mini-Project: Task Manager App
// File: lib/main.dart
//
// Slide reference: "Mini-Project — Complete App"
// Architecture slide: "Three-layer pattern:
//   data source → repository → notifier"
//
// FEATURE-FIRST STRUCTURE (from Capstone slide):
// lib/
// ├── core/           ← app-wide infrastructure
// │   ├── theme/      ← ThemeData, colors, text styles
// │   ├── routing/    ← GoRouter with auth guard
// │   └── services/   ← Firebase, Dio setup
// ├── features/       ← one folder per feature
// │   ├── auth/
// │   ├── tasks/
// │   └── profile/
// └── shared/         ← reusable widgets, utils
//     ├── widgets/
//     └── utils/
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ----------------------------------------------------------
  // INIT: Firebase
  // Uncomment after adding google-services.json / GoogleService-Info.plist
  // ----------------------------------------------------------
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  // ----------------------------------------------------------
  // INIT: Hive local storage
  // ----------------------------------------------------------
  await Hive.initFlutter();
  await Hive.openBox('tasks_cache');
  await Hive.openBox('user_prefs');

  runApp(
    const ProviderScope(
      child: TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends ConsumerWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Task Manager — D4WEE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
