# 🔒 Security Policy

## Reporting a Vulnerability

**KHÔNG tạo public issue** cho lỗ hổng bảo mật. Gửi qua GitHub profile của maintainer.

Bao gồm:
- Mô tả lỗ hổng + các bước tái hiện
- Mức độ ảnh hưởng
- Đề xuất fix (nếu có)

Phản hồi trong vòng **7 ngày**.

## Best Practices

- **Không commit** `android/app/google-services.json` thật vào repo.
- `google-services.json` cho production nên được mount qua CI secret / download từ Firebase Console.
- `.env` chỉ chứa key dev; nếu commit nhầm → **rotate key ngay**.
- Bật App Check cho production Firebase.
- Cấu hình Firestore Security Rules chặt chẽ.
