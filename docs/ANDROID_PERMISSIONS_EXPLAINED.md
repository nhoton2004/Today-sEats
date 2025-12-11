# Android Permissions - Giải thích Chi tiết ✅

## 📱 Permissions là gì?

**Permissions** (Quyền truy cập) là các quyền mà app Android cần xin phép người dùng để truy cập vào:
- 📷 Camera
- 📁 Storage (bộ nhớ)
- 📍 Location (vị trí)
- 🎤 Microphone (mic)
- 📞 Phone calls
- ...và nhiều tính năng khác

---

## 🎯 Tại sao cần Permissions?

### Bảo mật & Quyền riêng tư
- ✅ Người dùng biết app sử dụng những gì
- ✅ Người dùng có quyền từ chối
- ✅ Bảo vệ dữ liệu cá nhân

### Ví dụ
```
App muốn chụp ảnh avatar
→ Cần quyền CAMERA
→ User cho phép ✅
→ App có thể mở camera
```

---

## 📋 Permissions đã thêm cho Upload Avatar

### File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Camera permission - Để chụp ảnh -->
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <!-- Storage permissions - Để đọc/ghi file ảnh -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"/>
    
    <!-- For Android 13+ - Chỉ đọc ảnh -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    
    <!-- Internet - Để upload lên server -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

---

## 🔍 Giải thích từng Permission

### 1. CAMERA
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```
- **Công dụng:** Mở camera để chụp ảnh
- **Khi nào cần:** User nhấn "Chụp ảnh mới" trong upload avatar
- **User sẽ thấy:** "Today's Eats muốn truy cập camera của bạn"

---

### 2. READ_EXTERNAL_STORAGE
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```
- **Công dụng:** Đọc file ảnh từ thư viện (Gallery)
- **Khi nào cần:** User nhấn "Chọn từ thư viện"
- **User sẽ thấy:** "Today's Eats muốn truy cập ảnh và phương tiện của bạn"

---

### 3. WRITE_EXTERNAL_STORAGE
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
```
- **Công dụng:** Ghi file vào bộ nhớ (nếu cần)
- **maxSdkVersion="32":** Chỉ áp dụng cho Android 12 trở xuống
- **Android 13+:** Không cần permission này nữa

---

### 4. READ_MEDIA_IMAGES (Android 13+)
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```
- **Công dụng:** Đọc ảnh (thay thế READ_EXTERNAL_STORAGE trên Android 13+)
- **Chi tiết hơn:** Chỉ truy cập ảnh, không phải tất cả files
- **Bảo mật tốt hơn:** User biết app chỉ truy cập ảnh

---

### 5. INTERNET
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
- **Công dụng:** Kết nối Internet
- **Khi nào cần:** Upload ảnh lên server, gọi API
- **Không cần xin phép user:** Tự động có quyền

---

## 🎬 Runtime Permissions Flow

### Trên Android 6.0+ (API 23+)

App phải **xin phép lúc runtime** (khi đang chạy), không phải lúc cài đặt.

**Flow:**

```
1. User tap "Chụp ảnh" hoặc "Chọn từ gallery"
   ↓
2. App check: Đã có permission chưa?
   ├─ Có → Mở camera/gallery ngay
   └─ Chưa → Hiển thị dialog xin phép
   ↓
3. User thấy dialog:
   "Today's Eats muốn truy cập camera"
   [Từ chối] [Cho phép]
   ↓
4. User chọn:
   ├─ Cho phép → App mở camera ✅
   └─ Từ chối → Hiển thị error ❌
```

---

## 📱 User Experience

### Khi user mở camera lần đầu:

**Dialog hiển thị:**
```
┌─────────────────────────────────┐
│  Allow Today's Eats to access   │
│  your camera?                    │
│                                  │
│  [Don't allow]  [Allow]          │
└─────────────────────────────────┘
```

**Tiếng Việt (Android tiếng Việt):**
```
┌─────────────────────────────────┐
│  Cho phép Today's Eats truy cập │
│  camera của bạn?                 │
│                                  │
│  [Từ chối]  [Cho phép]           │
└─────────────────────────────────┘
```

---

## 🛠️ Flutter xử lý tự động

**image_picker package** tự động xin permissions!

```dart
final XFile? image = await ImagePicker().pickImage(
  source: ImageSource.camera,  // ← Tự động xin CAMERA permission
);

final XFile? image2 = await ImagePicker().pickImage(
  source: ImageSource.gallery,  // ← Tự động xin STORAGE permission
);
```

**Bạn KHÔNG cần code thêm** để xin permission. Package lo hết!

---

## ⚠️ Nếu user từ chối permission?

### App phải handle gracefully:

```dart
try {
  final image = await ImagePicker().pickImage(...);
  
  if (image == null) {
    // User canceled or permission denied
    ErrorHandler.showWarning(
      context,
      message: 'Cần quyền truy cập camera/thư viện để chọn ảnh',
    );
  }
} catch (e) {
  ErrorHandler.showError(
    context,
    error: e,
    customMessage: 'Không thể mở camera. Vui lòng cấp quyền trong Settings.',
  );
}
```

---

## 📊 Permission Levels

### Normal Permissions (Tự động có)
- ✅ INTERNET
- ✅ ACCESS_NETWORK_STATE
- ✅ VIBRATE

**Không cần xin user!**

### Dangerous Permissions (Phải xin user)
- ⚠️ CAMERA
- ⚠️ READ_EXTERNAL_STORAGE
- ⚠️ WRITE_EXTERNAL_STORAGE
- ⚠️ READ_MEDIA_IMAGES
- ⚠️ LOCATION
- ⚠️ MICROPHONE

**Phải xin lúc runtime!**

---

## 🔄 Android Version Differences

| Android Version | Storage Permission |
|-----------------|-------------------|
| **Android 12 và cũ hơn** | `READ_EXTERNAL_STORAGE` + `WRITE_EXTERNAL_STORAGE` |
| **Android 13+ (API 33+)** | `READ_MEDIA_IMAGES` (chi tiết hơn) |

**App của bạn support cả 2!** ✅

---

## 🧪 Testing Permissions

### Test trên emulator:

1. **Lần đầu mở camera:**
   - Dialog xin phép hiện ra
   - Tap "Allow"
   - Camera mở ✅

2. **Lần sau:**
   - Không hỏi nữa (đã có permission)
   - Camera mở trực tiếp ✅

3. **Test từ chối:**
   - Tap "Don't allow"
   - App handle error ✅
   - Người dùng có thể vào Settings để cấp lại

---

## 🎯 Best Practices

### 1. Giải thích trước khi xin

```dart
// Show explanation dialog first
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Cần quyền truy cập camera'),
    content: Text('Để chụp ảnh đại diện, app cần quyền sử dụng camera.'),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          // Then request permission
        },
        child: Text('OK'),
      ),
    ],
  ),
);
```

### 2. Cung cấp lựa chọn thay thế

```dart
// If camera denied → suggest gallery
if (cameraDenied) {
  showDialog(...
    content: Text('Không có quyền camera. Bạn có thể chọn ảnh từ thư viện.'),
  );
}
```

### 3. Link đến Settings nếu bị từ chối vĩnh viễn

```dart
import 'package:permission_handler/permission_handler.dart';

if (await Permission.camera.isPermanentlyDenied) {
  // Show dialog with button to open Settings
  openAppSettings();
}
```

---

## 📝 Summary

**Đã thêm vào AndroidManifest.xml:**
- ✅ CAMERA - Chụp ảnh
- ✅ READ_EXTERNAL_STORAGE - Đọc ảnh từ gallery
- ✅ WRITE_EXTERNAL_STORAGE - Ghi file (Android ≤12)
- ✅ READ_MEDIA_IMAGES - Đọc ảnh (Android ≥13)
- ✅ INTERNET - Upload lên server

**image_picker tự động:**
- ✅ Xin permissions khi cần
- ✅ Hiển thị dialog cho user
- ✅ Handle user response

**Bạn chỉ cần:**
- ✅ Thêm permissions vào manifest (đã làm rồi ✅)
- ✅ Handle case user từ chối (trong UpdateAvatarDialog)

**App sẵn sàng upload avatar!** 🚀
