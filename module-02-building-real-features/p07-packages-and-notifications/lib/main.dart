// ============================================================
// P07 — Packages, Plugins & Push Notifications
// File: lib/main.dart
//
// Slide reference: "Packages, Plugins & Platform Channels"
//                + "Push Notifications & Deep Linking"
//
// This file demonstrates all essential packages from the slides:
// - image_picker    → pick photos from camera/gallery
// - geolocator      → get GPS coordinates
// - url_launcher    → open URLs, email, phone
// - share_plus      → share text/files to other apps
// - permission_handler → runtime permission requests
// - flutter_local_notifications → local scheduled alerts
// - FCM             → Firebase push notifications (see comments)
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ============================================================
// LOCAL NOTIFICATIONS SETUP
// ============================================================
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await _localNotifications.initialize(initSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initLocalNotifications();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P07 — Packages & Notifications',
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
      home: const PackagesDemoScreen(),
    );
  }
}

class PackagesDemoScreen extends StatefulWidget {
  const PackagesDemoScreen({super.key});

  @override
  State<PackagesDemoScreen> createState() => _PackagesDemoScreenState();
}

class _PackagesDemoScreenState extends State<PackagesDemoScreen> {
  File? _pickedImage;
  Position? _currentPosition;
  String _statusMessage = '';

  // ─── IMAGE PICKER ─────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85, // 0-100, lower = smaller file
      );
      if (file != null) {
        setState(() => _pickedImage = File(file.path));
        _showStatus('Image selected: ${file.name}');
      }
    } catch (e) {
      _showStatus('Error: $e');
    }
  }

  // ─── GEOLOCATOR ───────────────────────────────────────────
  Future<void> _getLocation() async {
    // 1. Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showStatus('Location services disabled. Please enable GPS.');
      return;
    }

    // 2. Check/request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showStatus('Location permission denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showStatus('Location permission permanently denied. Open app settings.');
      openAppSettings(); // from permission_handler
      return;
    }

    // 3. Get position
    setState(() => _statusMessage = 'Getting location...');
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);
      _showStatus(
        'Lat: ${position.latitude.toStringAsFixed(4)}, '
        'Lng: ${position.longitude.toStringAsFixed(4)}',
      );
    } catch (e) {
      _showStatus('Location error: $e');
    }
  }

  // ─── URL LAUNCHER ─────────────────────────────────────────
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showStatus('Cannot open: $url');
    }
  }

  Future<void> _sendEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'info@codeforpakistan.org',
      query: Uri.encodeFull(
          'subject=Flutter Course Enquiry&body=Hello,\n\nI am interested in the D4WEE Flutter course.'),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _callPhone() async {
    final phoneUri = Uri(scheme: 'tel', path: '+923001234567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  // ─── SHARE PLUS ───────────────────────────────────────────
  void _shareText() {
    Share.share(
      'Check out the D4WEE Flutter course by Code for Pakistan! 🚀\n'
      'Learn mobile development from beginner to job-ready in 3 months.\n'
      'https://codeforpakistan.org',
      subject: 'D4WEE Flutter Course',
    );
  }

  Future<void> _shareImage() async {
    if (_pickedImage == null) {
      _showStatus('Pick an image first!');
      return;
    }
    await Share.shareXFiles(
      [XFile(_pickedImage!.path)],
      text: 'Shared from D4WEE Flutter App',
    );
  }

  // ─── LOCAL NOTIFICATIONS ──────────────────────────────────
  Future<void> _showLocalNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'reminders', // channel id
      'Reminders', // channel name
      channelDescription: 'Study reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
        android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      0, // notification ID
      'Study Reminder 📚',
      'Time to practice Flutter! Complete today\'s exercises.',
      details,
    );
    _showStatus('Local notification sent!');
  }

  Future<void> _scheduleNotification() async {
    // Schedule a notification 5 seconds from now
    // Full scheduling uses TZDateTime from timezone package
    _showStatus('Scheduled for 5 seconds from now (see flutter_local_notifications docs for TZDateTime)');
    Future.delayed(const Duration(seconds: 5), _showLocalNotification);
  }

  // ─── PERMISSION HANDLER ───────────────────────────────────
  Future<void> _checkAllPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.location,
      Permission.notification,
      Permission.storage,
    ].request();

    final denied = statuses.entries
        .where((e) => e.value.isDenied)
        .map((e) => e.key.toString())
        .join(', ');

    if (denied.isEmpty) {
      _showStatus('All permissions granted ✓');
    } else {
      _showStatus('Denied: $denied');
    }
  }

  void _showStatus(String message) {
    setState(() => _statusMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P07 — Packages & Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── STATUS ────────────────────────────────────────
          if (_statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0397D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_statusMessage,
                  style: const TextStyle(fontSize: 13)),
            ),

          // ── IMAGE PICKER ──────────────────────────────────
          _PackageCard(
            title: 'image_picker',
            subtitle: 'Access camera and photo gallery',
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFF0397D6),
            child: Column(
              children: [
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _pickedImage!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (_pickedImage != null) const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_outlined),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── GEOLOCATOR ────────────────────────────────────
          _PackageCard(
            title: 'geolocator',
            subtitle: 'Get device GPS coordinates',
            icon: Icons.location_on_outlined,
            color: const Color(0xFF6CB33E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_currentPosition != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6CB33E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '📍 ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                      '${_currentPosition!.longitude.toStringAsFixed(6)}\n'
                      'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _getLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Get Current Location'),
                ),
              ],
            ),
          ),

          // ── URL LAUNCHER ──────────────────────────────────
          _PackageCard(
            title: 'url_launcher',
            subtitle: 'Open URLs, email, phone',
            icon: Icons.open_in_new,
            color: const Color(0xFF544DCF),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _launchUrl('https://flutter.dev'),
                  icon: const Icon(Icons.language, size: 16),
                  label: const Text('Open URL'),
                ),
                OutlinedButton.icon(
                  onPressed: _sendEmail,
                  icon: const Icon(Icons.email_outlined, size: 16),
                  label: const Text('Email'),
                ),
                OutlinedButton.icon(
                  onPressed: _callPhone,
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Phone'),
                ),
              ],
            ),
          ),

          // ── SHARE PLUS ────────────────────────────────────
          _PackageCard(
            title: 'share_plus',
            subtitle: 'Share content to other apps',
            icon: Icons.share_outlined,
            color: const Color(0xFFDDB307),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareText,
                    icon: const Icon(Icons.text_fields, size: 16),
                    label: const Text('Share Text'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareImage,
                    icon: const Icon(Icons.image_outlined, size: 16),
                    label: const Text('Share Image'),
                  ),
                ),
              ],
            ),
          ),

          // ── LOCAL NOTIFICATIONS ───────────────────────────
          _PackageCard(
            title: 'flutter_local_notifications',
            subtitle: 'Show notifications without server',
            icon: Icons.notifications_outlined,
            color: const Color(0xFFD31145),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showLocalNotification,
                    icon: const Icon(Icons.notifications_active_outlined, size: 16),
                    label: const Text('Show Now'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scheduleNotification,
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Schedule'),
                  ),
                ),
              ],
            ),
          ),

          // ── PERMISSIONS ───────────────────────────────────
          _PackageCard(
            title: 'permission_handler',
            subtitle: 'Request runtime permissions',
            icon: Icons.security_outlined,
            color: const Color(0xFF897966),
            child: OutlinedButton.icon(
              onPressed: _checkAllPermissions,
              icon: const Icon(Icons.checklist, size: 16),
              label: const Text('Request All Permissions'),
            ),
          ),

          // ── FCM SETUP GUIDE ───────────────────────────────
          const _FcmGuide(),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;

  const _PackageCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
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
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FcmGuide extends StatelessWidget {
  const _FcmGuide();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1D1D1F),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_outlined, color: Color(0xFF0397D6)),
                SizedBox(width: 8),
                Text(
                  'FCM Push Notifications Setup',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '// 1. Request permission\n'
              'await FirebaseMessaging.instance\n'
              '  .requestPermission();\n\n'
              '// 2. Get device token (send to server)\n'
              'final token = await FirebaseMessaging\n'
              '  .instance.getToken();\n\n'
              '// 3. Handle foreground messages\n'
              'FirebaseMessaging.onMessage.listen((msg) {\n'
              '  _localNotifications.show(\n'
              '    0, msg.notification?.title,\n'
              '    msg.notification?.body, details);\n'
              '});\n\n'
              '// 4. Handle background tap\n'
              'FirebaseMessaging.onMessageOpenedApp\n'
              '  .listen((msg) => context.go(\'/tasks\'));',
              style: TextStyle(
                color: Color(0xFFE5E5E5),
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
