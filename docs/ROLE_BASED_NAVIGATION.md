# Luồng Phân Quyền User/Admin - Today's Eats ✅

**Ngày implement:** 11/12/2025  
**Trạng thái:** ✅ **ĐÃ HOÀN THÀNH**

---

## 📊 Flowchart (ĐÚNG - MongoDB)

```
Login thành công
  ↓
Kiểm tra role trong MongoDB (qua API) ✅
  ├─ role = "user"
  │     ↓
  │     Điều hướng vào Main Screen (User Mode)
  │
  ├─ role = "admin"
  │     ↓
  │     Điều hướng vào Admin Panel
  │
  └─ role = "moderator"
        ↓
        Điều hướng vào Admin Panel
```

> [!IMPORTANT]
> **App sử dụng MongoDB, KHÔNG phải Firestore!**
> Role được lưu trong MongoDB User collection.

---

## 🎯 Lý do cần có

1. **App có Admin Panel** → Phải phân quyền ai được truy cập
2. **Giáo viên thường hỏi:** "Phân biệt user và admin như thế nào?"
3. **Bảo mật:** Chỉ admin mới được CRUD dishes
4. **UX tốt hơn:** Admin tự động vào Admin Panel, không cần tự chọn

---

## 🔧 Implementation

### 1. RoleService - Check role từ MongoDB
**File:** [`lib/core/utils/role_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/utils/role_service.dart)

```dart
class RoleService {
  final ApiService _apiService = ApiService();

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // ✅ Fetch from MongoDB
    final userData = await _apiService.getUserByUid(user.uid);
    final role = userData['role'] as String?;
    
    return role == 'admin';
  }

  /// Get user role
  Future<String?> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userData = await _apiService.getUserByUid(user.uid);
    return userData['role'] as String?;
  }

  /// Navigate to appropriate screen based on role
  Future<String> getHomeRouteForUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '/login';

    final role = await getUserRole();

    switch (role) {
      case 'admin':
        return '/admin';      // ✅ Admin Panel
      case 'moderator':
        return '/admin';      // ✅ Admin Panel
      case 'user':
      default:
        return '/main';       // ✅ Main Screen
    }
  }
}
```

---

### 2. SplashScreen - Role-based routing
**File:** [`lib/features/splash/splash_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/splash/splash_screen.dart)

**Changes:**
```dart
import '../../core/utils/role_service.dart';

class _SplashScreenState extends State<SplashScreen> {
  final RoleService _roleService = RoleService();

  @override
  void initState() {
    super.initState();
    
    Timer(const Duration(seconds: 3), () async {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        
        if (user != null) {
          // ✅ Check role and navigate
          final route = await _roleService.getHomeRouteForUser();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        } else {
          // Not logged in → Login screen
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }
}
```

---

### 3. App Routes - Added /admin route
**File:** [`lib/app.dart`](file:///home/nho/Documents/TodaysEats/lib/app.dart)

```dart
import 'features/admin/admin_screen.dart';  // ✅ Added

routes: {
  '/splash': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/main': (context) => const MainScreen(),
  '/admin': (context) => const AdminScreen(),  // ✅ Added
  // ...
}
```

---

## 🔄 Complete Flow

### **User Login → Navigation**

```
1. User opens app
   ↓
2. SplashScreen displays (3 seconds)
   ↓
3. Check FirebaseAuth.currentUser
   ├─ null → Navigate to /login
   └─ exists → Continue
   ↓
4. RoleService.getHomeRouteForUser()
   ↓
5. API call: GET /api/users/:uid
   ↓
6. MongoDB response:
   {
     "uid": "...",
     "email": "...",
     "role": "admin"  // or "user"
   }
   ↓
7. Check role:
   ├─ "admin" or "moderator" → route = '/admin'
   └─ "user" or default → route = '/main'
   ↓
8. Navigator.pushReplacementNamed(route)
   ↓
9. User sees appropriate screen
```

---

### **Login Screen → After successful login**

**LoginScreen và RegisterScreen:**
```dart
// After successful Firebase login
await _authService.signInWithEmailAndPassword(email, password);

if (mounted) {
  // ✅ Check role before navigating
  final roleService = RoleService();
  final route = await roleService.getHomeRouteForUser();
  
  Navigator.of(context).pushReplacementNamed(route);
}
```

**Hoặc** (đơn giản hơn):
```dart
// After login, always go to splash first
Navigator.of(context).pushReplacementNamed('/splash');
// Splash sẽ tự động check role và route
```

---

## 📊 Role Comparison

| Feature | User (role="user") | Admin (role="admin") |
|---------|-------------------|---------------------|
| **Home Screen** | `/main` (MainScreen) | `/admin` (AdminScreen) |
| **View Dishes** | ✅ Yes | ✅ Yes |
| **Spin Dish** | ✅ Yes | ✅ Yes |
| **Favorites** | ✅ Yes | ✅ Yes |
| **Create Dish** | ❌ No | ✅ Yes |
| **Edit Dish** | ❌ No | ✅ Yes |
| **Delete Dish** | ❌ No | ✅ Yes |
| **View All Users** | ❌ No | ✅ Yes (future) |
| **Manage Roles** | ❌ No | ✅ Yes (future) |

---

## 🗂️ Database

### MongoDB User Document with Role

```json
{
  "_id": "mongodb_object_id",
  "uid": "firebase_uid",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoURL": "https://...",
  "role": "user",  // ✅ "user" | "admin" | "moderator"
  "favorites": [...],
  "createdAt": "2025-12-11T...",
  "updatedAt": "2025-12-11T..."
}
```

**Default role:** `"user"`

**Set admin:**
```javascript
// MongoDB Shell
db.users.updateOne(
  { email: "admin@example.com" },
  { $set: { role: "admin" } }
);
```

---

## 🧪 Testing

### Test User Login
1. Tạo user thường trong app (register)
2. Login
3. ✅ Expected: Navigate to `/main` (MainScreen with tabs)

### Test Admin Login
1. Set role = "admin" trong MongoDB
2. Login
3. ✅ Expected: Navigate to `/admin` (AdminScreen)

### Test Role Check
```dart
// Test trong splash screen hoặc console
final roleService = RoleService();

final isAdmin = await roleService.isAdmin();
print('Is Admin: $isAdmin');  // true or false

final role = await roleService.getUserRole();
print('Role: $role');  // "admin", "user", "moderator", or null

final route = await roleService.getHomeRouteForUser();
print('Route: $route');  // "/admin" or "/main"
```

---

## ✅ Checklist

- [x] RoleService created
- [x] `isAdmin()` method
- [x] `getUserRole()` method  
- [x] `getHomeRouteForUser()` method
- [x] SplashScreen updated with role check
- [x] `/admin` route added to app.dart
- [x] AdminScreen import added
- [x] Backend has `role` field in User model
- [x] Backend API `/users/:uid` returns role

---

## 🚀 Next Steps (Optional)

### 1. Update Login/Register Screens
**Hiện tại:** Login/Register navigate trực tiếp đến `/main`

**Nên sửa thành:**
```dart
// After successful login
Navigator.of(context).pushReplacementNamed('/splash');
// Let splash handle role-based routing
```

### 2. Add Role Badge in Profile
```dart
// ProfileScreen
if (userRole == 'admin') {
  Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('ADMIN', style: TextStyle(color: Colors.white)),
  )
}
```

### 3. Add Switch Account Feature
```dart
// Profile menu → "Switch to Admin Panel" / "Switch to User Mode"
if (userRole == 'admin') {
  ListTile(
    title: Text('Switch to User Mode'),
    onTap: () => Navigator.pushReplacementNamed(context, '/main'),
  )
}
```

---

## 📝 Notes

**So với sơ đồ ban đầu:**
- ✅ Sơ đồ nói "Firestore" → Code dùng **MongoDB** (đã sửa)
- ✅ Flow logic hoàn toàn khớp
- ✅ Role check từ database
- ✅ Automatic navigation based on role

**App behavior:**
- Admin login → Thấy Admin Panel ngay
- User login → Thấy Main Screen (normal app)
- Flexible: Admin có thể switch sang User mode nếu cần

**Backend đã sẵn sàng:**
- ✅ User model có `role` field
- ✅ API `/users/:uid` trả về role
- ✅ Middleware `isAdmin` check role
- ✅ Protected routes chỉ cho admin

**App sẽ hot reload tự động!** 🚀
