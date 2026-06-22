// ============================================================
// P04 — Forms & Local Storage
// File: lib/screens/form_demo_screen.dart
//
// TOPIC: TextFormField, Form, GlobalKey, validation
//
// Slide reference: "Forms, Validation & User Input"
// Key quote: "validate(), save(), reset() — and why order matters"
//
// THE FORM PATTERN:
// 1. Create a GlobalKey<FormState> — unique identifier for the Form
// 2. Wrap inputs in Form(key: _formKey, ...)
// 3. Use TextFormField with validator: callback
// 4. On submit: if (_formKey.currentState!.validate()) { ... }
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormDemoScreen extends StatefulWidget {
  const FormDemoScreen({super.key});

  @override
  State<FormDemoScreen> createState() => _FormDemoScreenState();
}

class _FormDemoScreenState extends State<FormDemoScreen> {
  // GlobalKey links this State to the Form widget
  // Used to call validate(), save(), reset()
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers hold the value and let you read/clear it
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  // FocusNodes — control which field has keyboard focus
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _bioFocus = FocusNode();

  @override
  void dispose() {
    // IMPORTANT: dispose all controllers and focus nodes
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _bioCtrl.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Step 1: validate() runs ALL validator callbacks
    // Returns true only if ALL validators return null
    if (!_formKey.currentState!.validate()) return;

    // Step 2: check additional conditions
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Step 3: save() calls the onSaved callback on each field (optional)
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // Simulate form submission
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Registration Successful! 🎉'),
            content: Text(
              'Name: ${_nameCtrl.text}\n'
              'Email: ${_emailCtrl.text}\n'
              'Phone: ${_phoneCtrl.text}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _formKey.currentState!.reset();
                  _nameCtrl.clear();
                  _emailCtrl.clear();
                  _phoneCtrl.clear();
                  _passwordCtrl.clear();
                  _bioCtrl.clear();
                  setState(() => _acceptedTerms = false);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Validation')),
      body: Form(
        key: _formKey,
        // autovalidateMode: onUserInteraction = validate as user types
        // (shows errors immediately rather than only on submit)
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --------------------------------------------------
            // FULL NAME
            // --------------------------------------------------
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_emailFocus),
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Muhammad Ali',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                // Only allow letters and spaces
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                  return 'Name can only contain letters and spaces';
                }
                return null; // null = valid
              },
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // EMAIL
            // --------------------------------------------------
            TextFormField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                hintText: 'ali@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                // Simple but effective email regex
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // PHONE — with input formatter
            // --------------------------------------------------
            TextFormField(
              controller: _phoneCtrl,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              // inputFormatters restrict what the user can TYPE
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // only numbers
                LengthLimitingTextInputFormatter(11),   // max 11 chars
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number (Pakistan)',
                hintText: '03001234567',
                prefixIcon: Icon(Icons.phone_outlined),
                prefixText: '+92 ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return null; // optional
                if (value.length != 10 && value.length != 11) {
                  return 'Enter a valid Pakistani mobile number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // PASSWORD — with visibility toggle
            // --------------------------------------------------
            TextFormField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_bioFocus),
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'Include at least one uppercase letter';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'Include at least one number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // BIO — multiline TextField
            // --------------------------------------------------
            TextFormField(
              controller: _bioCtrl,
              focusNode: _bioFocus,
              maxLines: 4,
              maxLength: 200,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Bio (optional)',
                hintText: 'Tell us about yourself...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // --------------------------------------------------
            // TERMS CHECKBOX
            // --------------------------------------------------
            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) =>
                      setState(() => _acceptedTerms = value ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _acceptedTerms = !_acceptedTerms),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // SUBMIT BUTTON
            // --------------------------------------------------
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0397D6),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Register', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
