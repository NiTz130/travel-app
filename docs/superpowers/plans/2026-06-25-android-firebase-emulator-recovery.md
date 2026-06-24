# Android Firebase Emulator Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconstruct the current `lib/`-only Flutter travel app into an Android debug project that builds, runs against Firebase Emulator, and avoids the known critical runtime crashes.

**Architecture:** Restore Flutter/Android scaffold first, then add emulator wiring and generated local assets so the app can start. After the platform is stable, fix the data-layer blockers with focused repository changes and small tests around auth state, Firestore empty results, review persistence, and directions fallback behavior.

**Tech Stack:** Flutter 3.32.7, Dart 3.8.1, Android Gradle Kotlin DSL, Firebase Auth/Firestore/Realtime Database Emulator, flutter_bloc, GetX, shared_preferences, PowerShell asset generation.

---

## File Structure

- `pubspec.yaml`: Flutter package metadata, dependencies, dev dependencies, and asset registration.
- `analysis_options.yaml`: moderate analyzer rules that keep compile blockers visible without making legacy naming a blocker.
- `android/`: Flutter-generated Android host project with package/application id `com.example.travel_app_v2`.
- `lib/main.dart`: Firebase initialization, dotenv loading, emulator connection, and app startup.
- `lib/repositories/firebase_options.dart`: dev-only Firebase options for project id `travel-app-v2-dev`.
- `lib/repositories/firebase_emulator.dart`: debug-only Firebase Emulator host and connection helper.
- `lib/network_controller.dart`: compatibility update for current `connectivity_plus` API.
- `lib/repositories/trips/trip_repo.dart`: current-user lookup at call time and injectable Firestore/Auth for tests.
- `lib/repositories/city/city_repo.dart`: injectable Firestore/Auth and safe empty-query behavior.
- `lib/repositories/attractions/attractionList_repo.dart`: safe detail lookup, named review methods, review/userIds updates.
- `lib/repositories/restaurants/restaurants_repo.dart`: safe detail lookup and unified parent-field plus subcollection review persistence.
- `lib/blocs/place/placeList_bloc.dart`: call named review methods so argument order cannot regress.
- `lib/repositories/directions/directions_repo.dart`: safe fallback for missing location/API key/empty routes.
- `lib/repositories/user/userAuth_repo.dart`: debug-safe Google Sign-In behavior.
- `lib/ui/Welcomepage.dart`: disable Google Sign-In action in debug emulator flow and use generated social icon paths.
- `tool/generate_recovery_assets.ps1`: deterministic local asset generator using simple project-owned shapes.
- `tool/seed_firestore_emulator.ps1`: deterministic Firestore Emulator seed data script.
- `assets/images/`: generated local images and lottie JSON used by the existing UI.
- `assets/ATTRIBUTION.md`: asset source/license statement.
- `firebase.json`: Firebase Emulator service and port configuration.
- `docs/firebase-emulator.md`: local emulator runbook.
- `docs/android-recovery.md`: Android build/run recovery runbook.
- `test/repositories/firebase_emulator_test.dart`: host-selection tests.
- `test/repositories/trip_repo_test.dart`: current-user and trip write tests.
- `test/repositories/place_repos_test.dart`: empty detail and review persistence tests.
- `test/repositories/directions_repo_test.dart`: missing local state fallback test.

---

### Task 1: Recreate Flutter Android Scaffold And Dependencies

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `android/`
- Modify: `.gitignore`

- [ ] **Step 1: Snapshot current source before scaffold generation**

Run:

```powershell
$backup = Join-Path $env:TEMP ("travel_app_lib_backup_" + (Get-Date -Format "yyyyMMddHHmmss"))
Copy-Item -Recurse -LiteralPath lib -Destination $backup
Write-Output $backup
```

Expected: command prints one temp path ending with `travel_app_lib_backup_<timestamp>`.

- [ ] **Step 2: Generate Android scaffold**

Run:

```powershell
flutter create --platforms=android --project-name=travel_app --org=com.example .
```

Expected: command creates `pubspec.yaml`, `analysis_options.yaml`, and `android/app/build.gradle.kts`.

- [ ] **Step 3: Restore current `lib/` from the snapshot**

Run:

```powershell
Copy-Item -Recurse -Force -Path (Join-Path $backup "*") -Destination lib
git diff -- lib/main.dart
```

Expected: `git diff -- lib/main.dart` does not show the Flutter counter template.

- [ ] **Step 4: Add runtime dependencies**

Run:

```powershell
flutter pub add firebase_core firebase_auth cloud_firestore firebase_database flutter_bloc get google_fonts loading_animation_widget flutter_rating_bar syncfusion_flutter_maps colorful_safe_area flutter_keyboard_visibility lottie location geocoding image_picker http flutter_dotenv shared_preferences connectivity_plus intl uuid
```

Expected: `pubspec.yaml` contains each package under `dependencies`.

- [ ] **Step 5: Add test-only dependencies**

Run:

```powershell
flutter pub add --dev fake_cloud_firestore firebase_auth_mocks
```

Expected: `pubspec.yaml` contains `fake_cloud_firestore` and `firebase_auth_mocks` under `dev_dependencies`.

- [ ] **Step 6: Register assets in `pubspec.yaml`**

Add this under the existing `flutter:` section:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

Then run:

```powershell
flutter pub get
```

Expected: dependency resolution finishes with exit code `0`.

- [ ] **Step 7: Update `.gitignore` for restored Flutter/Android workflow**

Ensure `.gitignore` contains these entries:

```gitignore
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
android/.gradle/
android/local.properties
android/app/google-services.json
.env
firebase-emulator-data/
.idea/
```

- [ ] **Step 8: Commit scaffold and dependency baseline**

Run:

```powershell
git add .gitignore pubspec.yaml pubspec.lock analysis_options.yaml android
git commit -m "chore: restore Flutter Android scaffold"
```

Expected: commit succeeds and includes scaffold/dependency files.

---

### Task 2: Set Android Package Name

**Files:**
- Modify: `android/app/build.gradle.kts`
- Move: `android/app/src/main/kotlin/com/example/travel_app/MainActivity.kt` to `android/app/src/main/kotlin/com/example/travel_app_v2/MainActivity.kt`

- [ ] **Step 1: Update Android namespace and application id**

In `android/app/build.gradle.kts`, set the Android block to include:

```kotlin
android {
    namespace = "com.example.travel_app_v2"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.travel_app_v2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

Keep the generated `plugins`, `compileOptions`, `kotlinOptions`, and `flutter` blocks from the Flutter template.

- [ ] **Step 2: Move `MainActivity.kt` package**

Run:

```powershell
New-Item -ItemType Directory -Force android\app\src\main\kotlin\com\example\travel_app_v2 | Out-Null
Move-Item -LiteralPath android\app\src\main\kotlin\com\example\travel_app\MainActivity.kt -Destination android\app\src\main\kotlin\com\example\travel_app_v2\MainActivity.kt
```

Then update the first line of `android/app/src/main/kotlin/com/example/travel_app_v2/MainActivity.kt`:

```kotlin
package com.example.travel_app_v2
```

- [ ] **Step 3: Remove empty old Kotlin package directory**

Run:

```powershell
Remove-Item -LiteralPath android\app\src\main\kotlin\com\example\travel_app -Force
```

Expected: only `android/app/src/main/kotlin/com/example/travel_app_v2/MainActivity.kt` remains for the app activity.

- [ ] **Step 4: Verify Gradle files parse**

Run:

```powershell
flutter build apk --debug
```

Expected: this may fail on missing assets or Dart compile errors, but it must not fail because of `namespace`, `applicationId`, or missing `MainActivity`.

- [ ] **Step 5: Commit Android package rename**

Run:

```powershell
git add android
git commit -m "chore: set Android application id"
```

Expected: commit succeeds.

---

### Task 3: Add Firebase Emulator Startup

**Files:**
- Create: `lib/repositories/firebase_emulator.dart`
- Create: `test/repositories/firebase_emulator_test.dart`
- Modify: `lib/main.dart`
- Modify: `lib/repositories/firebase_options.dart`

- [ ] **Step 1: Write failing host-selection tests**

Create `test/repositories/firebase_emulator_test.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/repositories/firebase_emulator.dart';

void main() {
  test('uses Android emulator loopback host for Android', () {
    expect(
      firebaseEmulatorHostFor(platform: TargetPlatform.android, isWeb: false),
      '10.0.2.2',
    );
  });

  test('uses localhost for non-Android desktop targets', () {
    expect(
      firebaseEmulatorHostFor(platform: TargetPlatform.windows, isWeb: false),
      'localhost',
    );
  });

  test('override host wins over platform defaults', () {
    expect(
      firebaseEmulatorHostFor(
        platform: TargetPlatform.android,
        isWeb: false,
        overrideHost: '192.168.1.50',
      ),
      '192.168.1.50',
    );
  });
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```powershell
flutter test test\repositories\firebase_emulator_test.dart
```

Expected: FAIL with an import error for `firebase_emulator.dart`.

- [ ] **Step 3: Add emulator helper**

Create `lib/repositories/firebase_emulator.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

const int firebaseAuthEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;
const int firebaseDatabaseEmulatorPort = 9000;

String firebaseEmulatorHostFor({
  TargetPlatform? platform,
  bool? isWeb,
  String? overrideHost,
}) {
  if (overrideHost != null && overrideHost.trim().isNotEmpty) {
    return overrideHost.trim();
  }

  final resolvedIsWeb = isWeb ?? kIsWeb;
  if (resolvedIsWeb) {
    return 'localhost';
  }

  final resolvedPlatform = platform ?? defaultTargetPlatform;
  return resolvedPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
}

Future<void> configureFirebaseEmulators({
  String? host,
  bool force = false,
}) async {
  if (!force && kReleaseMode) {
    return;
  }

  final emulatorHost = firebaseEmulatorHostFor(overrideHost: host);
  await FirebaseAuth.instance.useAuthEmulator(
    emulatorHost,
    firebaseAuthEmulatorPort,
  );
  FirebaseFirestore.instance.useFirestoreEmulator(
    emulatorHost,
    firestoreEmulatorPort,
  );
  FirebaseDatabase.instance.useDatabaseEmulator(
    emulatorHost,
    firebaseDatabaseEmulatorPort,
  );
}
```

- [ ] **Step 4: Run emulator helper tests**

Run:

```powershell
flutter test test\repositories\firebase_emulator_test.dart
```

Expected: PASS.

- [ ] **Step 5: Replace dev Firebase options**

Replace `lib/repositories/firebase_options.dart` with:

```dart
// Dev-only Firebase options for Firebase Emulator recovery.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Only Android is configured for this recovery pass.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dev-api-key',
    appId: '1:1234567890:android:0000000000000000000000',
    messagingSenderId: '1234567890',
    projectId: 'travel-app-v2-dev',
    databaseURL: 'http://10.0.2.2:9000?ns=travel-app-v2-dev',
    storageBucket: 'travel-app-v2-dev.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'dev-api-key',
    appId: '1:1234567890:web:0000000000000000000000',
    messagingSenderId: '1234567890',
    projectId: 'travel-app-v2-dev',
    authDomain: 'travel-app-v2-dev.firebaseapp.com',
    databaseURL: 'http://localhost:9000?ns=travel-app-v2-dev',
    storageBucket: 'travel-app-v2-dev.appspot.com',
  );
}
```

- [ ] **Step 6: Update app startup**

Replace the imports and `main()` body in `lib/main.dart` with this structure:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'blocs/place/placeList_bloc.dart';
import 'blocs/trip/trip_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'network_controller.dart';
import 'repositories/firebase_emulator.dart';
import 'repositories/firebase_options.dart';
import 'ui/Welcomepage.dart';
import 'ui/emailVerificationPage.dart';
import 'ui/navigationPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureFirebaseEmulators();
  Get.put<NetworkController>(NetworkController(), permanent: true);
  runApp(const MyApp());
}
```

Keep the existing `MyApp` and `AuthHandler` classes after the new `main()` unless a later analyzer error requires a targeted change.

- [ ] **Step 7: Verify analyzer reaches project code**

Run:

```powershell
flutter analyze
```

Expected: dependency URI errors for Firebase/Flutter packages are gone. Remaining errors are specific Dart/API errors in project files.

- [ ] **Step 8: Commit Firebase emulator bootstrap**

Run:

```powershell
git add lib\main.dart lib\repositories\firebase_emulator.dart lib\repositories\firebase_options.dart test\repositories\firebase_emulator_test.dart
git commit -m "feat: add Firebase emulator bootstrap"
```

Expected: commit succeeds.

---

### Task 4: Generate Publish-Safe Local Assets

**Files:**
- Create: `tool/generate_recovery_assets.ps1`
- Create: `assets/images/*`
- Create: `assets/ATTRIBUTION.md`
- Modify: `lib/ui/Welcomepage.dart`

- [ ] **Step 1: Update social icon asset names in `Welcomepage.dart`**

Replace:

```dart
"assets/images/Facebook_Logo_(2019).png.webp"
```

with:

```dart
"assets/images/facebook-logo.png"
```

Replace:

```dart
"assets/images/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png"
```

with:

```dart
"assets/images/google-logo.png"
```

- [ ] **Step 2: Create deterministic asset generator**

Create `tool/generate_recovery_assets.ps1`:

```powershell
Add-Type -AssemblyName System.Drawing

$assetDir = Join-Path (Get-Location) "assets/images"
New-Item -ItemType Directory -Force $assetDir | Out-Null

function New-PngAsset {
  param(
    [string]$Name,
    [string]$Label,
    [int]$Red,
    [int]$Green,
    [int]$Blue
  )

  $bitmap = New-Object System.Drawing.Bitmap 96, 96
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $bg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, $Red, $Green, $Blue))
  $graphics.FillRectangle($bg, 0, 0, 96, 96)
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 6
  $graphics.DrawEllipse($pen, 16, 16, 64, 64)
  $font = New-Object System.Drawing.Font "Arial", 24, ([System.Drawing.FontStyle]::Bold)
  $textBrush = [System.Drawing.Brushes]::White
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center
  $graphics.DrawString($Label, $font, $textBrush, (New-Object System.Drawing.RectangleF 0, 0, 96, 96), $format)
  $bitmap.Save((Join-Path $assetDir $Name), [System.Drawing.Imaging.ImageFormat]::Png)
  $graphics.Dispose()
  $bitmap.Dispose()
}

function New-JpgAsset {
  param(
    [string]$Name,
    [int]$Red,
    [int]$Green,
    [int]$Blue
  )

  $bitmap = New-Object System.Drawing.Bitmap 800, 1200
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle 0, 0, 800, 1200),
    [System.Drawing.Color]::FromArgb(255, $Red, $Green, $Blue),
    [System.Drawing.Color]::FromArgb(255, 23, 91, 122),
    45
  )
  $graphics.FillRectangle($brush, 0, 0, 800, 1200)
  $bitmap.Save((Join-Path $assetDir $Name), [System.Drawing.Imaging.ImageFormat]::Jpeg)
  $graphics.Dispose()
  $bitmap.Dispose()
}

New-JpgAsset "app bac.jpg" 32 150 136
New-PngAsset "Rectangle 1.png" "TR" 33 150 243
New-PngAsset "Rectangle 1 loging.png" "IN" 26 188 156

$icons = @(
  @("home.png","H",80,120,200), @("homeClick.png","H",20,70,160),
  @("search.png","S",80,120,200), @("searchClick.png","S",20,70,160),
  @("map.png","M",80,120,200), @("mapClick.png","M",20,70,160),
  @("like.png","L",80,120,200), @("likeClick.png","L",20,70,160),
  @("user.png","U",80,120,200), @("userClick.png","U",20,70,160),
  @("hotel.png","H",47,128,237), @("burger.png","B",239,126,69),
  @("forest.png","F",58,151,93), @("flash.png","A",245,190,60),
  @("gas-pump.png","G",115,115,115), @("heart.png","♡",235,93,120),
  @("heartBlack.png","♥",30,30,30), @("star.png","★",244,185,66),
  @("location.png","P",46,134,193), @("correct.png","✓",60,170,110),
  @("dry-clean.png","○",160,160,160), @("travel.png","T",38,166,154),
  @("destination.png","D",38,166,154), @("add.png","+",40,140,90),
  @("add-black.png","+",35,35,35), @("chat-arrow.png",">",52,152,219),
  @("chat-arrow-before.png",">",170,170,170), @("facebook-logo.png","f",24,119,242),
  @("google-logo.png","G",66,133,244), @("sunny.png","☀",245,180,55),
  @("cloudy.png","C",120,160,180), @("mostly-cloudy.png","C",95,140,170),
  @("cloudsAndSun.png","S",100,170,210), @("Partly-sunny.png","S",240,180,80),
  @("Mostly-Sunny-Day.png","S",240,170,40), @("PartlyCloudyNightV2.png","N",50,70,130),
  @("MostlyClearNight.png","N",30,45,110), @("MostlyCloudyNightV2.png","N",65,75,115),
  @("N210LightRainShowersV2.png","R",70,110,170), @("Light-rain.png","R",75,130,190),
  @("time-left.png","?",130,130,130)
)

foreach ($icon in $icons) {
  New-PngAsset $icon[0] $icon[1] $icon[2] $icon[3] $icon[4]
}

$lottie = @'
{
  "v": "5.7.4",
  "fr": 30,
  "ip": 0,
  "op": 60,
  "w": 240,
  "h": 240,
  "nm": "Recovery checklist",
  "ddd": 0,
  "assets": [],
  "layers": []
}
'@
Set-Content -LiteralPath (Join-Path $assetDir "143784-checklist.json") -Value $lottie -Encoding UTF8
```

- [ ] **Step 3: Generate assets**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tool\generate_recovery_assets.ps1
```

Expected: `assets/images/app bac.jpg`, `assets/images/home.png`, `assets/images/homeClick.png`, `assets/images/time-left.png`, and `assets/images/143784-checklist.json` exist.

- [ ] **Step 4: Add attribution**

Create `assets/ATTRIBUTION.md`:

```markdown
# Asset Attribution

All files in `assets/images/` for the Android recovery pass are generated by `tool/generate_recovery_assets.ps1`.

These assets are simple project-created geometric files and do not include third-party artwork, brand files, photos, icon packs, or downloaded lottie files.

The files may be used, modified, and replaced as part of this project. When production-quality brand or travel photography is added later, record each source, author, URL, and license in this file before publishing.
```

- [ ] **Step 5: Verify no referenced asset is missing**

Run:

```powershell
$required = @(
  "app bac.jpg","Rectangle 1.png","Rectangle 1 loging.png",
  "home.png","homeClick.png","search.png","searchClick.png","map.png","mapClick.png","like.png","likeClick.png","user.png","userClick.png",
  "hotel.png","burger.png","forest.png","flash.png","gas-pump.png",
  "heart.png","heartBlack.png","star.png","location.png","correct.png","dry-clean.png","travel.png","destination.png",
  "add.png","add-black.png","chat-arrow.png","chat-arrow-before.png",
  "facebook-logo.png","google-logo.png",
  "sunny.png","cloudy.png","mostly-cloudy.png","cloudsAndSun.png","Partly-sunny.png","Mostly-Sunny-Day.png",
  "PartlyCloudyNightV2.png","MostlyClearNight.png","MostlyCloudyNightV2.png","N210LightRainShowersV2.png","Light-rain.png","time-left.png",
  "143784-checklist.json"
)
$missing = $required | Where-Object { -not (Test-Path -LiteralPath (Join-Path "assets/images" $_)) }
if ($missing.Count -gt 0) { $missing; exit 1 }
Write-Output "All recovery assets exist."
```

Expected: prints `All recovery assets exist.`

- [ ] **Step 6: Commit generated assets**

Run:

```powershell
git add tool\generate_recovery_assets.ps1 assets lib\ui\Welcomepage.dart
git commit -m "chore: add recovery assets"
```

Expected: commit succeeds.

---

### Task 5: Fix Known Compile Blockers

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/network_controller.dart`
- Modify: files importing `package:flutter/src/widgets/framework.dart`

- [ ] **Step 1: Fix bad relative imports in `main.dart`**

Ensure `lib/main.dart` imports these local files without `../`:

```dart
import 'blocs/place/placeList_bloc.dart';
import 'blocs/trip/trip_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'network_controller.dart';
import 'ui/Welcomepage.dart';
import 'ui/emailVerificationPage.dart';
import 'ui/navigationPage.dart';
```

- [ ] **Step 2: Remove private Flutter framework imports**

Remove this import wherever it appears:

```dart
import 'package:flutter/src/widgets/framework.dart';
```

Known files from the current repo:

```text
lib/ui/emailVerificationPage.dart
lib/ui/createTrip.dart
lib/ui/components/cityList.dart
lib/ui/profile/myAccount.dart
lib/ui/placeDeatailsScreen/placesList.dart
```

Each file already imports `package:flutter/material.dart`, which provides the widget types used there.

- [ ] **Step 3: Update `NetworkController` for current `connectivity_plus` stream type**

Replace `lib/network_controller.dart` with:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint("Couldn't check connectivity status, error: $e");
      }
      return;
    }

    await _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(
    List<ConnectivityResult> results,
  ) async {
    final isOffline =
        results.isEmpty || results.contains(ConnectivityResult.none);
    if (isOffline) {
      await Future.delayed(const Duration(milliseconds: 100));
      Get.rawSnackbar(
        messageText: const Text(
          'PLEASE CONNECT TO THE INTERNET',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: const Color.fromARGB(255, 97, 97, 97),
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );
    } else if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }
}
```

- [ ] **Step 4: Run analyzer**

Run:

```powershell
flutter analyze
```

Expected: URI errors for bad local imports and private framework imports are gone. Remaining issues are project logic/API issues to address in later tasks.

- [ ] **Step 5: Commit compile blocker fixes**

Run:

```powershell
git add lib
git commit -m "fix: resolve initial compile blockers"
```

Expected: commit succeeds.

---

### Task 6: Fix TripRepo Current User Handling

**Files:**
- Modify: `lib/repositories/trips/trip_repo.dart`
- Create: `test/repositories/trip_repo_test.dart`

- [ ] **Step 1: Write failing TripRepo tests**

Create `test/repositories/trip_repo_test.dart`:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/models/trip.dart';
import 'package:travel_app/repositories/trips/trip_repo.dart';

Trip sampleTrip() {
  return Trip(
    tripId: 'trip-1',
    tripName: 'Da Nang',
    tripBudget: '1000',
    tripLocation: 'Da Nang',
    tripDescription: 'Beach trip',
    tripCoverPhoto: 'cover.jpg',
    tripDuration: '2 days',
    durationCount: 2,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 3),
    places: <String, dynamic>{},
  );
}

void main() {
  test('createTrip writes under the signed-in user at call time', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'user-1', email: 'user@example.com'),
      signedIn: true,
    );
    final repo = TripRepo(firestore: firestore, firebaseAuth: auth);

    final isError = await repo.createTrip(sampleTrip());

    expect(isError, isFalse);
    final trips = await firestore
        .collection('users')
        .doc('user-1')
        .collection('trips')
        .get();
    expect(trips.docs, hasLength(1));
    expect(trips.docs.single.data()['tripId'], 'trip-1');
  });

  test('createTrip returns true when no user is signed in', () async {
    final repo = TripRepo(
      firestore: FakeFirebaseFirestore(),
      firebaseAuth: MockFirebaseAuth(signedIn: false),
    );

    final isError = await repo.createTrip(sampleTrip());

    expect(isError, isTrue);
  });
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```powershell
flutter test test\repositories\trip_repo_test.dart
```

Expected: FAIL because `TripRepo` does not accept injected Firestore/Auth.

- [ ] **Step 3: Refactor `TripRepo` with injected dependencies and call-time user lookup**

Replace `lib/repositories/trips/trip_repo.dart` with:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;

import '../../models/trip.dart';

class TripRepo {
  TripRepo({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _firebaseAuth;

  auth.User _currentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to access trips.');
    }
    return user;
  }

  CollectionReference<Map<String, dynamic>> _tripsCollection() {
    return _firestore
        .collection('users')
        .doc(_currentUser().uid)
        .collection('trips');
  }

  Future<bool> createTrip(Trip trip) async {
    try {
      await _tripsCollection().add(trip.toJson());
      return false;
    } catch (e) {
      debugPrint('Error creating trip: $e');
      return true;
    }
  }

  Future<bool> updateTrip(Trip trip) async {
    try {
      final querySnapshot = await _tripsCollection()
          .where('tripId', isEqualTo: trip.tripId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw StateError('Trip not found: ${trip.tripId}');
      }

      await _tripsCollection()
          .doc(querySnapshot.docs.first.id)
          .update(trip.toJson());
      return false;
    } catch (e) {
      debugPrint('Error updating trip: $e');
      return true;
    }
  }

  Future<List<Trip>> onGoingTrips() async {
    final now = DateTime.now();
    final currentDate = DateTime.parse(intl.DateFormat('yyyy-MM-dd').format(now));
    final query = await _tripsCollection()
        .where('endDate', isGreaterThan: currentDate)
        .get();
    return query.docs.map((doc) => Trip.fromMap(doc.data())).toList();
  }

  Future<List<Trip>> pastTrips() async {
    final now = DateTime.now();
    final currentDate = DateTime.parse(intl.DateFormat('yyyy-MM-dd').format(now));
    final query = await _tripsCollection()
        .where('endDate', isLessThan: currentDate)
        .get();
    return query.docs.map((doc) => Trip.fromMap(doc.data())).toList();
  }

  Future<Trip> getSelectTrip(String tripId) async {
    final query = await _tripsCollection()
        .where('tripId', isEqualTo: tripId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError('Trip not found: $tripId');
    }

    return Trip.fromMap(query.docs.first.data());
  }

  Future<int> countTotalTrips() async {
    final result = await _tripsCollection().count().get();
    return result.count ?? 0;
  }
}

final tripRepo = TripRepo();
```

- [ ] **Step 4: Run TripRepo tests**

Run:

```powershell
flutter test test\repositories\trip_repo_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit TripRepo fix**

Run:

```powershell
git add lib\repositories\trips\trip_repo.dart test\repositories\trip_repo_test.dart
git commit -m "fix: read trip user at call time"
```

Expected: commit succeeds.

---

### Task 7: Fix Place Detail Queries And Review Persistence

**Files:**
- Modify: `lib/repositories/city/city_repo.dart`
- Modify: `lib/repositories/attractions/attractionList_repo.dart`
- Modify: `lib/repositories/restaurants/restaurants_repo.dart`
- Modify: `lib/blocs/place/placeList_bloc.dart`
- Create: `test/repositories/place_repos_test.dart`

- [ ] **Step 1: Write failing place repository tests**

Create `test/repositories/place_repos_test.dart`:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/repositories/attractions/attractionList_repo.dart';
import 'package:travel_app/repositories/city/city_repo.dart';
import 'package:travel_app/repositories/restaurants/restaurants_repo.dart';

Map<String, dynamic> placeData(String placeId) => {
      'placeId': placeId,
      'title': 'Sample place',
      'imageUrls': ['image.jpg'],
      'rating': 4.5,
      'address': 'Sample address',
      'searchString': 'restaurant',
      'phone': '123',
      'reviews': <Map<String, dynamic>>[],
      'openingHours': <String>[],
      'location': {'lat': 10.0, 'lng': 106.0},
    };

Map<String, dynamic> reviewData(String reviewId, String userId) => {
      'userId': userId,
      'reviewId': reviewId,
      'name': 'Reviewer',
      'publishAt': DateTime(2026, 1, 1),
      'reviewerPhotoUrl': 'avatar.png',
      'text': 'Good place',
    };

void main() {
  test('city detail throws controlled error when place is missing', () async {
    final repo = cityRepo(
      firestore: FakeFirebaseFirestore(),
      firebaseAuth: MockFirebaseAuth(signedIn: true),
    );

    expect(
      () => repo.getcityDetailes('missing-city'),
      throwsA(isA<StateError>()),
    );
  });

  test('attraction deleteReview updates reviews and userIds by placeId', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('attractions').add({
      ...placeData('attraction-1'),
      'searchString': 'attraction',
      'reviews': [reviewData('review-1', 'user-1')],
      'userIds': ['user-1'],
    });
    final repo = attractionListRepo(firestore: firestore);

    await repo.deleteReview(
      placeId: 'attraction-1',
      reviews: <Map<String, dynamic>>[],
      userId: 'user-1',
    );

    final query = await firestore
        .collection('attractions')
        .where('placeId', isEqualTo: 'attraction-1')
        .get();
    final data = query.docs.single.data();
    expect(data['reviews'], isEmpty);
    expect(data['userIds'], isEmpty);
  });

  test('restaurant addReview mirrors parent field and reviews subcollection', () async {
    final firestore = FakeFirebaseFirestore();
    final parentRef = await firestore
        .collection('restaurants')
        .add(placeData('restaurant-1'));
    final repo = RestaurantsRepo(firestore: firestore);

    await repo.addReview(
      placeId: 'restaurant-1',
      reviews: [reviewData('review-1', 'user-1')],
    );

    final parent = await parentRef.get();
    final subcollection = await parentRef.collection('reviews').get();
    expect(parent.data()!['reviews'], hasLength(1));
    expect(subcollection.docs, hasLength(1));
    expect(subcollection.docs.single.id, 'review-1');
  });
}
```

- [ ] **Step 2: Run tests and verify failure**

Run:

```powershell
flutter test test\repositories\place_repos_test.dart
```

Expected: FAIL because repositories do not accept injected Firestore/Auth and review methods are positional.

- [ ] **Step 3: Refactor `city_repo.dart`**

Replace constructor and Firestore/Auth access in `cityRepo` with:

```dart
class cityRepo {
  cityRepo({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _firebaseAuth;

  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  Future<Place> getcityDetailes(placeId) async {
    final query = await _firestore
        .collection('cities')
        .where('placeId', isEqualTo: placeId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError('City not found: $placeId');
    }

    return Place.fromMap(query.docs.first.data());
  }
}
```

Then replace remaining `FirebaseFirestore.instance` calls in that file with `_firestore`.

- [ ] **Step 4: Refactor attraction review methods to named parameters**

In `lib/repositories/attractions/attractionList_repo.dart`, add a constructor:

```dart
class attractionListRepo {
  const attractionListRepo({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
}
```

Use `firestore` instead of `FirebaseFirestore.instance` in this file.

Change detail lookup:

```dart
Future<Place> getAttractionDetailes(placeId) async {
  final query = await firestore
      .collection('attractions')
      .where('placeId', isEqualTo: placeId)
      .limit(1)
      .get();

  if (query.docs.isEmpty) {
    throw StateError('Attraction not found: $placeId');
  }

  return Place.fromMap(query.docs.first.data());
}
```

Change delete signature and body:

```dart
Future<void> deleteReview({
  required String placeId,
  required List reviews,
  required String userId,
}) async {
  final attractionsQuery = await firestore
      .collection('attractions')
      .where('placeId', isEqualTo: placeId)
      .get();

  final userStillHasReview = reviews.any((review) => review['userId'] == userId);

  for (final doc in attractionsQuery.docs) {
    final currentUserIds = List<String>.from(doc.data()['userIds'] ?? <String>[]);
    if (!userStillHasReview) {
      currentUserIds.removeWhere((id) => id == userId);
    }
    await doc.reference.update({
      'reviews': reviews,
      'userIds': currentUserIds,
    });
  }
}
```

Change add signature and body:

```dart
Future<void> addReview({
  required String placeId,
  required List reviews,
  required String userId,
}) async {
  final attractionsQuery = await firestore
      .collection('attractions')
      .where('placeId', isEqualTo: placeId)
      .get();

  for (final doc in attractionsQuery.docs) {
    final userIds = List<String>.from(doc.data()['userIds'] ?? <String>[]);
    if (!userIds.contains(userId)) {
      userIds.add(userId);
    }
    await doc.reference.update({
      'reviews': reviews,
      'userIds': userIds,
    });
  }
}
```

- [ ] **Step 5: Refactor restaurant review persistence**

In `lib/repositories/restaurants/restaurants_repo.dart`, add injectable Firestore:

```dart
class RestaurantsRepo {
  const RestaurantsRepo({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
}
```

Use `firestore` instead of `FirebaseFirestore.instance` in this file.

Change detail lookup:

```dart
Future<Place> getRestaurantDetails(placeId) async {
  final query = await firestore
      .collection('restaurants')
      .where('placeId', isEqualTo: placeId)
      .limit(1)
      .get();

  if (query.docs.isEmpty) {
    throw StateError('Restaurant not found: $placeId');
  }

  return Place.fromMap(query.docs.first.data());
}
```

Change `addReview`:

```dart
Future<void> addReview({
  required String placeId,
  required List reviews,
}) async {
  final querySnapshot = await firestore
      .collection('restaurants')
      .where('placeId', isEqualTo: placeId)
      .get();

  for (final doc in querySnapshot.docs) {
    await doc.reference.update({'reviews': reviews});
    final existing = await doc.reference.collection('reviews').get();
    for (final reviewDoc in existing.docs) {
      await reviewDoc.reference.delete();
    }
    for (final review in reviews) {
      final reviewId = review['reviewId']?.toString();
      if (reviewId != null && reviewId.isNotEmpty) {
        await doc.reference.collection('reviews').doc(reviewId).set(
              Map<String, dynamic>.from(review),
            );
      }
    }
  }
}
```

Change `deleteReview`:

```dart
Future<void> deleteReview({
  required String placeId,
  required List reviews,
}) async {
  await addReview(placeId: placeId, reviews: reviews);
}
```

- [ ] **Step 6: Update `placeList_bloc.dart` review calls**

Replace review repository calls with named arguments:

```dart
await attractionListRep.addReview(
  placeId: event.placeId,
  reviews: event.reviews,
  userId: event.userId,
);
```

```dart
await restaurantRepo.addReview(
  placeId: event.placeId,
  reviews: event.reviews,
);
```

```dart
await attractionListRep.deleteReview(
  placeId: event.placeId,
  reviews: event.reviews,
  userId: event.userId,
);
```

```dart
await restaurantRepo.deleteReview(
  placeId: event.placeId,
  reviews: event.reviews,
);
```

- [ ] **Step 7: Run place repository tests**

Run:

```powershell
flutter test test\repositories\place_repos_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit place/review fixes**

Run:

```powershell
git add lib\repositories\city\city_repo.dart lib\repositories\attractions\attractionList_repo.dart lib\repositories\restaurants\restaurants_repo.dart lib\blocs\place\placeList_bloc.dart test\repositories\place_repos_test.dart
git commit -m "fix: stabilize place detail and review persistence"
```

Expected: commit succeeds.

---

### Task 8: Fix Directions Fallback And Disable Google Sign-In In Dev

**Files:**
- Modify: `lib/repositories/directions/directions_repo.dart`
- Modify: `lib/repositories/user/userAuth_repo.dart`
- Modify: `lib/ui/Welcomepage.dart`
- Create: `test/repositories/directions_repo_test.dart`

- [ ] **Step 1: Write failing directions fallback test**

Create `test/repositories/directions_repo_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/repositories/directions/directions_repo.dart';

void main() {
  test('calculateDistance returns empty list when currentLocation is missing', () async {
    SharedPreferences.setMockInitialValues({});
    const repo = DirectionsRepo(lat: 10.0, lng: 106.0);

    final result = await repo.calculateDistance();

    expect(result, isEmpty);
  });
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```powershell
flutter test test\repositories\directions_repo_test.dart
```

Expected: FAIL because `jsonDecode(getSheardData!)` throws when no location exists.

- [ ] **Step 3: Update `DirectionsRepo.calculateDistance`**

Replace the method body with:

```dart
Future<List> calculateDistance() async {
  final prefs = await SharedPreferences.getInstance();
  final storedLocation = prefs.getString('currentLocation');
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  if (storedLocation == null || storedLocation.isEmpty) {
    return [];
  }
  if (apiKey == null || apiKey.isEmpty) {
    return [];
  }

  final currentLocation = jsonDecode(storedLocation);
  final originLat = currentLocation['lat'];
  final originLng = currentLocation['lng'];
  if (originLat == null || originLng == null) {
    return [];
  }

  final url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$lat,$lng&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) {
    return [];
  }

  final data = jsonDecode(response.body);
  final routes = data['routes'];
  if (routes is! List || routes.isEmpty) {
    return [];
  }

  final legs = routes.first['legs'];
  if (legs is! List || legs.isEmpty) {
    return [];
  }

  final leg = legs.first;
  final distance = leg['distance']?['text'];
  final duration = leg['duration']?['text'];
  if (distance == null || duration == null) {
    return [];
  }

  return [
    {
      'currentCity': prefs.getString('currentCity'),
      'distance': distance,
      'duration': duration,
    }
  ];
}
```

- [ ] **Step 4: Make Google Sign-In dev-safe in repository**

Add this import to `lib/repositories/user/userAuth_repo.dart`:

```dart
import 'package:flutter/foundation.dart';
```

Add this guard at the top of `signInWithGoogle()`:

```dart
if (kDebugMode) {
  debugPrint('Google Sign-In is disabled for Firebase Emulator dev.');
  return null;
}
```

- [ ] **Step 5: Disable Google button behavior in `Welcomepage.dart` debug builds**

Add this import:

```dart
import 'package:flutter/foundation.dart';
```

Replace the Google button `onPressed` with:

```dart
onPressed: () {
  if (kDebugMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In đang tắt trong chế độ dev emulator.'),
      ),
    );
    return;
  }
  BlocProvider.of<userBloc>(context).add(signInWithGoogle());
},
```

- [ ] **Step 6: Run directions test**

Run:

```powershell
flutter test test\repositories\directions_repo_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit directions/auth dev fixes**

Run:

```powershell
git add lib\repositories\directions\directions_repo.dart lib\repositories\user\userAuth_repo.dart lib\ui\Welcomepage.dart test\repositories\directions_repo_test.dart
git commit -m "fix: add dev-safe directions and google auth behavior"
```

Expected: commit succeeds.

---

### Task 9: Add Firebase Emulator Config, Seed Data, And Docs

**Files:**
- Create: `firebase.json`
- Create: `tool/seed_firestore_emulator.ps1`
- Create: `docs/firebase-emulator.md`
- Create: `docs/android-recovery.md`

- [ ] **Step 1: Create Firebase Emulator config**

Create `firebase.json`:

```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "database": {
      "port": 9000
    },
    "ui": {
      "enabled": true,
      "port": 4000
    },
    "singleProjectMode": true
  }
}
```

- [ ] **Step 2: Create Firestore seed script**

Create `tool/seed_firestore_emulator.ps1`:

```powershell
$projectId = "travel-app-v2-dev"
$base = "http://127.0.0.1:8080/v1/projects/$projectId/databases/(default)/documents"

function Set-FirestoreDocument {
  param(
    [string]$Path,
    [hashtable]$Fields
  )

  $body = @{ fields = @{} }
  foreach ($key in $Fields.Keys) {
    $value = $Fields[$key]
    if ($value -is [double] -or $value -is [int]) {
      $body.fields[$key] = @{ doubleValue = [double]$value }
    } elseif ($value -is [array]) {
      $body.fields[$key] = @{
        arrayValue = @{
          values = @($value | ForEach-Object { @{ stringValue = [string]$_ } })
        }
      }
    } elseif ($value -is [hashtable]) {
      $body.fields[$key] = @{
        mapValue = @{
          fields = @{
            lat = @{ doubleValue = [double]$value.lat }
            lng = @{ doubleValue = [double]$value.lng }
          }
        }
      }
    } else {
      $body.fields[$key] = @{ stringValue = [string]$value }
    }
  }

  $json = $body | ConvertTo-Json -Depth 20
  Invoke-RestMethod -Method Patch -Uri "$base/$Path" -ContentType "application/json" -Body $json | Out-Null
}

$common = @{
  imageUrls = @("https://images.pexels.com/photos/2166553/pexels-photo-2166553.jpeg")
  rating = 4.5
  address = "Sample address"
  phone = "0900000000"
  openingHours = @("Open daily")
  location = @{ lat = 16.0544; lng = 108.2022 }
}

Set-FirestoreDocument "cities/da-nang" ($common + @{
  placeId = "city-da-nang"
  title = "Da Nang"
  searchString = "locality"
  reviews = @()
})

Set-FirestoreDocument "attractions/dragon-bridge" ($common + @{
  placeId = "attraction-dragon-bridge"
  title = "Dragon Bridge"
  searchString = "attraction"
  city = "Da Nang"
  reviews = @()
  userIds = @()
})

Set-FirestoreDocument "restaurants/sample-restaurant" ($common + @{
  placeId = "restaurant-sample"
  title = "Sample Restaurant"
  searchString = "restaurant"
  city = "Da Nang"
  reviews = @()
})

Write-Output "Seeded Firestore Emulator for project $projectId."
```

- [ ] **Step 3: Add Firebase Emulator runbook**

Create `docs/firebase-emulator.md`:

```markdown
# Firebase Emulator

Project id for local recovery: `travel-app-v2-dev`.

Start emulators:

```powershell
firebase emulators:start --project travel-app-v2-dev
```

In another terminal, seed Firestore:

```powershell
powershell -ExecutionPolicy Bypass -File tool\seed_firestore_emulator.ps1
```

Ports:

- Auth: `9099`
- Firestore: `8080`
- Realtime Database: `9000`
- Emulator UI: `4000`

Android emulator apps connect to host `10.0.2.2`. Physical Android devices must use the LAN IP address of the development machine and pass it into `configureFirebaseEmulators(host: '<LAN-IP>')` during a separate device-specific setup.
```

- [ ] **Step 4: Add Android recovery runbook**

Create `docs/android-recovery.md`:

```markdown
# Android Recovery

Run dependency resolution:

```powershell
flutter pub get
```

Run analyzer:

```powershell
flutter analyze
```

Run repository tests:

```powershell
flutter test test\repositories
```

Build Android debug APK:

```powershell
flutter build apk --debug
```

Run app against Firebase Emulator:

```powershell
firebase emulators:start --project travel-app-v2-dev
powershell -ExecutionPolicy Bypass -File tool\seed_firestore_emulator.ps1
flutter run -d emulator
```

When replacing dev config with a real Firebase project, create a Firebase Android app with package `com.example.travel_app_v2`, download `android/app/google-services.json`, run FlutterFire configuration, and replace `lib/repositories/firebase_options.dart` with generated production options.
```

- [ ] **Step 5: Verify docs scripts are present**

Run:

```powershell
Test-Path firebase.json
Test-Path tool\seed_firestore_emulator.ps1
Test-Path docs\firebase-emulator.md
Test-Path docs\android-recovery.md
```

Expected: prints four `True` values.

- [ ] **Step 6: Commit emulator docs and seed tools**

Run:

```powershell
git add firebase.json tool\seed_firestore_emulator.ps1 docs\firebase-emulator.md docs\android-recovery.md
git commit -m "docs: add Firebase emulator recovery runbooks"
```

Expected: commit succeeds.

---

### Task 10: Final Verification Pass

**Files:**
- Modify only files required by concrete failures from the commands in this task.

- [ ] **Step 1: Run all repository tests**

Run:

```powershell
flutter test test\repositories
```

Expected: all repository tests pass.

- [ ] **Step 2: Run analyzer**

Run:

```powershell
flutter analyze
```

Expected: no analyzer errors. Legacy warnings may remain only when they do not prevent build or the recovery acceptance criteria.

- [ ] **Step 3: Build Android debug APK**

Run:

```powershell
flutter build apk --debug
```

Expected: build succeeds and writes a debug APK under `build\app\outputs\flutter-apk\app-debug.apk`.

- [ ] **Step 4: Start Firebase Emulator**

Run:

```powershell
firebase emulators:start --project travel-app-v2-dev
```

Expected: Auth, Firestore, Database, and Emulator UI start on ports `9099`, `8080`, `9000`, and `4000`.

- [ ] **Step 5: Seed Firestore Emulator**

In another terminal, run:

```powershell
powershell -ExecutionPolicy Bypass -File tool\seed_firestore_emulator.ps1
```

Expected: prints `Seeded Firestore Emulator for project travel-app-v2-dev.`

- [ ] **Step 6: Smoke-run Android app**

Run:

```powershell
flutter run -d emulator
```

Expected:

- App launches without missing asset exceptions.
- Email/password sign-up and sign-in use Auth Emulator.
- After sign-in, the app reaches the main navigation screen.
- Opening home/search/detail screens with seeded data does not crash.
- Favorite, trip creation, and review add/delete flows do not crash.

- [ ] **Step 7: Commit final verification fixes**

If Step 1 through Step 6 required targeted fixes, commit them:

```powershell
git add .
git commit -m "fix: complete Android recovery verification"
```

Expected: commit succeeds only when there are actual verification fixes. If `git status --short` is empty, skip this commit.
