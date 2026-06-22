// ============================================================
// P06 — Firebase Full-Stack
// File: lib/main.dart
//
// Slide reference: "Firebase — Firestore, Auth & Cloud Functions"
// Key quote: "Setting up a Firebase project with FlutterFire CLI"
//
// ⚠️ SETUP REQUIRED — See README.md before running.
//
// This file shows the COMPLETE Firebase integration pattern.
// All Firebase calls are commented with explanations so students
// can follow along step by step during the video.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Uncomment after flutterfire configure:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ----------------------------------------------------------
  // STEP 1: Initialise Firebase
  // This must be the very first thing after ensureInitialized.
  // ----------------------------------------------------------
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // from firebase_options.dart
  // );

  // ----------------------------------------------------------
  // STEP 2: Setup Crashlytics
  // Catches Flutter errors AND native platform errors.
  // ----------------------------------------------------------
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P06 — Firebase Full-Stack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0397D6)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0397D6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const FirebaseDemoScreen(),
    );
  }
}

class FirebaseDemoScreen extends StatelessWidget {
  const FirebaseDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P06 — Firebase Full-Stack')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SetupBanner(),
          const SizedBox(height: 20),
          _Section(
            title: 'Firebase Auth',
            icon: Icons.lock_outline,
            color: const Color(0xFF0397D6),
            items: const [
              'Email & Password sign up / sign in',
              'Google Sign-In (OAuth 2.0)',
              'Phone OTP verification',
              'Password reset via email',
              'Auth state stream → GoRouter redirect',
            ],
          ),
          _Section(
            title: 'Cloud Firestore',
            icon: Icons.storage_outlined,
            color: const Color(0xFF544DCF),
            items: const [
              'Collection: users/{uid}/tasks/{taskId}',
              'CRUD: add, set, update, delete',
              'Real-time listener: StreamBuilder',
              'Queries: where, orderBy, limit',
              'Pagination: startAfter (cursor-based)',
              'Batch writes & transactions',
            ],
          ),
          _Section(
            title: 'Firebase Storage',
            icon: Icons.cloud_upload_outlined,
            color: const Color(0xFF6CB33E),
            items: const [
              'Upload profile photo (image_picker)',
              'Upload with progress indicator',
              'Download URL → show in Image.network()',
              'Delete old photo on update',
            ],
          ),
          _Section(
            title: 'Security Rules',
            icon: Icons.security_outlined,
            color: const Color(0xFFDDB307),
            items: const [
              'Only authenticated users can read/write',
              'Users can only access their own data',
              'Validate data shape on write',
              'Rate limiting rules',
            ],
          ),
          const SizedBox(height: 24),
          const _CodeSnippets(),
        ],
      ),
    );
  }
}

class _SetupBanner extends StatelessWidget {
  const _SetupBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDDB307).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDB307).withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFDDB307)),
              SizedBox(width: 8),
              Text(
                'Setup Required',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFDDB307)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '1. Create project at console.firebase.google.com\n'
            '2. dart pub global activate flutterfire_cli\n'
            '3. flutterfire configure\n'
            '4. Enable Auth methods in Firebase console\n'
            '5. Create Firestore database\n'
            '6. Uncomment Firebase code in main.dart',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CodeSnippets extends StatelessWidget {
  const _CodeSnippets();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Code Patterns',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _CodeCard(
          title: 'Firestore CRUD',
          code: '''
// CREATE
await FirebaseFirestore.instance
  .collection('users')
  .doc(uid)
  .collection('tasks')
  .add(task.toJson());

// READ — one time
final doc = await _tasksRef.doc(id).get();
final task = Task.fromJson(doc.data()!);

// REAL-TIME LISTENER — stream
Stream<List<Task>> tasksStream() {
  return _tasksRef
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snap) => snap.docs
      .map((d) => Task.fromJson({...d.data(), 'id': d.id}))
      .toList());
}

// UPDATE
await _tasksRef.doc(id).update({'isCompleted': true});

// DELETE
await _tasksRef.doc(id).delete();''',
        ),
        const SizedBox(height: 12),
        _CodeCard(
          title: 'Security Rules',
          code: '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own tasks
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null
        && request.auth.uid == userId;
      
      // Validate data shape on create
      allow create: if request.resource.data.keys()
        .hasAll(['title', 'createdAt', 'isCompleted'])
        && request.resource.data.title is string
        && request.resource.data.title.size() > 0;
    }
  }
}''',
        ),
        const SizedBox(height: 12),
        _CodeCard(
          title: 'Storage Upload with Progress',
          code: '''
Future<String> uploadProfilePhoto(File file, String uid) async {
  final ref = FirebaseStorage.instance
    .ref()
    .child('users/\$uid/profile.jpg');
  
  // Upload with progress tracking
  final task = ref.putFile(file);
  
  task.snapshotEvents.listen((snapshot) {
    final progress = snapshot.bytesTransferred / snapshot.totalBytes;
    // Update progress indicator in UI
    setState(() => _uploadProgress = progress);
  });
  
  await task;
  return await ref.getDownloadURL();
}''',
        ),
      ],
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String title;
  final String code;

  const _CodeCard({required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1D1D1F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0397D6),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                color: Color(0xFFE5E5E5),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
