# P16 — Professional Employment as a Flutter Developer

**Module 04 · Part 16 · Week 12**

> "Your GitHub profile is your first interview. Your portfolio is your portfolio."

This part covers landing a full-time or contract Flutter role.

---

## 📄 Resume Template for Flutter Developers

```
MUHAMMAD ALI
Islamabad, Pakistan · ali@gmail.com · +92-300-1234567
github.com/m-ali-dev · linkedin.com/in/m-ali-dev

─────────────────────────────────────────────────────────

SUMMARY
Flutter developer with 1 year of hands-on experience building
production Android and iOS applications. Completed the D4WEE
Mobile Development programme (Code for Pakistan). Proficient in
Dart, Firebase, and Riverpod. Seeking a Flutter developer role
where I can contribute to real products from day one.

─────────────────────────────────────────────────────────

SKILLS
Mobile:    Flutter 3, Dart 3, Dart null safety
State:     Riverpod, Provider, BLoC
Backend:   Firebase (Auth, Firestore, Storage, FCM), REST APIs (Dio)
Storage:   Hive, SharedPreferences, SQLite
Testing:   flutter_test, mockito, widget tests, integration tests
Tools:     Git, VS Code, Android Studio, Figma (read designs)
CI/CD:     GitHub Actions, Codemagic
Platforms: Android, iOS (basic)

─────────────────────────────────────────────────────────

PROJECTS

Task Manager App (github.com/m-ali-dev/task-manager)
• Full-stack Flutter app with Firebase Auth + Firestore real-time CRUD
• Riverpod state management, GoRouter auth guard, Hive offline cache
• FCM push notifications, dark mode, responsive layout
• 85% test coverage (unit + widget + integration)
• Tech: Flutter 3, Firebase, Riverpod, GoRouter, Hive, Dio

Weather App (github.com/m-ali-dev/flutter-weather)
• REST API integration (OpenWeatherMap), clean architecture
• Location-based weather using Geolocator
• Animated weather icons, 7-day forecast, search by city
• Tech: Flutter 3, Dio, Riverpod, Geolocator

[Your capstone or other apps here]

─────────────────────────────────────────────────────────

EDUCATION

D4WEE Mobile Development with Flutter
Code for Pakistan · 2026 · Islamabad
• 12-week intensive programme, 16 parts
• Built 4 full Flutter apps from scratch

B.Sc. Computer Science (or relevant degree)
[Your University] · [Year]

─────────────────────────────────────────────────────────

CERTIFICATIONS
• Google Flutter Development Certificate (if applicable)
• Firebase Certified (if applicable)

─────────────────────────────────────────────────────────

LANGUAGES
Urdu (Native), English (Professional)
```

---

## 🎯 Interview Preparation

### Flutter Technical Questions

**Fundamentals:**
- What is the difference between StatelessWidget and StatefulWidget?
- Explain the Flutter widget lifecycle (initState, build, dispose).
- What is the difference between `const` and `final` in Dart?
- What are keys in Flutter and when do you use them?
- How does Flutter's rendering pipeline work? (widget tree → element tree → render tree)

**State Management:**
- What is the difference between `ref.watch()` and `ref.read()` in Riverpod?
- When would you use StateProvider vs AsyncNotifier?
- What is reactive state management? Why is it better than calling setState everywhere?

**Architecture:**
- Explain feature-first vs layer-first folder structure.
- What is the repository pattern and why is it useful?
- How do you handle errors in async code with Riverpod?

**Navigation:**
- How does GoRouter's `redirect` work for auth protection?
- What is the difference between `context.go()` and `context.push()`?

**Testing:**
- What is the difference between unit tests and widget tests?
- How do you mock a repository in widget tests?

**Performance:**
- How do you identify and fix unnecessary widget rebuilds?
- When should you use `const` constructors? Why?
- What is the difference between `ListView` and `ListView.builder`?

---

### STAR Method for Behavioural Questions

**"Tell me about a challenge you faced and how you resolved it."**

Use STAR:
- **S**ituation: "While building the Task Manager capstone..."
- **T**ask: "I needed to implement real-time Firestore sync with offline support."
- **A**ction: "I used Hive for local caching + Firestore streams for real-time updates. When offline, the app reads from Hive."
- **R**esult: "The app works fully offline and syncs automatically when connectivity returns."

---

### Code Exercises to Practice

```dart
// Common interview: implement a debounced search
// Expected: student knows Future.delayed + cancelable timers

class SearchBloc {
  Timer? _debounce;
  
  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query);
    });
  }
  
  Future<void> _search(String query) async {
    // call API
  }
  
  void dispose() {
    _debounce?.cancel();
  }
}
```

```dart
// Common: explain why this causes infinite rebuilds
// and how to fix it

// ❌ WRONG
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    // This creates a NEW object on every build — Riverpod sees
    // it as a different provider and triggers another rebuild
    final result = ref.watch(myProvider(MyClass())); // ← bug
  }
}

// ✅ CORRECT — pass primitive or cache the object
class MyWidget extends ConsumerWidget {
  final String id; // pass primitive
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(myProvider(id)); // stable
  }
}
```

---

## 📍 Where to Apply

### Pakistani Companies Hiring Flutter Developers
- **10Pearls** (Karachi/Islamabad) — Enterprise Flutter apps
- **Systems Limited** (Lahore) — Banking and fintech apps
- **Tkxel** (Lahore) — US clients, Flutter + Firebase
- **Softech** (Islamabad) — Mobile-first startups
- **AdalFi** (Lahore) — Fintech, strong mobile team
- **Careem / Bykea** (Karachi) — Super-app style Flutter

### Remote / International
- LinkedIn Jobs → Filter: "Flutter Developer" + "Remote"
- We Work Remotely (weworkremotely.com)
- Remote.co
- AngelList → startup Flutter roles
- Upwork → build client base → convert to full-time

---

## 📧 Cold Email Template

```
Subject: Flutter Developer — [1 key result from your portfolio]

Hi [Name],

I'm a Flutter developer based in Islamabad, completing the D4WEE 
programme at Code for Pakistan.

I noticed [Company] recently [launched/announced/is hiring for] 
Flutter work. I built a [task manager / e-commerce / [your app]] 
app with [Firebase / Riverpod / GoRouter] that handles [X users / 
offline-first / real-time updates].

GitHub: github.com/[you]
App demo video: [Loom link or YouTube]

Happy to share the full source code if you'd like to review my 
coding style before a call.

Would 15 minutes this week or next work?

Best,
[Your name]
```

---

## 💡 Salary Negotiation

**Know your numbers before the interview:**
- Junior Flutter Developer (Pakistan, on-site): PKR 80,000–150,000/mo
- Mid-level (Pakistan, on-site): PKR 150,000–300,000/mo
- Senior (Pakistan, remote for international): $2,000–$5,000/mo

**Script for counter-offer:**
> "Thank you for the offer. Based on my research and the skills I bring — 
> specifically [Firebase architecture, state management, full test coverage] — 
> I was expecting something in the range of [PKR X]. Is there flexibility there?"

**Always negotiate.** The first offer is almost never the best offer.

---

## 📚 Resources

- [Flutter Roadmap](https://roadmap.sh/flutter)
- [Dart Pub — top Flutter packages](https://pub.dev/flutter/packages)
- [Flutter Dev Community (Discord)](https://discord.gg/N7Yshp4)
- [Pakistani Flutter Community (Facebook)](https://www.facebook.com/groups/flutterpakistan)
- [Code for Pakistan](https://codeforpakistan.org) — Stay connected!
