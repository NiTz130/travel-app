# 📝 Changelog

Tất cả thay đổi đáng chú ý của dự án sẽ được ghi lại tại file này.

Format dựa theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/),
dự án tuân theo [Semantic Versioning](https://semver.org/lang/vi/).

## [1.0.0+1] - 2026-06-25

### Added
- Email/password và Google sign-in flow.
- Email verification & password reset screens.
- Bottom navigation: Home, Search, Favorites, Profile, Trip detail.
- Trip creation, trip detail, place list, place detail, reviews, favorites.
- Weather, directions, maps (Syncfusion), random destination images (Pexels).
- Firebase Emulator setup (`firebase.json` + `tool/seed_firestore_emulator.ps1`).
- Repository tests với `fake_cloud_firestore` + `firebase_auth_mocks`.
- Network awareness (`connectivity_plus`) + offline cache (`shared_preferences`).
- `flutter_dotenv` cho API keys tùy chọn.

### Recovery
- Android Gradle recovery (xem `docs/android-recovery.md`).
- Firebase Emulator guide (xem `docs/firebase-emulator.md`).
