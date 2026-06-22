// ============================================================
// P08 — Mini-Project: Task Manager
// File: lib/features/auth/providers/auth_provider.dart
//
// Firebase Auth provider — real authentication.
// Slide reference: P06 "Firebase Auth — email + Google"
//
// To activate Firebase:
// 1. Run: flutterfire configure
// 2. Uncomment Firebase imports below
// 3. Remove the mock AuthService and use FirebaseAuth directly
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// AUTH USER MODEL — what we expose to the app
// ============================================================
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }
}

// ============================================================
// MOCK AUTH SERVICE
// Replace this with FirebaseAuth in P06
// ============================================================
class MockAuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Stream<AppUser?> get authStateChanges async* {
    yield _currentUser;
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid credentials');
    }
    _currentUser = AppUser(
      uid: 'uid_${email.hashCode.abs()}',
      email: email,
      displayName: email.split('@').first,
    );
    return _currentUser!;
  }

  Future<AppUser> register(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = AppUser(
      uid: 'uid_${email.hashCode.abs()}',
      email: email,
      displayName: name,
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}

// Singleton — one auth service for the app lifetime
final _authService = MockAuthService();

// ============================================================
// STREAM PROVIDER — emits auth state changes
// GoRouter watches this to redirect login/logout
// ============================================================
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return _authService.authStateChanges;
});

// ============================================================
// NOTIFIER — sign in, register, sign out
// ============================================================
class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async => _authService.currentUser;

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.signInWithEmail(email, password),
    );
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.register(email, password, name),
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncData(null);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

// Convenience provider — non-null current user
// Use this in screens where auth is guaranteed (protected routes)
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ============================================================
// FIREBASE AUTH VERSION (activate in P06)
// ============================================================
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// final authStateProvider = StreamProvider<User?>((ref) {
//   return FirebaseAuth.instance.authStateChanges();
// });
//
// class FirebaseAuthNotifier extends AsyncNotifier<User?> {
//   FirebaseAuth get _auth => FirebaseAuth.instance;
//
//   @override
//   Future<User?> build() async => _auth.currentUser;
//
//   Future<void> signIn(String email, String password) async {
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(() async {
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email, password: password,
//       );
//       return credential.user;
//     });
//   }
//
//   Future<void> signInWithGoogle() async {
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(() async {
//       final googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) throw Exception('Google sign-in cancelled');
//       final credential = GoogleAuthProvider.credential(
//         accessToken: (await googleUser.authentication).accessToken,
//         idToken: (await googleUser.authentication).idToken,
//       );
//       final userCredential = await _auth.signInWithCredential(credential);
//       return userCredential.user;
//     });
//   }
//
//   Future<void> signOut() async {
//     await _auth.signOut();
//     await GoogleSignIn().signOut();
//     state = const AsyncData(null);
//   }
// }
