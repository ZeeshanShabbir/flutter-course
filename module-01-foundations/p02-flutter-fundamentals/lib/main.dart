// ============================================================
// P02 — Flutter Fundamentals
// File: lib/main.dart
//
// ENTRY POINT for every Flutter app.
// main() → runApp() → MyApp (MaterialApp) → HomeScreen
//
// Slide reference: "How Flutter Actually Works"
// Key concept: "The widget tree, element tree, and render tree"
// ============================================================

import 'package:flutter/material.dart';

// Import our screen files
import 'screens/home_screen.dart';
import 'screens/widgets_demo_screen.dart';
import 'screens/stateful_demo_screen.dart';
import 'screens/list_demo_screen.dart';

void main() {
  // runApp() takes a widget and makes it the ROOT of the widget tree.
  // Everything in Flutter is a widget — from the whole screen
  // down to a single pixel of padding.
  runApp(const MyApp());
}

// ============================================================
// MyApp — The root widget
// This is a StatelessWidget because the app itself doesn't change.
// StatelessWidget: describe → build → render. That's it.
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up:
    // - Navigation (routing)
    // - Theme (colours, fonts, shapes)
    // - Localisation
    // - Debug banner
    return MaterialApp(
      title: 'D4WEE Flutter Fundamentals',
      debugShowCheckedModeBanner: false, // hides the "DEBUG" ribbon
      // -------------------------------------------------------
      // ThemeData — define your app's visual language ONCE here.
      // Every widget inherits these values automatically.
      // You never hardcode Color.blue in widgets — use the theme.
      // -------------------------------------------------------
      theme: ThemeData(
        // colorScheme generates a harmonious colour palette from one seed.
        // Material 3 (useMaterial3: true) is the modern standard.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0397D6), // D4WEE brand blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // Typography — Calibri/Montserrat per brand guidelines
        // (Calibri isn't bundled with Flutter; Arial is the fallback)
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1D1F),
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1F),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1D1D1F)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF555555)),
        ),

        // AppBar theme — consistent header across all screens
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0397D6),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0397D6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Card theme — white cards with subtle shadow
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Scaffold background — matches the template's light grey
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),

      // Dark theme — defined once, auto-applied when OS switches
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0397D6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1D1D1F),
      ),

      // Follow the OS setting for light/dark
      themeMode: ThemeMode.system,

      // Named routes — map strings to screens
      // In P03 we switch to GoRouter, but named routes are fine to start.
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/widgets': (context) => const WidgetsDemoScreen(),
        '/stateful': (context) => const StatefulDemoScreen(),
        '/list': (context) => const ListDemoScreen(),
      },
    );
  }
}
