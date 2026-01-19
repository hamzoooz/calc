# Calculator Pro

A professional, modern Calculator Application built with Flutter that works seamlessly on Android, iOS, and Web.

## Features

### Core Calculator
- **Basic Operations**: Addition, subtraction, multiplication, division
- **Advanced Operations**: Square root, power, percentage, modulo
- **Scientific Functions**: sin, cos, tan, log, ln, factorial
- **Brackets Support**: Full support with correct BODMAS order of operations
- **Real-time Preview**: See calculation results as you type
- **Calculation History**: Save and reuse past calculations

### User Experience
- **Modern UI**: Clean, minimal design with glassmorphism effects
- **Dark & Light Mode**: Automatic system detection or manual toggle
- **Responsive Layout**: Optimized for phones, tablets, and web
- **Smooth Animations**: Fluid button press and transition animations
- **Haptic Feedback**: Optional vibration on button press

### Additional Features
- **Multi-language Support**: English and Arabic (RTL)
- **Favorite Calculations**: Save important calculations
- **Copy/Share Results**: Easily share calculation results
- **Offline Support**: Works without internet connection
- **PWA Support**: Install as an app on any device

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Architecture**: Clean Architecture with MVVM pattern
- **Language**: Dart with strong typing
- **Persistence**: SharedPreferences

## Project Structure

```
lib/
├── app.dart                    # Main app widget
├── main.dart                   # Entry point
├── core/
│   ├── constants/
│   │   ├── app_colors.dart     # Color definitions
│   │   └── app_strings.dart    # String constants
│   ├── services/
│   │   └── calculation_engine.dart  # Math engine
│   └── theme/
│       └── app_theme.dart      # Theme configuration
├── data/
│   └── models/
│       └── history_item.dart   # History data model
├── l10n/
│   └── app_localizations.dart  # Localization
├── providers/
│   ├── calculator_provider.dart # Calculator state
│   └── settings_provider.dart   # Settings state
└── ui/
    ├── screens/
    │   ├── home_screen.dart
    │   ├── history_screen.dart
    │   └── settings_screen.dart
    └── widgets/
        ├── calculator_button.dart
        ├── display_panel.dart
        ├── standard_keypad.dart
        └── scientific_keypad.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK 3.2.0 or higher
- Android Studio / VS Code
- For Android: Android SDK
- For iOS: Xcode (macOS only)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd calc
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Building for Production

### Android APK

```bash
# Build release APK
flutter build apk --release

# Build split APKs by ABI (smaller size)
flutter build apk --split-per-abi --release

# Output location: build/app/outputs/flutter-apk/
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release

# Output location: build/app/outputs/bundle/release/
```

### iOS

```bash
flutter build ios --release

# Then open in Xcode and archive
open ios/Runner.xcworkspace
```

### Web

```bash
# Build web app
flutter build web --release

# With PWA support (default)
flutter build web --release --web-renderer html

# Output location: build/web/
```

### Web (with base href for subdirectory hosting)

```bash
flutter build web --base-href /calculator/
```

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/calculation_engine_test.dart
```

## Configuration

### App ID (Android)
Edit `android/app/build.gradle.kts`:
```kotlin
applicationId = "com.yourcompany.calculator"
```

### App Name
- Android: `android/app/src/main/AndroidManifest.xml` - `android:label`
- iOS: `ios/Runner/Info.plist` - `CFBundleDisplayName`
- Web: `web/manifest.json` - `name` and `short_name`

### Signing for Release (Android)

1. Generate a keystore:
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=key
storeFile=<path-to-key.jks>
```

3. Update `android/app/build.gradle.kts` to use the keystore.

## Deployment

### Google Play Store
1. Build the app bundle: `flutter build appbundle`
2. Create a release in Google Play Console
3. Upload the `.aab` file
4. Fill in store listing details
5. Submit for review

### Apple App Store
1. Build for iOS: `flutter build ios`
2. Open in Xcode and configure signing
3. Archive and upload to App Store Connect
4. Configure app details and submit for review

### Web Deployment
1. Build: `flutter build web`
2. Deploy `build/web/` to any static hosting:
   - Firebase Hosting
   - Netlify
   - Vercel
   - GitHub Pages
   - AWS S3 + CloudFront

## Privacy

- No ads
- No unnecessary permissions
- No data collection
- All calculations performed locally
- History stored only on device

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
