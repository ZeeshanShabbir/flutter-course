# Mobile Development with Flutter — D4WEE Course Codebase

**Instructor:** Muhammad Zeeshan Shabbir  
**Organisation:** Code for Pakistan · D4WEE Programme  
**Duration:** 3 Months (12 Weeks) | **Level:** Beginner → Job-Ready

---

## 📁 Repository Structure

This is the **single mega-repo** for the entire course. Every module and every project lives here so students can clone once and follow along without hunting for separate repos.

```
flutter-course-d4wee/
│
├── module-01-foundations/          ← Weeks 1–3
│   ├── p01-dart-crash-course/      ← Pure Dart practice scripts
│   ├── p02-flutter-fundamentals/   ← First Flutter app
│   ├── p03-navigation-and-state/   ← GoRouter + Riverpod
│   └── p04-forms-and-local-storage/← Forms + Hive/SharedPrefs
│
├── module-02-building-real-features/ ← Weeks 4–6
│   ├── p05-rest-apis-and-http/     ← Dio, JSON, Freezed
│   ├── p06-firebase-fullstack/     ← Auth, Firestore, Storage
│   ├── p07-packages-and-notifications/ ← image_picker, FCM
│   └── p08-mini-project/           ← FULL APP: Task Manager
│
├── module-03-shipping-and-ai/      ← Weeks 7–9
│   ├── p09-app-polish-and-animations/ ← Hero, Lottie, responsive
│   ├── p10-testing-and-crash-reporting/ ← Unit + widget tests
│   ├── p11-ai-dev-tools/           ← Prompt patterns, Cursor tips
│   └── p12-ai-features-in-app/     ← OpenAI API + ML Kit
│
└── module-04-capstone-and-career/  ← Weeks 10–12
    ├── p13-capstone-plan-and-build/ ← CAPSTONE APP (production)
    ├── p14-publishing-to-stores/   ← Play Store + App Store guides
    ├── p15-freelancing/            ← Upwork/Fiverr templates
    └── p16-professional-employment/ ← Resume + interview prep
```

---

## 🚀 How to Use This Repo

### Clone Once
```bash
git clone https://github.com/your-org/flutter-course-d4wee.git
cd flutter-course-d4wee
```

### Open a Project in VS Code
Each `p0X-*` folder that contains a `pubspec.yaml` is a **standalone Flutter project**. Open it directly:

```bash
code module-01-foundations/p02-flutter-fundamentals
```

### Install Dependencies
Inside any Flutter project folder:
```bash
flutter pub get
```

### Run the App
```bash
flutter run
```

---

## 📋 16-Part Curriculum at a Glance

| Module | Part | Topic | Week |
|--------|------|-------|------|
| 01 | P01 | Dart Crash Course | 1 |
| 01 | P02 | Flutter Fundamentals | 2 |
| 01 | P03 | Navigation & State | 2–3 |
| 01 | P04 | Forms & Local Storage | 3 |
| 02 | P05 | REST APIs & HTTP | 4 |
| 02 | P06 | Firebase Full-Stack | 4–5 |
| 02 | P07 | Packages & Notifications | 5 |
| 02 | P08 | Mini-Project (Full App) | 6 |
| 03 | P09 | App Polish & Animations | 7 |
| 03 | P10 | Testing & Crash Reporting | 7–8 |
| 03 | P11 | AI Dev Tools | 8 |
| 03 | P12 | AI Features in App | 9 |
| 04 | P13 | Capstone: Plan & Build | 10–11 |
| 04 | P14 | Publishing to Stores | 11 |
| 04 | P15 | Freelancing | 12 |
| 04 | P16 | Professional Employment | 12 |

---

## 🛠 Prerequisites

- Flutter SDK (stable channel) — [flutter.dev](https://flutter.dev/docs/get-started/install)
- Dart SDK (bundled with Flutter)
- VS Code + Flutter & Dart extensions
- Android Studio or Xcode (for device emulation)
- Git

---

## 📝 Notes for Students

- **Read the comments.** Every file is heavily commented to explain *why*, not just *what*.
- **Don't just copy-paste.** Type the code yourself — muscle memory matters.
- **Each part builds on the previous one.** Work through them in order.
- **Check the `README.md` inside each part** for setup instructions and learning goals.

---

*Prepared for Code for Pakistan · D4WEE Programme · 2026*
