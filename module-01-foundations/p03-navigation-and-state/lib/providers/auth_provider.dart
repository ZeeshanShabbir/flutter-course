// ============================================================
// P03 — Navigation & State Management
// File: lib/providers/auth_provider.dart
//
// TOPIC: Riverpod — StateNotifier for auth state
//
// Slide reference: "GoRouter with redirect for auth"
// Key quote: "Auth-state guard at the router level. UI never
//             has to check 'is the user logged in' before
//             showing protected content."
//
// PATTERN: StateNotifier + StateNotifierProvider
// - State = immutable data class (AuthState)
// - Notifier = methods that change the state
// - Provider = exposes the notifier to the widget tree
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// AUTH STATE — the data we track
// Immutable: to change, you create a new instance
// ============================================================
class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? displayName;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.displayName,
    this.isLoading = false,
    this.error,
  });

  // copyWith — create a new state with some fields changed
  // This is the pattern Riverpod/immutable state uses everywhere.
  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? displayName,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================================
// AUTH NOTIFIER — the logic layer
// extends StateNotifier<AuthState>: wraps state with change methods
// ============================================================
class AuthNotifier extends StateNotifier<AuthState> {
  // super() sets the initial state
  AuthNotifier() : super(const AuthState());

  // Login — simulate an async auth call
  Future<void> login(String email, String password) async {
    // 1. Set loading state → UI shows loading indicator
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 2. Simulate network call (replace with Firebase Auth in P06)
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation — in production: Firebase Auth
      if (email.isEmpty || password.length < 6) {
        throw Exception('Invalid email or password');
      }

      // 3. Success → set logged-in state
      // This triggers: GoRouter redirect → navigates to home
      state = AuthState(
        isLoggedIn: true,
        userId: 'user_${email.hashCode.abs()}',
        displayName: email.split('@').first,
      );
    } catch (e) {
      // 4. Error → update state with error message
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Logout — clear all state
  void logout() {
    // Resetting to initial state triggers GoRouter redirect → login
    state = const AuthState();
  }
}

// ============================================================
// PROVIDER — exposes AuthNotifier to the widget tree
//
// StateNotifierProvider gives you:
//   ref.watch(authProvider)         → AuthState (rebuilds on change)
//   ref.watch(authProvider.notifier) → AuthNotifier (to call methods)
//   ref.read(authProvider.notifier)  → for one-time calls (in callbacks)
// ============================================================
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
