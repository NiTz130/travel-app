# 🤝 Đóng góp cho Travel App

## Quy trình

1. **Fork** repo và tạo branch: `git checkout -b feat/ten-tinh-nang`
2. **Cài** dependencies: `flutter pub get`
3. **Bật** Firebase Emulator + seed: `firebase emulators:start` rồi `tool/seed_firestore_emulator.ps1`
4. **Code** theo `analysis_options.yaml` + `flutter_lints`
5. **Test**: `flutter analyze && flutter test`
6. **Commit** với [Conventional Commits](https://www.conventionalcommits.org/)
7. **Push** + mở Pull Request

## Quy tắc

- **Không commit**: `google-services.json`, `.env` thật, `build/`, `.dart_tool/`, `*.lock` (trừ `pubspec.lock`)
- **Test** mọi repository mới với `fake_cloud_firestore` hoặc Firebase Emulator
- **L10n**: UI chính dùng tiếng Anh; nếu cần tiếng Việt → `intl` ARB
- **PR** phải kèm screenshot nếu thay đổi UI

## Commit Convention

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore
```

**Ví dụ**:
```
feat(auth): add Google sign-in flow
fix(map): handle null location permission
docs(readme): add architecture diagram
```
