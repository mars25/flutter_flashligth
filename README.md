# Flashlight App — Flutter Training Project

A simple yet functional Flutter application that controls the device's flashlight (torch light). This project demonstrates Flutter fundamentals, state management with `StatefulWidget`, native plugin integration, and the full Android release build and publication process.

## Features

- ✨ Toggle flashlight on/off with a tap.
- 🎨 Dynamic UI that changes based on flashlight state (background color, app bar color, icon).
- 🛡️ Error handling and user feedback via `SnackBar`.
- 📱 Tested on Samsung Galaxy A34 (Android 15, API 35).
- 🔐 Signed APK/AAB ready for Google Play Store publication.

## Project Structure

```
lib/
  main.dart                 # Main app entry point with TrainingApp (StatefulWidget)
test/
  widget_test.dart          # Widget tests for counter UI
android/
  app/build.gradle.kts      # Gradle config with signing setup
  key.properties            # (IGNORED) Local signing credentials
pubspec.yaml               # Dependencies: torch_light, flutter, etc.
```

## Prerequisites

- **Flutter SDK:** 3.10.1+ (verify with `flutter --version`)
- **Android SDK:** API 34+, build-tools 28.0.3+
- **Java Development Kit (JDK):** 17+ (keytool for signing)
- **Device/Emulator:** Android device with USB debugging enabled or Android emulator

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/mars25/flutter_flashligth.git
cd flutter_flashligth
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run on Connected Device
Before running, connect your Android device via USB and enable USB debugging:

```bash
flutter devices  # List available devices
flutter run      # Run on first device found
```

Or explicitly run on a specific device:
```bash
flutter run -d <device-id>
```

### 4. Run Tests
```bash
flutter test
```

## Building for Production

### Prerequisites for Signing

1. **Create a Keystore** (if not already created):
   ```powershell
   keytool -genkeypair -v -keystore flashlight.jks `
     -storepass YourStrongPassword123! `
     -keypass YourStrongPassword123! `
     -alias flashlight -keyalg RSA -keysize 2048 `
     -validity 10000 `
     -dname "CN=YourName, OU=Dev, O=YourCompany, L=City, S=State, C=MX"
   ```

2. **Create `android/key.properties`** (NOT committed to git):
   ```properties
   storePassword=YourStrongPassword123!
   keyPassword=YourStrongPassword123!
   keyAlias=flashlight
   storeFile=C:/Users/YourUser/keystore/flashlight.jks
   ```

3. **Verify** `android/app/build.gradle.kts` has signing config (already included in this project).

### Build APK (Release)
```bash
flutter build apk --release
```

Output: `build/app/outputs/apk/release/app-release.apk`

### Build App Bundle (AAB) — for Google Play Store
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab` (36.5 MB)

## Publishing to Google Play Store

### Step 1: Create Google Play Developer Account
- Visit https://play.google.com/console/
- Sign in with your Google Account
- Pay the one-time developer fee (USD 25)
- Complete your developer profile

### Step 2: Create New App
1. Go to "All apps" → "Create app"
2. Fill in:
   - **App name:** Flashlight
   - **Default language:** English
   - **App or game:** App
   - **Paid or free:** Free
3. Accept terms and create app

### Step 3: Complete Store Listing
In Play Console → "Main store listing":

- **Title (up to 50 chars):** Flashlight - Control Your Device Torch
- **Short description (80 chars):** Turn your device's flashlight on and off with a single tap.
- **Full description (up to 4,000 chars):**
  ```
  A simple, fast flashlight app that lets you instantly control your device's torch light.
  
  Features:
  - One-tap flashlight toggle
  - Dynamic UI with visual feedback
  - Error handling for devices without flashlight support
  
  Permissions: Camera (required for flashlight access on Android)
  ```

- **App icon:** 512×512 PNG
- **Feature graphic:** 1024×500 PNG/JPG
- **Screenshots (Phone):** At least 2 screenshots, 1080×1920px recommended
  - Screenshot 1: Flashlight OFF state (black background)
  - Screenshot 2: Flashlight ON state (white background)

- **Category:** Tools / Utilities
- **Contact email:** your-email@example.com
- **Privacy policy URL:** (required if using camera permission)
  - Example: `https://github.com/mars25/flutter_flashligth/blob/main/PRIVACY_POLICY.md`

### Step 4: Complete Data Safety Form
1. Navigate to "App content" → "Data safety"
2. Answer questions about data collection:
   - You're using **Camera permission** for flashlight control (not for recording)
   - No personal data is collected
   - Data is not shared with third parties
3. Submit form

### Step 5: Upload AAB and Review
1. Go to "Release" → "Production" (or "Testing" for internal testing first)
2. Click "Create new release"
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Add release notes:
   ```
   Version 1.0.0
   - Initial release
   - Flashlight control functionality
   - Error handling and user feedback
   ```
5. Review and submit for publication

### Step 6: Wait for Review
- Google reviews your app (typically 1–2 hours for initial review)
- Check Play Console for any policy violations or feedback
- Once approved, app appears on Google Play Store

## Troubleshooting

### "Flashlight not available" error on device
- Device doesn't have a flashlight or camera
- Camera permission not granted (check app settings)
- Device is in developer mode with restricted permissions

**Solution:** Grant Camera permission in device settings or check with `flutter logs`

### Build fails with signing error
- Verify `android/key.properties` exists and paths are correct
- Check keystore password matches in `key.properties`
- Ensure keystore file is accessible

### AAB upload fails to Play Console
- AAB file may be corrupted; rebuild with `flutter build appbundle --release`
- Ensure app version in `pubspec.yaml` is higher than previous release
- Check app signing configuration in Play Console settings

## Dependencies

- **flutter:** SDK framework
- **torch_light:** ^1.1.0 — for flashlight control
- **cupertino_icons:** ^1.0.8 — iOS-style icons (standard)

## Security Notes

- **Keystore:** Store `flashlight.jks` and `key.properties` in a **secure, offline location**
- **Git:** These files are in `.gitignore` and should never be committed
- **Password:** Save keystore password in a password manager; losing it means you cannot update the app on Play Store

## License

This project is provided as-is for educational and personal use.

## Contact

- GitHub: [@mars25](https://github.com/mars25)
- Repository: [flutter_flashligth](https://github.com/mars25/flutter_flashligth)

---

**Happy coding! 🚀**
