# Sơ đồ luồng tổng quát hệ thống - Today's Eats

## 1. Luồng khởi động ứng dụng

```
Bắt đầu
  ↓
Mở ứng dụng Today's Eats
  ↓
Splash Screen (3 giây với animation)
  ↓
Kiểm tra trạng thái đăng nhập (Firebase Auth)
  ├── Đã đăng nhập
  │     ↓
  │     Điều hướng tới Main Screen (Bottom Navigation)
  │     ├── Tab Home (Dish Spinner)
  │     ├── Tab Favorites
  │     ├── Tab Fridge AI
  │     ├── Tab Profile
  │     └── Tab Admin
  │
  └── Chưa đăng nhập
        ↓
        Điều hướng tới Onboarding Screen
        ↓
        Login Screen
```

## 2. Chi tiết từng màn hình

### 2.1. Splash Screen
**Thời gian:** 3 giây  
**Animation:** Fade in + Scale  
**Logic:**
```dart
Timer(const Duration(seconds: 3), () async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
        // Đã đăng nhập → Main Screen
        Navigator.pushReplacementNamed('/main');
    } else {
        // Chưa đăng nhập → Onboarding
        Navigator.pushReplacementNamed('/onboarding');
    }
});
```

### 2.2. Onboarding Screen
**Mục đích:** Giới thiệu app cho người dùng mới  
**Điều hướng:** → Login Screen

### 2.3. Login Screen
**Các phương thức đăng nhập:**
- Email/Password
- Google Sign-In
- Firebase Authentication

**Điều hướng:**
- Đăng nhập thành công → Main Screen
- Chưa có tài khoản → Register Screen
- Quên mật khẩu → Forgot Password Screen

### 2.4. Main Screen - Bottom Navigation (5 Tabs)

#### Tab 1: Home (Dish Spinner) 🍽️
- Xoay vòng chọn món ăn ngẫu nhiên
- Hiển thị danh sách món ăn
- Thêm/xóa yêu thích

#### Tab 2: Favorites ❤️
- Danh sách món ăn đã yêu thích
- Xem chi tiết món ăn
- Bỏ yêu thích

#### Tab 3: Fridge AI 🤖
- AI gợi ý món ăn từ nguyên liệu trong tủ lạnh
- Quản lý nguyên liệu
- Tìm kiếm công thức nấu ăn

#### Tab 4: Profile 👤
- Thông tin người dùng
- Cài đặt ứng dụng
- Chế độ Dark Mode
- Đăng xuất

#### Tab 5: Admin ⚙️
- Quản lý món ăn (CRUD)
- Quản lý danh mục
- Thống kê

## 3. Sơ đồ luồng hoạt động đầy đủ (Text-based)

```
┌─────────────────┐
│   Bắt đầu       │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Mở ứng dụng Today's Eats       │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│   Splash Screen                 │
│   (Animation 3 giây)            │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ Kiểm tra trạng thái đăng nhập   │
│    (Firebase Auth)              │
└────────┬────────────────────────┘
         │
         ├─── Đã đăng nhập ────────────────────┐
         │                                     │
         ▼                                     ▼
┌──────────────────┐              ┌────────────────────────┐
│ Onboarding Screen│              │   Main Screen          │
│                  │              │  (Bottom Navigation)   │
└────────┬─────────┘              └───────┬────────────────┘
         │                                │
         ▼                                │
┌──────────────────┐                      │
│  Login Screen    │                      │
└────────┬─────────┘                      │
         │                                │
         └────────────────────────────────┘
                                          │
         ┌────────────────┬───────────────┼───────────────┬────────────┐
         │                │               │               │            │
         ▼                ▼               ▼               ▼            ▼
    ┌─────────┐    ┌──────────┐   ┌───────────┐   ┌─────────┐  ┌────────┐
    │  Home   │    │Favorites │   │Fridge AI  │   │ Profile │  │ Admin  │
    │(Spinner)│    │          │   │           │   │         │  │        │
    └─────────┘    └──────────┘   └───────────┘   └─────────┘  └────────┘
```

## 4. Routes định nghĩa trong app

**File:** `lib/app.dart`

```dart
routes: {
  '/splash': (context) => const SplashScreen(),
  '/onboarding': (context) => const OnboardingScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/forgot-password': (context) => const ForgotPasswordScreen(),
  '/main': (context) => const MainScreen(),
  '/api-test': (context) => const ApiTestScreen(),
}
```

## 5. Các màn hình chính

### Cấu trúc Bottom Navigation
**File:** `lib/features/main/main_screen.dart`

```dart
final List<Widget> _screens = [
  const SpinHomeScreen(),      // Tab 1: Home
  const FavoritesScreen(),     // Tab 2: Favorites
  const FridgeAIView(),        // Tab 3: Fridge AI
  const ProfileScreen(),       // Tab 4: Profile
  const AdminScreen(),         // Tab 5: Admin ⚠️ (Đã bổ sung)
];
```

## 6. So sánh với sơ đồ ban đầu

| Thành phần | Sơ đồ ban đầu | Thực tế trong code | Trạng thái |
|------------|---------------|-------------------|------------|
| Splash Screen | ✅ Có | ✅ Có | ✅ Khớp |
| **Onboarding Screen** | ❌ Thiếu | ✅ Có | ⚠️ **Đã bổ sung** |
| Login Screen | ✅ Có | ✅ Có | ✅ Khớp |
| Tab Home | ✅ Có | ✅ Có | ✅ Khớp |
| Tab Favorites | ✅ Có | ✅ Có | ✅ Khớp |
| Tab Fridge AI | ✅ Có | ✅ Có | ✅ Khớp |
| Tab Profile | ✅ Có | ✅ Có | ✅ Khớp |
| **Tab Admin** | ❌ Thiếu | ✅ Có | ⚠️ **Đã bổ sung** |

## 7. Tóm tắt

✅ **Sơ đồ đã được cập nhật đầy đủ** với:
1. Màn hình **Onboarding** (trước Login Screen)
2. Tab **Admin** (thứ 5 trong Bottom Navigation)

📝 **Ghi chú:**
- Luồng chính: `Splash → Check Auth → (Onboarding →) Login → Main (5 tabs)`
- Firebase Auth được sử dụng để kiểm tra trạng thái đăng nhập
- Bottom Navigation có 5 tabs thay vì 4 tabs như sơ đồ ban đầu
