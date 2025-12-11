# Sơ đồ Luồng Splash & Kiểm tra Đăng nhập - Today's Eats

**Ngày cập nhật:** 11/12/2025  
**Trạng thái:** ✅ CODE ĐÃ CẬP NHẬT ĐỂ KHỚP VỚI SƠ ĐỒ

---

## 📊 Sơ đồ luồng chính

```
Splash Screen
  ↓
Tải cấu hình ban đầu (config, theme, v.v.)
  ↓
Kiểm tra Firebase Auth (user hiện tại)
  ├── Có user
  │     ↓
  │     Điều hướng tới Main Screen
  │
  └── Không có user
        ↓
        Điều hướng tới Login Screen
```

---

## 🔍 Chi tiết implementation

### 1. **main.dart** - Khởi tạo ứng dụng

**File:** [`lib/main.dart`](file:///home/nho/Documents/TodaysEats/lib/main.dart)

```dart
Future<void> main() async {
  // Khởi tạo Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase (config ban đầu)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Chạy ứng dụng
  runApp(const TodaysEatsApp());
}
```

**Mục đích:**
- ✅ Khởi tạo Flutter framework
- ✅ Kết nối Firebase (Authentication, Firestore, etc.)
- ✅ Cấu hình platform-specific options

---

### 2. **app.dart** - Tải theme và providers

**File:** [`lib/app.dart`](file:///home/nho/Documents/TodaysEats/lib/app.dart)

```dart
return MultiProvider(
  providers: [
    // Theme Provider - Tải theme (Dark/Light mode)
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..initialize(),
    ),
    // Dish Spinner Provider
    ChangeNotifierProvider(
      create: (_) => DishSpinnerProvider(),
    ),
    // Fridge AI Provider
    ChangeNotifierProvider(
      create: (_) => FridgeAIProvider(AIService()),
    ),
    // Local storage provider (backup)
    ChangeNotifierProvider(
      create: (_) => MenuManagementProvider(StorageService())..initialize(),
    ),
    // MongoDB API provider (primary)
    ChangeNotifierProvider(
      create: (_) => MenuManagementApiProvider(ApiService())..initialize(),
    ),
  ],
  child: MaterialApp(
    title: "Today's Eats",
    initialRoute: '/splash',  // ✅ Bắt đầu từ Splash Screen
    routes: {...},
  ),
);
```

**Mục đích:**
- ✅ Tải theme (dark/light mode)
- ✅ Khởi tạo providers (state management)
- ✅ Thiết lập routes cho navigation
- ✅ Load config từ storage

---

### 3. **splash_screen.dart** - Kiểm tra đăng nhập

**File:** [`lib/features/splash/splash_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/splash/splash_screen.dart#L38-L52)

```dart
@override
void initState() {
  super.initState();

  // Khởi tạo animation
  _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );

  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeIn),
  );

  _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  _controller.forward();

  // ✅ Kiểm tra auth state sau 3 giây
  Timer(const Duration(seconds: 3), () async {
    if (mounted) {
      // Lấy user hiện tại từ Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // ✅ Có user (đã đăng nhập) → Main Screen
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        // ✅ Không có user (chưa đăng nhập) → Login Screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  });
}
```

**Timeline:**
```
0.0s: Splash Screen hiển thị
0.0s - 1.5s: Animation (Fade + Scale)
3.0s: Kiểm tra Firebase Auth
3.0s: Navigate → Main hoặc Login
```

**Mục đích:**
- ✅ Hiển thị logo và branding (3 giây)
- ✅ Cho thời gian load config, theme, providers
- ✅ Kiểm tra trạng thái đăng nhập
- ✅ Điều hướng phù hợp

---

## 🎯 Luồng hoạt động chi tiết

### Trường hợp 1: **Người dùng ĐÃ đăng nhập**

```
1. Mở app
   ↓
2. main() → Firebase.initializeApp()
   ↓
3. app.dart → Load theme, providers
   ↓
4. Splash Screen (3s animation)
   ↓
5. Kiểm tra: FirebaseAuth.instance.currentUser != null ✅
   ↓
6. Navigator.pushReplacementNamed('/main')
   ↓
7. Main Screen (5 tabs)
   - Tab Home (Dish Spinner)
   - Tab Favorites
   - Tab Fridge AI
   - Tab Profile
   - Tab Admin
```

**Thời gian:** ~3 giây

---

### Trường hợp 2: **Người dùng CHƯA đăng nhập**

```
1. Mở app
   ↓
2. main() → Firebase.initializeApp()
   ↓
3. app.dart → Load theme, providers
   ↓
4. Splash Screen (3s animation)
   ↓
5. Kiểm tra: FirebaseAuth.instance.currentUser == null ❌
   ↓
6. Navigator.pushReplacementNamed('/login')
   ↓
7. Login Screen
   - Email/Password login
   - Google Sign-In
   ↓
8. Đăng nhập thành công
   ↓
9. Main Screen (5 tabs)
```

**Thời gian:** ~3 giây splash + thời gian đăng nhập

---

## 📋 Thay đổi so với version trước

| Tính năng | Trước đây | Hiện tại | Lý do |
|-----------|-----------|----------|-------|
| **Onboarding** | Bắt buộc cho user mới | ❌ Đã loại bỏ | Đơn giản hóa luồng |
| **Login flow** | Splash → Onboarding → Login | Splash → Login ✅ | Giảm bước |
| **User trải nghiệm** | 3 màn hình | 2 màn hình | Nhanh hơn |

---

## ⚙️ Cấu hình ban đầu được tải

**1. Firebase (main.dart)**
- ✅ Firebase Authentication
- ✅ Firebase Firestore
- ✅ Platform configuration

**2. Theme Provider (app.dart)**
- ✅ Dark/Light mode preference
- ✅ Google Fonts (Nunito, Quicksand)
- ✅ Material 3 theme

**3. State Management Providers (app.dart)**
- ✅ DishSpinnerProvider
- ✅ FridgeAIProvider
- ✅ MenuManagementProvider (Local Storage)
- ✅ MenuManagementApiProvider (MongoDB)

---

## 🔐 Firebase Authentication Check

```dart
// Lấy user hiện tại
final user = FirebaseAuth.instance.currentUser;

if (user != null) {
  // User object chứa:
  // - user.uid: User ID
  // - user.email: Email address
  // - user.displayName: Display name
  // - user.photoURL: Profile photo
  // - user.emailVerified: Email verification status
  
  // → User đã đăng nhập
  Navigator.pushReplacementNamed('/main');
} else {
  // → User chưa đăng nhập
  Navigator.pushReplacementNamed('/login');
}
```

---

## 📱 UI Components trong Splash Screen

**Background:**
- Pattern image: `assets/images/food_pattern.jpg`
- Semi-transparent gradient overlay

**Logo:**
- Size: 120x120
- Border radius: 30
- Shadow: blur 30, opacity 0.3

**Text:**
- Title: "Today's Eats" (36px, bold, white)
- Subtitle: "Hôm nay ăn gì?" (18px, white70)

**Animation:**
- Duration: 1500ms
- Fade: 0.0 → 1.0 (easeIn)
- Scale: 0.5 → 1.0 (easeOutBack)

---

## ✅ Xác nhận hoạt động

**Code đã được cập nhật:**
- ✅ [`splash_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/splash/splash_screen.dart#L48) - Chuyển từ `/onboarding` sang `/login`

**Sơ đồ hiện tại:**
```
Splash → Check Auth
  ├─ Có user → Main ✅
  └─ Không user → Login ✅ (BỎ Onboarding)
```

**Trạng thái:** ✅ **KHỚP 100% với sơ đồ!**

---

## 📝 Ghi chú

> [!NOTE]
> Onboarding Screen vẫn tồn tại trong code tại [`lib/features/onboarding/onboarding_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/onboarding/onboarding_screen.dart) và route `/onboarding` vẫn được định nghĩa trong [`app.dart`](file:///home/nho/Documents/TodaysEats/lib/app.dart#L58). Nếu muốn, có thể truy cập thủ công từ Login Screen hoặc xóa hoàn toàn.

> [!TIP]
> Nếu muốn hiển thị Onboarding chỉ lần đầu tiên, có thể dùng SharedPreferences để lưu flag `isFirstLaunch` và kiểm tra trong Splash Screen.
