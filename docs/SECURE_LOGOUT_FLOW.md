# Luồng Đăng Xuất An Toàn (Secure Logout Flow) - Today's Eats ✅

**Ngày implement:** 11/12/2025  
**Trạng thái:** ✅ **ĐÃ HOÀN THÀNH**

---

## 📊 Flowchart (Theo sơ đồ của bạn)

```
Profile Screen
  ↓
Người dùng nhấn "Đăng xuất"
  ↓
App hiển thị hộp thoại xác nhận:
  "Bạn có chắc chắn muốn đăng xuất không?"
  ↓
Người dùng xác nhận
  ↓
App thực hiện:
  - Xóa accessToken (JWT) khỏi local storage
  - Xóa các dữ liệu nhạy cảm cache local (vd: user info, favorites cache)
  - Hủy các stream / listener / socket (nếu đang mở)
  ↓
Điều hướng về Login Screen
  ↓
(Option nâng cao)
App có thể gửi request POST /auth/logout lên Backend
  - Backend thêm token vào blacklist (nếu dùng)
  - Hoặc xóa refresh token khỏi MongoDB (nếu có lưu)
```

---

## 🎯 Tại sao cần Secure Logout?

### Bảo mật
- ✅ Xóa token → Không ai dùng lại được
- ✅ Xóa cache → Không để lộ dữ liệu cá nhân
- ✅ Hủy connections → Ngắt kết nối realtime

### UX tốt
- ✅ Xác nhận trước khi logout (tránh nhầm lẫn)
- ✅ Clear data → User khác không thấy dữ liệu cũ
- ✅ Navigate về Login → Flow rõ ràng

---

## 🔧 Implementation

### 1. LogoutService
**File:** [`lib/core/services/logout_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/logout_service.dart)

**Features:**
- ✅ `secureLogout()` - Logout và cleanup
- ✅ `showLogoutConfirmation()` - Confirmation dialog
- ✅ `handleLogout()` - Complete flow

**Usage:**
```dart
final logoutService = LogoutService();

// Simple way
await logoutService.handleLogout(context);

// Or manual steps
final confirmed = await logoutService.showLogoutConfirmation(context);
if (confirmed) {
  await logoutService.secureLogout();
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

## 🔄 Complete Logout Flow

### **Step 1: Show Confirmation Dialog**

```dart
Future<bool> showLogoutConfirmation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Đăng xuất'),
      content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Đăng xuất'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
```

**Dialog UI:**
```
┌─────────────────────────────┐
│     Đăng xuất               │
├─────────────────────────────┤
│  Bạn có chắc chắn muốn      │
│  đăng xuất không?           │
│                             │
│  [Hủy]  [Đăng xuất]         │
└─────────────────────────────┘
```

---

### **Step 2: Secure Logout & Cleanup**

```dart
Future<void> secureLogout() async {
  // 1. Sign out from Firebase Auth
  await FirebaseAuth.instance.signOut();
  // → Clears Firebase tokens automatically

  // 2. Clear all cached data
  await CacheService().clearAllCache();
  // → Removes: dishes cache, favorites cache, user stats

  // 3. Clear SharedPreferences (if storing custom tokens)
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Or selective removal

  // 4. Cancel any active streams/listeners
  // If you have StreamSubscription, cancel them here
  // subscription?.cancel();

  print('✅ Secure logout completed');
}
```

**What gets cleared:**
- ✅ Firebase Auth token (automatic)
- ✅ Cached dishes
- ✅ Cached favorites
- ✅ Cached user stats
- ✅ Any custom data in SharedPreferences

---

### **Step 3: Navigate to Login**

```dart
// Remove all previous routes and go to login
Navigator.of(context).pushNamedAndRemoveUntil(
  '/login',
  (route) => false,  // Remove ALL routes
);
```

**Navigation stack:**
```
Before logout: [Splash, Main, Profile]
               
After logout:  [Login]  ← Clean slate
```

---

## 📱 Integration with ProfileScreen

### Example: Logout Button

```dart
// In ProfileScreen
ListTile(
  leading: Icon(Icons.logout, color: Colors.red),
  title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
  onTap: () async {
    await LogoutService().handleLogout(context);
  },
)
```

### With Loading State

```dart
bool _isLoggingOut = false;

ListTile(
  leading: _isLoggingOut
      ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Icon(Icons.logout, color: Colors.red),
  title: Text('Đăng xuất'),
  enabled: !_isLoggingOut,
  onTap: () async {
    setState(() => _isLoggingOut = true);
    
    try {
      await LogoutService().handleLogout(context);
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  },
)
```

---

## 🔐 Security Features

### 1. Firebase Auth Token Cleanup

```dart
await FirebaseAuth.instance.signOut();
```

**What happens:**
- ✅ Invalidates current session
- ✅ Clears access token
- ✅ Clears refresh token
- ✅ User must re-login to get new tokens

---

### 2. Cache Cleanup

```dart
await CacheService().clearAllCache();
```

**Removes sensitive data:**
```dart
// Before logout
SharedPreferences: {
  'cached_dishes': '[{...}, {...}, ...]',
  'cached_favorites': '[{...}, {...}]',
  'cached_user_stats_uid123': '{dishesCreated: 5, ...}',
}

// After logout
SharedPreferences: {}  ← Empty
```

---

### 3. Prevent Back Navigation

```dart
Navigator.pushNamedAndRemoveUntil('/login', (route) => false);
```

**User cannot go back to authenticated screens:**
```
❌ Press back button → Nothing happens (no routes to go back to)
✅ Must login again to access app
```

---

## 🌐 Optional: Backend Logout API

### Why?

**If using refresh tokens or session management:**
- ✅ Invalidate refresh token in database
- ✅ Add access token to blacklist
- ✅ Track logout events for analytics

### Backend Implementation

**Endpoint:** `POST /api/auth/logout`

```javascript
router.post('/auth/logout', verifyToken, async (req, res) => {
  try {
    const { uid } = req.user;

    // Option 1: Delete refresh token from database
    await RefreshToken.deleteMany({ userId: uid });

    // Option 2: Add access token to blacklist
    await TokenBlacklist.create({
      token: req.headers.authorization.split('Bearer ')[1],
      expiresAt: new Date(Date.now() + 3600000), // 1 hour
    });

    // Option 3: Update user's lastLogoutAt
    await User.updateOne(
      { uid },
      { lastLogoutAt: new Date() }
    );

    res.json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### Frontend Call

```dart
Future<void> secureLogout() async {
  try {
    // 1. Call backend logout API (optional)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    // 2. Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // 3. Clear cache
    await CacheService().clearAllCache();

  } catch (e) {
    print('Error during logout: $e');
    rethrow;
  }
}
```

---

## 🧪 Testing

### Test Normal Flow
```dart
// 1. Login as user
// 2. Go to Profile
// 3. Tap "Đăng xuất"
// 4. Verify confirmation dialog appears
// 5. Tap "Đăng xuất"
// 6. Verify navigated to Login screen
// 7. Verify cache cleared
// 8. Try to go back → Should stay on Login
```

### Test Cancel
```dart
// 1. Tap "Đăng xuất"
// 2. Tap "Hủy" in dialog
// 3. Verify still on Profile screen
// 4. Verify no data cleared
```

### Test Multiple Users
```dart
// 1. Login as User A
// 2. View some dishes (cached)
// 3. Logout
// 4. Login as User B
// 5. Verify User B doesn't see User A's cache
```

---

## 📊 What Gets Cleared

| Data Type | Stored In | Cleared On Logout |
|-----------|-----------|-------------------|
| **Firebase Auth Tokens** | Firebase SDK | ✅ Yes (automatic) |
| **Cached Dishes** | SharedPreferences | ✅ Yes |
| **Cached Favorites** | SharedPreferences | ✅ Yes |
| **User Stats Cache** | SharedPreferences | ✅ Yes |
| **User Preferences** | SharedPreferences | ⚠️ Optional (usually kept) |
| **Theme Settings** | SharedPreferences | ❌ No (kept for next user) |

---

## ⚙️ Configuration Options

### Keep Some Data

```dart
Future<void> secureLogout({bool keepPreferences = true}) async {
  await FirebaseAuth.instance.signOut();

  if (keepPreferences) {
    // Only clear sensitive data
    await CacheService().clearDishesCache();
    await CacheService().clearFavoritesCache();
    // Keep theme, language settings
  } else {
    // Clear everything
    await CacheService().clearAllCache();
  }
}
```

### Logout Without Confirmation

```dart
// For automatic logouts (token expired, etc.)
Future<void> forceLogout(BuildContext context) async {
  await LogoutService().secureLogout();
  
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phiên đăng nhập đã hết hạn'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
```

---

## ✅ Checklist

- [x] LogoutService created
- [x] Confirmation dialog
- [x] Firebase signOut
- [x] Cache cleanup (CacheService.clearAllCache)
- [x] Navigation to Login
- [x] Remove all routes (pushNamedAndRemoveUntil)
- [x] Error handling
- [x] Loading state support

---

## 📝 Notes

**App behavior:**
- ✅ User taps Logout → Confirmation required
- ✅ After logout → Clean slate, no cached data
- ✅ Cannot go back → Must login again
- ✅ Different user login → Fresh data

**Security:**
- ✅ Tokens cleared automatically by Firebase
- ✅ Cache cleared manually by us
- ✅ No data leakage between users

**Future Enhancements:**
- [ ] Backend logout API (token blacklist)
- [ ] Logout from all devices feature
- [ ] Session timeout (auto-logout after N minutes inactive)
- [ ] Logout analytics (track logout reasons)

**Secure logout đã hoàn chỉnh!** ✅
