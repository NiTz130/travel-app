# Android Firebase Emulator Recovery Design

## Mục Tiêu

Khôi phục repository hiện tại thành một Flutter Android project có thể build và chạy dev local. Source hiện chỉ còn thư mục `lib/`, nên phần phục hồi sẽ tái tạo scaffold Flutter/Android, khai báo dependency, assets, cấu hình Firebase Emulator, và sửa các lỗi critical đang chặn luồng chính.

Kết quả mong muốn là Android debug build chạy được với package name `com.example.travel_app_v2`, đăng ký/đăng nhập email-password qua Firebase Auth Emulator, mở được luồng navigation chính, và không crash vì thiếu asset hoặc lỗi runtime đã biết.

## Ngoài Phạm Vi

- Không khôi phục iOS, web, desktop trong vòng phục hồi đầu tiên.
- Không dùng lại Firebase project cũ `flutter-travel-app-3f538` vì không còn quyền truy cập.
- Không cấu hình Google Sign-In production trong dev emulator.
- Không làm lại toàn bộ UI, state management, hoặc data model.
- Không migrate dữ liệu production cũ.
- Không xử lý mọi warning style nếu warning đó không chặn build hoặc luồng chính.

## Quyết Định Chính

1. Reconstruct project theo hướng Android-only trước.
2. Dùng package name Android `com.example.travel_app_v2`.
3. Dùng Firebase Emulator cho dev local, ưu tiên Auth và Firestore.
4. Email/password là luồng auth dev chính.
5. Google Sign-In sẽ bị ẩn hoặc disable rõ ràng trong dev path.
6. Assets mới phải miễn phí/open-license và có attribution.
7. Các lỗi critical trong `lib/` được sửa cùng vòng phục hồi, không để app build nhưng crash ngay ở luồng chính.

## Project Scaffold

Tạo lại cấu trúc Flutter project chuẩn cho Android:

- `pubspec.yaml`
- `analysis_options.yaml`
- `android/`
- `assets/images/`
- tài liệu vận hành trong `docs/`

Thư mục `lib/` hiện có được giữ làm source chính. Nếu cần sửa import hoặc API để compile với dependency hiện tại, thay đổi phải scoped và có lý do rõ.

`pubspec.yaml` sẽ được dựng từ import thực tế trong code. Nhóm package dự kiến:

- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_database`
- State/navigation/util: `flutter_bloc`, `get`, `shared_preferences`, `connectivity_plus`
- UI: `google_fonts`, `loading_animation_widget`, `flutter_rating_bar`, `syncfusion_flutter_maps`, `colorful_safe_area`, `flutter_keyboard_visibility`, `lottie`
- Device/API: `location`, `geocoding`, `image_picker`, `http`, `flutter_dotenv`
- Utility: `intl`, `uuid`

Version package sẽ chọn theo khả năng tương thích với Flutter SDK hiện tại, không cố đoán version cũ.

## Firebase Emulator

App vẫn dùng Firebase SDK thật, nhưng ở debug mode sẽ kết nối tới Firebase Emulator.

Service cần hỗ trợ trước:

- Firebase Auth Emulator cho email/password.
- Cloud Firestore Emulator cho collections chính: `users`, `cities`, `attractions`, `restaurants`, `trips`, `favorites`, `reviews`.
- Realtime Database Emulator nếu code `Home.dart` vẫn cần `firebase_database` trong luồng chính.

Android emulator host sẽ dùng `10.0.2.2`. Nếu chạy trên thiết bị Android thật, tài liệu sẽ ghi rõ cần đổi host sang IP LAN của máy chạy emulator.

Firebase initialization sẽ dùng `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`. Vì không có project cũ, file options trong vòng phục hồi sẽ dùng project id dev-only `travel-app-v2-dev` cho emulator. Khi cần production, người dùng tạo Firebase project mới và thay config bằng `flutterfire configure` hoặc `android/app/google-services.json` thật.

Google Sign-In trong dev sẽ không cố cấu hình OAuth thật. UI hoặc repository sẽ trả trạng thái "không hỗ trợ trong dev" thay vì crash.

## Assets

Khôi phục `assets/images/` bằng bộ asset mới miễn phí/open-license. Mục tiêu là build được, không crash, và giữ cảm giác app du lịch gần với bản cũ.

Nhóm asset cần có:

- background login/onboarding: `app bac.jpg`
- decorative login blocks: `Rectangle 1.png`, `Rectangle 1 loging.png`
- bottom navigation icons và selected variants
- favorite/star/location/add icons
- category icons: hotel, food/cafe, park/forest, attraction, gas
- weather icons: sunny, cloudy, rain, partly cloudy, night variants, fallback `time-left.png`
- chat/send icons
- checklist lottie hoặc replacement rõ license

File name sẽ ưu tiên giữ đúng path hiện tại để giảm sửa UI rộng. Mọi asset lấy từ nguồn ngoài phải ghi vào `assets/ATTRIBUTION.md` với tên file, nguồn, license, và URL nếu có. Nếu không xác minh được license, không dùng asset đó.

## Sửa Critical Logic

Các sửa trong `lib/` tập trung vào lỗi chặn luồng chính:

1. `TripRepo` không giữ `FirebaseAuth.instance.currentUser` trong field global. Mỗi method đọc user hiện tại tại thời điểm gọi và trả lỗi có kiểm soát nếu chưa đăng nhập.
2. Các query detail như city, attraction, restaurant không dùng `query.docs[0]` khi chưa kiểm tra empty. Không tìm thấy dữ liệu phải có fallback hoặc typed error.
3. Review attraction sửa lỗi thứ tự tham số delete. API repository nên dùng named parameters để tránh gọi nhầm.
4. Review restaurant thống nhất schema. Khuyến nghị dùng subcollection `reviews` vì code đọc và xóa hiện đã theo hướng này. Field `reviews` trên document cha chỉ giữ nếu UI hiện tại bắt buộc.
5. `DirectionsRepo` xử lý thiếu `currentLocation`, thiếu `GOOGLE_MAPS_API_KEY`, hoặc Directions API trả `routes` rỗng bằng kết quả rỗng/error state thay vì crash.
6. Firebase startup connect emulator trong debug mode sau khi initialize.
7. Google Sign-In dev path disable rõ ràng thay vì cố gọi cấu hình thiếu.

Các thay đổi này không bao gồm refactor kiến trúc lớn. Nếu một file quá lớn như `locationDetails.dart` cần chỉnh, chỉ chỉnh phần liên quan để app chạy và giảm rủi ro regression.

## Tài Liệu

Thêm các tài liệu vận hành:

- `docs/firebase-emulator.md`: cách cài Firebase CLI, khởi động emulator, service cần bật, host Android emulator, seed data tối thiểu nếu cần.
- `docs/android-recovery.md`: cách chạy `flutter pub get`, `flutter analyze`, `flutter build apk --debug`, và cách thay Firebase config thật sau này.
- `assets/ATTRIBUTION.md`: nguồn và license của asset mới.

## Acceptance Criteria

Phục hồi được coi là đạt khi:

1. `flutter pub get` chạy thành công.
2. `flutter analyze` không còn lỗi compile blocker.
3. `flutter build apk --debug` thành công.
4. Firebase Emulator chạy được cho Auth và Firestore.
5. App Android debug kết nối emulator trong debug mode.
6. Người dùng có thể đăng ký và đăng nhập bằng email/password trong emulator.
7. Sau login, app mở được màn home/navigation chính.
8. Mọi asset local được tham chiếu trong luồng chính tồn tại và render được.
9. Smoke test qua các thao tác chính không crash: mở danh sách/chi tiết với seed data, thêm/xóa favorite, tạo trip, thêm/xóa review.
10. Tài liệu phục hồi Android và Firebase Emulator có đủ bước để chạy lại trên máy khác.

## Rủi Ro Và Giảm Thiểu

- **Dependency version drift:** chọn version tương thích Flutter hiện tại và sửa compile errors theo API mới.
- **Thiếu schema Firestore thật:** dùng seed data tối thiểu cho emulator, document hóa collection/field cần có.
- **Asset licensing không rõ:** chỉ dùng nguồn license rõ hoặc tạo replacement đơn giản.
- **Google Sign-In phụ thuộc OAuth thật:** disable trong dev để không chặn phục hồi.
- **UI lớn, nhiều file legacy:** sửa scoped theo compile/runtime blocker, không refactor rộng trong vòng đầu.

## Thứ Tự Triển Khai Dự Kiến

1. Recreate Flutter Android scaffold và `pubspec.yaml`.
2. Add assets open-license và attribution.
3. Add Firebase Emulator config/documentation.
4. Fix compile blockers.
5. Fix critical runtime logic trong repos/BLoCs liên quan.
6. Add minimal seed/dev instructions.
7. Run analyzer, debug build, and smoke checks.
