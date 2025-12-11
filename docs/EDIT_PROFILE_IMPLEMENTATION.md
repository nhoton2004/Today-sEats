# Chức năng Edit Profile - Today's Eats

**Ngày tạo:** 11/12/2025  
**Trạng thái:** ✅ ĐÃ IMPLEMENT

---

## 📝 Tóm tắt

Đã thêm chức năng chỉnh sửa thông tin cá nhân cho người dùng:
- ✅ Màn hình EditProfileScreen
- ✅ API updateUserProfile
- ✅ Integration với ProfileScreen
- ⚠️ **Cần backend API endpoint:** `PUT /api/users/:uid`

---

## 🎨 UI Components

### EditProfileScreen

**File:** [`lib/features/profile/edit_profile_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/profile/edit_profile_screen.dart)

**Features:**
- ✅ Avatar preview (từ Firebase Auth photoURL)
- ✅ Email field (read-only, disabled)
- ✅ Display name field (editable)
- ✅ Save button với loading state
- ✅ Cancel button
- ✅ Form validation
- ✅ Success/Error SnackBar

**Validation Rules:**
- Tên không được trống
- Tên phải có ít nhất 2 ký tự

---

## 🔄 Workflow

```
1. User tap "Thông tin cá nhân" trong ProfileScreen
   ↓
2. Navigate → EditProfileScreen
   ↓
3. Load current user info:
   - displayName from Firebase Auth
   - photoURL from Firebase Auth
   - Email (read-only)
   ↓
4. User chỉnh sửa tên hiển thị
   ↓
5. User nhấn "Lưu thay đổi"
   ↓
6. Validate form
   ├─ Fail → Hiển thị lỗi validation
   └─ Success → Tiếp tục
   ↓
7. Update Firebase Auth:
   await user.updateDisplayName(newDisplayName)
   await user.reload()
   ↓
8. Update MongoDB:
   PUT /api/users/:uid
   body: { displayName: "..." }
   ↓
9. Success SnackBar
   ↓
10. Navigator.pop(context, true)
   ↓
11. ProfileScreen reload stats
   ↓
12. UI cập nhật tên mới
```

---

## 📡 API Integration

### Frontend API Service

**File:** [`lib/core/services/api_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/api_service.dart)

```dart
Future<Map<String, dynamic>> updateUserProfile({
  required String uid,
  String? displayName,
  String? photoURL,
}) async {
  try {
    final headers = await _getHeaders();
    final body = <String, dynamic>{};
    
    if (displayName != null) body['displayName'] = displayName;
    if (photoURL != null) body['photoURL'] = photoURL;

    final response = await http.put(
      Uri.parse('$baseUrl/users/$uid'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update user profile: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error updating user profile: $e');
  }
}
```

---

### Backend API Endpoint (CẦN IMPLEMENT)

**Endpoint:** `PUT /api/users/:uid`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <firebase_token> (optional)
```

**Request Body:**
```json
{
  "displayName": "New Name",
  "photoURL": "https://example.com/photo.jpg"
}
```

**Response (Success - 200):**
```json
{
  "message": "User profile updated successfully",
  "user": {
    "_id": "firebase_uid",
    "uid": "firebase_uid",
    "email": "user@example.com",
    "displayName": "New Name",
    "photoURL": "https://example.com/photo.jpg",
    "updatedAt": "2025-12-11T..."
  }
}
```

**Response (Error - 404):**
```json
{
  "error": "User not found"
}
```

---

### Backend Implementation Example (Node.js/Express)

```javascript
// routes/users.js

// PUT /api/users/:uid - Update user profile
router.put('/:uid', async (req, res) => {
  try {
    const { uid } = req.params;
    const { displayName, photoURL } = req.body;

    // Find user by Firebase UID
    const user = await User.findOne({ uid });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update fields
    const updateFields = {};
    if (displayName !== undefined) updateFields.displayName = displayName;
    if (photoURL !== undefined) updateFields.photoURL = photoURL;
    updateFields.updatedAt = new Date();

    // Update in MongoDB
    const updatedUser = await User.findOneAndUpdate(
      { uid },
      { $set: updateFields },
      { new: true } // Return updated document
    );

    res.json({
      message: 'User profile updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

---

## 🔧 Integration với ProfileScreen

**File:** [`lib/features/profile/profile_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart)

**Changes:**
```dart
import 'edit_profile_screen.dart'; // ✅ Added

// ...

_buildMenuItem(
  context,
  icon: Icons.person_outline,
  title: 'Thông tin cá nhân',
  onTap: () async {
    // ✅ Navigate to edit profile screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    
    // ✅ Reload user stats if profile was updated
    if (result == true) {
      _loadUserStats();
    }
  },
),
```

---

## ✅ Testing Checklist

### Manual Testing

- [ ] Mở ProfileScreen
- [ ] Tap "Thông tin cá nhân"
- [ ] EditProfileScreen hiển thị đúng
- [ ] Avatar hiển thị đúng (photoURL hoặc UI Avatars)
- [ ] Email hiển thị đúng và disabled
- [ ] Display name hiển thị giá trị hiện tại
- [ ] Validation: Tên trống → Hiển thị lỗi
- [ ] Validation: Tên < 2 ký tự → Hiển thị lỗi
- [ ] Nhập tên hợp lệ → Validation pass
- [ ] Nhấn "Lưu thay đổi" → Loading indicator
- [ ] Backend API success → SnackBar success
- [ ] Backend API fail → SnackBar error
- [ ] Sau save success → Pop về ProfileScreen
- [ ] ProfileScreen reload và hiển thị tên mới
- [ ] Nhấn "Hủy" → Pop về ProfileScreen (no save)

### API Testing

```bash
# Test update user profile
curl -X PUT http://localhost:5000/api/users/FIREBASE_UID \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "New Test Name"
  }'
```

---

## 🎯 Current Status

### ✅ Completed
- [x] EditProfileScreen UI
- [x] Form validation
- [x] Firebase Auth update (updateDisplayName)
- [x] API Service method (updateUserProfile)
- [x] ProfileScreen integration
- [x] Navigation + reload logic
- [x] Loading states
- [x] Error handling
- [x] Success feedback

### ⚠️ TODO - Backend
- [ ] Implement `PUT /api/users/:uid` endpoint
- [ ] Test endpoint với Postman/curl
- [ ] Verify MongoDB update
- [ ] Error handling trong backend

### 🚀 Future Enhancements
- [ ] Upload/change profile photo
- [ ] Add phone number field
- [ ] Add bio/description field
- [ ] Email verification flow
- [ ] Change password feature

---

## 📸 Screenshots Expected

### EditProfileScreen
```
┌─────────────────────────────────┐
│  ← Chỉnh sửa hồ sơ              │
├─────────────────────────────────┤
│                                 │
│         ┌─────────┐             │
│         │  [IMG]  │ 📷          │
│         └─────────┘             │
│     Nhấn để thay đổi ảnh        │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 📧 user@example.com     │   │ (disabled)
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 👤 John Doe            │   │ (editable)
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │    Lưu thay đổi         │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │        Hủy              │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

---

## 🔐 Security Considerations

1. **Firebase Auth:** 
   - `updateDisplayName()` chỉ update trong Firebase Auth
   - User đã authenticated qua `FirebaseAuth.instance.currentUser`

2. **MongoDB Update:**
   - Backend nên verify Firebase token
   - Chỉ cho user update profile của chính mình

3. **Input Validation:**
   - Frontend: Length validation
   - Backend: Sanitize input, validate format

---

## 📝 Notes

- ✅ **Firebase Auth** được update đầu tiên (displayName)
- ✅ **MongoDB** được update sau để sync data
- ✅ Nếu Firebase update fail → Không gọi MongoDB
- ✅ Nếu MongoDB fail → Rollback không cần thiết (Firebase đã update)
- ⚠️ **Backend endpoint cần được implement** để feature hoạt động đầy đủ

---

**Next Steps:**
1. Implement backend `PUT /api/users/:uid` endpoint
2. Test e2e flow
3. Add photo upload feature (future)
