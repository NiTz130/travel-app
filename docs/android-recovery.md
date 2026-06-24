# Android Recovery

Resolve Flutter dependencies:

```powershell
flutter pub get
```

Run static analysis:

```powershell
flutter analyze
```

Run repository tests:

```powershell
flutter test test\repositories
```

Build a debug APK:

```powershell
flutter build apk --debug
```

Run against the Firebase Emulator:

```powershell
firebase emulators:start --project travel-app-v2-dev
powershell -ExecutionPolicy Bypass -File tool\seed_firestore_emulator.ps1
flutter run -d emulator
```

For a future real Firebase project, create the Android app with package `com.example.travel_app_v2`, download `android/app/google-services.json`, run FlutterFire configuration, and replace the placeholder options in `lib/repositories/firebase_options.dart` with generated real project options.
