// ============================================================
// P13 — Capstone
// File: lib/features/auth/providers/auth_provider.dart
// ============================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (displayName != null && displayName!.trim().isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }
}

// ── Mock implementation (swap with Firebase in production) ──
class _MockAuth {
  AppUser? _user;
  final _controller = StreamController<AppUser?>.broadcast();

  _MockAuth() {
    _controller.add(null);
  }

  Stream<AppUser?> get stream => _controller.stream;
  AppUser? get current => _user;

  Future<AppUser> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (password.length < 6) throw Exception('Invalid credentials');
    _user = AppUser(uid: 'uid_${email.hashCode.abs()}', email: email,
        displayName: email.split('@').first);
    _controller.add(_user);
    return _user!;
  }

  Future<AppUser> register(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _user = AppUser(uid: 'uid_${email.hashCode.abs()}', email: email,
        displayName: name);
    _controller.add(_user);
    return _user!;
  }

  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}

final _auth = _MockAuth();

final authStateProvider = StreamProvider<AppUser?>((ref) => _auth.stream);
final currentUserProvider = Provider<AppUser?>((ref) =>
    ref.watch(authStateProvider).valueOrNull);

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async => _auth.current;

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _auth.signIn(email, password));
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _auth.register(email, password, name));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);
