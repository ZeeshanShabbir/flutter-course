# P14 — Publishing to Stores

**Module 04 · Part 14 · Week 11**

> "From your laptop to a billion Android and iOS devices."

This part is a **guide and checklist** — no runnable Flutter app code.  
Follow these steps when you are ready to ship your capstone or any production app.

---

## 📋 Pre-Launch Checklist

### App Quality
- [ ] App name and icon finalised (use `flutter_launcher_icons` package)
- [ ] Splash screen configured (`flutter_native_splash` package)
- [ ] All placeholder text removed (no "Lorem ipsum", no "TODO")
- [ ] No hardcoded test credentials in source code
- [ ] Error handling on every async operation
- [ ] All screens work on small phones (360×640 minimum)
- [ ] Dark mode tested on both platforms
- [ ] Back navigation works correctly everywhere
- [ ] Deep links tested
- [ ] Analytics events firing correctly
- [ ] Crashlytics enabled and tested

### Performance
- [ ] Profile mode tested (`flutter run --profile`)
- [ ] No jank on list scrolling (60fps target)
- [ ] Images lazy-loaded with placeholder
- [ ] App size checked: `flutter build apk --analyze-size`

---

## 🤖 Android — Google Play Store

### 1. Prepare a Signing Key
```bash
keytool -genkey -v \
  -keystore ~/your-app-key.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias your-key-alias
```

⚠️ **Back this keystore file up.** If you lose it, you can never update your app.

### 2. Configure Signing in Android
Create `android/key.properties` (already in `.gitignore`):
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your-key-alias
storeFile=/Users/yourname/your-app-key.jks
```

Update `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 3. Build the App Bundle (AAB)
```bash
# Always use AAB for Play Store (smaller download size for users)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### 4. Upload to Play Console
1. Go to [play.google.com/console](https://play.google.com/console)
2. Create app → Fill in all required fields
3. Go to **Release → Production → Create new release**
4. Upload the `.aab` file
5. Write release notes in English + Urdu
6. Set content rating (fill the questionnaire)
7. Set pricing (Free or Paid)
8. Submit for review (~3–7 days for first release)

### 5. ASO (App Store Optimisation)
- **Title**: Include your main keyword (e.g. "Task Manager — D4WEE")
- **Short description**: 80 chars, include 2–3 keywords naturally
- **Long description**: First 3 lines matter most — explain value immediately
- **Screenshots**: Show the app in action, not empty screens
- **Feature graphic**: 1024×500px, looks good at small sizes

---

## 🍎 iOS — Apple App Store

### Requirements
- macOS computer (mandatory — cannot build iOS on Windows/Linux)
- Apple Developer Account ($99/year at developer.apple.com)
- Xcode (latest stable version)

### 1. Configure Bundle ID
In Xcode: `ios/Runner.xcworkspace` → Runner → Signing & Capabilities
- Bundle Identifier: `com.yourcompany.appname`
- Team: select your Apple Developer account
- Check "Automatically manage signing"

### 2. Configure App Icons
```bash
flutter pub add dev:flutter_launcher_icons
# Configure in pubspec.yaml, then:
dart run flutter_launcher_icons
```

### 3. Build for Release
```bash
flutter build ios --release
# Then in Xcode: Product → Archive → Distribute App
```

### 4. TestFlight — Beta Testing
1. Upload archive to App Store Connect
2. Go to TestFlight → Add external testers (email addresses)
3. Wait for beta review (~24 hours)
4. Testers get an email to install via TestFlight app
5. Collect feedback before public release

### 5. Submit to App Store
1. App Store Connect → My Apps → + → New App
2. Fill in metadata (name, description, keywords, screenshots)
3. Select the build from TestFlight
4. Submit for review (~1–3 days)

---

## 🔁 CI/CD — Automated Builds

For production apps, automate the build process.

### GitHub Actions (free for public repos)
Create `.github/workflows/build.yml`:
```yaml
name: Build & Deploy

on:
  push:
    branches: [ main ]

jobs:
  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Build AAB
        run: flutter build appbundle --release
        env:
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.yourcompany.appname
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal  # start with internal testing
```

### Codemagic (easiest for Flutter)
1. Connect your GitHub repo to [codemagic.io](https://codemagic.io)
2. Configure signing credentials in the dashboard (no YAML needed)
3. Push to main → automatic build + upload to stores
4. Free tier: 500 build minutes/month

---

## 📦 Version Management

Update `pubspec.yaml` for every release:
```yaml
version: 1.2.0+5
#         ↑   ↑
#    semver   build number (must increment for every Play Store upload)
```

Follow semantic versioning:
- `1.0.0` → Initial release
- `1.0.1` → Bug fix
- `1.1.0` → New feature (backward compatible)
- `2.0.0` → Breaking change or major redesign

---

## 📚 Resources

- [Flutter deployment docs](https://docs.flutter.dev/deployment)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Codemagic CI/CD](https://codemagic.io/start/)
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)
