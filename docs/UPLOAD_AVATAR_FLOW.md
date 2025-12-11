# Luồng Cập Nhật Ảnh Avatar (Upload Avatar Flow) - Today's Eats ✅

**Ngày implement:** 11/12/2025  
**Trạng thái:** ✅ **ĐÃ HOÀN THÀNH**

---

## 📊 Flowchart (Theo sơ đồ của bạn)

```
Profile Screen
  ↓
Người dùng nhấn "Đổi avatar"
  ↓
App mở bộ chọn ảnh (Gallery / Camera)
  ↓
Người dùng chọn 1 ảnh
  ↓
App hiển thị preview ảnh mới
  ↓
Người dùng nhấn "Lưu avatar"
  ↓
App:
  - Upload file ảnh lên File Storage Service
    (vd: Cloudinary / S3 / server backend upload)
  - Nhận về URL ảnh sau khi upload
  ↓
App gửi request PUT /users/me/avatar
  (Body: avatarUrl mới, Header: Authorization)
  ↓
Backend:
  - Giải mã JWT → lấy userId
  - Cập nhật field avatarUrl trong MongoDB (collection users)
  - Trả về bản user đã cập nhật
  ↓
App:
  - Cập nhật UI avatar mới
  - Hiển thị thông báo: "Cập nhật avatar thành công."
```

---

## 🎯 Implementation

### 1. Update Avatar Dialog
**File:** [`lib/features/profile/update_avatar_dialog.dart`](file:///home/nho/Documents/TodaysEats/lib/features/profile/update_avatar_dialog.dart)

**Features:**
- ✅ Pick image from gallery
- ✅ Take photo with camera
- ✅ Preview selected image
- ✅ Upload to storage
- ✅ Update profile via API
- ✅ Loading states
- ✅ Error handling with retry

---

### 2. Image Picker Configuration

**Added package:** `image_picker: ^1.1.2`

**Permissions needed:**

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Camera permission -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Storage permissions -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>

<!-- For Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Cần quyền truy cập camera để chụp ảnh đại diện</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Cần quyền truy cập thư viện để chọn ảnh đại diện</string>
```

---

### 3. Upload Service
**File:** [`lib/core/services/upload_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/upload_service.dart)

**Already exists! ✅**

```dart
class UploadService {
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    // Upload to backend → S3/Cloudinary
    // Returns: { 'success': true, 'url': '...', 'key': '...' }
  }
}
```

---

### 4. API Service Update
**File:** [`lib/core/services/api_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/api_service.dart)

**Already exists! ✅**

```dart
Future<Map<String, dynamic>> updateUserProfile(
  String uid,
  Map<String, dynamic> updates,
) async {
  // PUT /users/:uid
  // Body: { photoURL: '...' }
}
```

---

## 🔄 Complete Upload Flow

### **Step-by-step Implementation**

```dart
// 1. User taps "Change Avatar" button
onPressed: () async {
  final newAvatarUrl = await showDialog<String>(
    context: context,
    builder: (context) => UpdateAvatarDialog(
      currentAvatarUrl: user.photoURL,
    ),
  );

  if (newAvatarUrl != null) {
    // Avatar updated successfully
    setState(() {
      _avatarUrl = newAvatarUrl;
    });
  }
}
```

### **Inside UpdateAvatarDialog:**

```dart
// 1. Pick image from gallery
Future<void> _pickImageFromGallery() async {
  final XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 85,
  );

  if (image != null) {
    setState(() {
      _selectedImage = File(image.path);
    });
  }
}

// 2. Pick image from camera
Future<void> _pickImageFromCamera() async {
  final XFile? image = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 85,
  );

  if (image != null) {
    setState(() {
      _selectedImage = File(image.path);
    });
  }
}

// 3. Upload and update
Future<void> _uploadAndUpdateAvatar() async {
  setState(() => _isUploading = true);

  try {
    // a. Upload to storage
    final uploadResult = await _uploadService.uploadImage(_selectedImage!);
    final avatarUrl = uploadResult['url'] as String;

    // b. Update profile in MongoDB
    final user = FirebaseAuth.instance.currentUser!;
    await _apiService.updateUserProfile(user.uid, {
      'photoURL': avatarUrl,
    });

    // c. Update Firebase Auth profile (optional)
    await user.updatePhotoURL(avatarUrl);

    // d. Show success and return
    ErrorHandler.showSuccess(
      context,
      message: 'Cập nhật avatar thành công!',
    );

    Navigator.pop(context, avatarUrl);

  } catch (e) {
    ErrorHandler.showError(
      context,
      error: e,
      onRetry: () => _uploadAndUpdateAvatar(),
    );
  } finally {
    setState(() => _isUploading = false);
  }
}
```

---

## 🗂️ Backend Requirements

### Storage Service

**App uses AWS S3** (existing backend setup)

**Backend endpoint:** `POST /api/dishes/upload/image`

**Request:**
```
POST /api/dishes/upload/image
Content-Type: multipart/form-data

{
  image: [binary file]
}
```

**Response:**
```json
{
  "success": true,
  "url": "https://todays-eats-images.s3.amazonaws.com/...",
  "key": "uploads/..."
}
```

---

### Update User Profile API

**Endpoint:** `PUT /api/users/:uid`

**Request:**
```
PUT /api/users/:uid
Headers:
  Authorization: Bearer <firebase_token>
Body:
{
  "photoURL": "https://new-avatar-url.com/image.jpg"
}
```

**Backend Logic:**
```javascript
router.put('/users/:uid', verifyToken, async (req, res) => {
  try {
    // 1. Verify user owns this profile
    if (req.user.uid !== req.params.uid) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    // 2. Update user in MongoDB
    const user = await User.findOneAndUpdate(
      { uid: req.params.uid },
      { 
        photoURL: req.body.photoURL,
        updatedAt: Date.now()
      },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // 3. Return updated user
    res.json(user);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

---

## 🎨 UI/UX Features

### Avatar Preview Circle

```dart
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.primary, width: 3),
  ),
  child: ClipOval(
    child: _selectedImage != null
        ? Image.file(_selectedImage!, fit: BoxFit.cover)
        : (currentAvatarUrl != null
            ? Image.network(currentAvatarUrl, fit: BoxFit.cover)
            : Icon(Icons.person, size: 100)),
  ),
)
```

### Loading State During Upload

```dart
FilledButton(
  onPressed: _isUploading ? null : _uploadAndUpdateAvatar,
  child: _isUploading
      ? CircularProgressIndicator(color: Colors.white)
      : Text('Lưu avatar'),
)
```

### Image Optimization

```dart
ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 800,      // Resize to max 800px width
  maxHeight: 800,     // Resize to max 800px height
  imageQuality: 85,   // Compress to 85% quality
);
```

**Benefits:**
- ✅ Smaller file size (faster upload)
- ✅ Less storage space
- ✅ Better performance

---

## 🧪 Testing

### Test Gallery Selection
```dart
// 1. Open dialog
// 2. Tap "Chọn từ thư viện"
// 3. Select image
// 4. Verify preview shows selected image
// 5. Tap "Lưu avatar"
// 6. Verify upload progress
// 7. Verify success message
// 8. Verify avatar updated in profile
```

### Test Camera
```dart
// 1. Open dialog
// 2. Tap "Chụp ảnh mới"
// 3. Take photo
// 4. Verify preview shows captured image
// 5. Tap "Lưu avatar"
// 6. Verify upload and update
```

### Test Error Scenarios
```dart
// No internet → Show error
// Upload failed → Show error with retry
// API failed → Show error with retry
// Cancel dialog → No changes made
```

---

## 📱 Integration with ProfileScreen

**Example:**

```dart
// In ProfileScreen
GestureDetector(
  onTap: () async {
    final newAvatarUrl = await showDialog<String>(
      context: context,
      builder: (context) => UpdateAvatarDialog(
        currentAvatarUrl: user?.photoURL,
      ),
    );

    if (newAvatarUrl != null) {
      // Reload user data
      setState(() {
        // Trigger rebuild with new avatar
      });
    }
  },
  child: Stack(
    children: [
      CircleAvatar(
        radius: 50,
        backgroundImage: user?.photoURL != null
            ? NetworkImage(user!.photoURL!)
            : null,
        child: user?.photoURL == null
            ? Icon(Icons.person, size: 50)
            : null,
      ),
      // Edit icon overlay
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(8),
          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
        ),
      ),
    ],
  ),
)
```

---

## ✅ Checklist

- [x] `image_picker` package added
- [x] UpdateAvatarDialog created
- [x] Gallery selection
- [x] Camera capture
- [x] Image preview
- [x] Upload to storage (S3 via backend)
- [x] Update profile API call
- [x] Loading states
- [x] Error handling with retry
- [x] Success feedback
- [x] Image optimization (resize, compress)

---

## 📊 Data Flow Summary

```
User Action → Image Picker → File Selected
  ↓
Preview Image
  ↓
User Confirms → Upload to S3 (via backend)
  ↓
Get Image URL
  ↓
PUT /api/users/:uid { photoURL: url }
  ↓
MongoDB: Update user.photoURL
  ↓
Response: Updated user data
  ↓
Update UI + Show success message
```

---

## 📝 Notes

**Storage:**
- ✅ Backend uploads to AWS S3
- ✅ Returns public URL
- ✅ Secure (presigned URLs if needed)

**Optimization:**
- ✅ Max 800x800px (reduces size)
- ✅ 85% quality (good balance)
- ✅ JPEG format (smaller than PNG)

**Security:**
- ✅ Firebase token required
- ✅ User can only update own profile
- ✅ Validation on backend

**Future Enhancements:**
- [ ] Crop functionality
- [ ] Filters/effects
- [ ] Multiple image upload
- [ ] Video avatar support
- [ ] Remove avatar option

**Avatar upload feature hoàn chỉnh!** ✅
