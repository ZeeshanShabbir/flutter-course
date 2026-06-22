// ============================================================
// P13 — Capstone  
// File: lib/features/auth/screens/register_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
      _emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    ref.listen(authProvider, (_, next) {
      if (next.hasError) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.error.toString()), backgroundColor: AppTheme.danger));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Join D4WEE', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Create your account to get started',
                style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 32),
              TextFormField(controller: _nameCtrl, textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your full name' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _passCtrl, obscureText: _obscure,
                onFieldSubmitted: (_) => _register(),
                decoration: InputDecoration(labelText: 'Password (min 8 chars)',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure))),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password required';
                  if (v.length < 8) return 'Minimum 8 characters';
                  if (!v.contains(RegExp(r'[A-Z]'))) return 'Include uppercase letter';
                  if (!v.contains(RegExp(r'[0-9]'))) return 'Include a number';
                  return null;
                }),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: auth.isLoading ? null : _register,
                child: auth.isLoading ? const SizedBox(height: 22, width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account')),
              const SizedBox(height: 12),
              TextButton(onPressed: () => context.pop(), child: const Text('Already have an account? Sign In')),
            ]),
          ),
        ),
      ),
    );
  }
}
