# Cách chạy CineBook trên Chrome

File này hướng dẫn chạy app Flutter bằng Chrome/web và các bước xử lý khi Flutter không nhận Chrome.

## 1. Yêu cầu cần có

- Flutter SDK đã cài và có trong `PATH`.
- Google Chrome đã cài trên máy.
- Windows Developer Mode đã bật nếu project dùng plugin cần symlink.
- Backend `movie_mobile` đang chạy ở port `3000`.
- MySQL và database backend đã setup theo hướng dẫn `.env` của backend.

Kiểm tra môi trường:

```powershell
flutter doctor -v
flutter devices
```

Nếu Flutter báo lỗi:

```txt
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

Mở phần cài đặt Developer Mode bằng lệnh:

```powershell
start ms-settings:developers
```

Sau đó bật `Developer Mode`, đóng terminal, mở lại terminal mới rồi chạy lại lệnh Flutter.

Kết quả đúng cần thấy thiết bị dạng:

```txt
Chrome (web)      • chrome  • web-javascript
```

## 2. Bật hỗ trợ web cho Flutter

Chạy trong terminal:

```powershell
flutter config --enable-web
flutter doctor -v
flutter devices
```

Nếu vẫn không thấy Chrome, xem phần 5.

## 3. Chạy backend trước

Mở terminal ở folder backend:

```powershell
cd C:\Users\trung\Desktop\PRM\movie_mobile
npm install
npm run db:setup
npm start
```

Backend cần chạy tại:

```txt
http://localhost:3000
```

## 4. Chạy Flutter trên Chrome

Mở terminal khác ở folder app:

```powershell
cd C:\Users\trung\Desktop\PRM\CineBook_App
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

Lưu ý:

- Khi chạy bằng Chrome trên cùng máy tính, dùng `http://localhost:3000`.
- Khi chạy Android emulator, app mặc định dùng `http://10.0.2.2:3000`.
- Khi chạy điện thoại thật, dùng IP LAN của máy tính, ví dụ:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

## 5. Fix lỗi Flutter không nhận Chrome

Nếu `flutter devices` không hiện Chrome, kiểm tra Chrome có ở đường dẫn mặc định không:

```powershell
Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
Test-Path "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
```

Nếu Chrome nằm ở `C:\Program Files`, set biến môi trường:

```powershell
setx CHROME_EXECUTABLE "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

Nếu Chrome nằm trong user local:

```powershell
setx CHROME_EXECUTABLE "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
```

Sau đó đóng terminal, mở lại terminal mới và chạy:

```powershell
flutter doctor -v
flutter devices
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

## 6. Nếu vẫn không chạy được

Thử chạy bằng Edge để kiểm tra web target:

```powershell
flutter run -d edge --dart-define=API_BASE_URL=http://localhost:3000
```

Hoặc build web để kiểm tra project có lỗi compile không:

```powershell
flutter build web --debug
```

Nếu build web OK nhưng Chrome không hiện trong `flutter devices`, lỗi nằm ở cấu hình Chrome/Flutter trên máy đó, không phải code app.
