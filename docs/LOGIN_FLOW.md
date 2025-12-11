# Sơ đồ Luồng Đăng nhập (Login) - Today's Eats

**Ngày xác nhận:** 11/12/2025  
**Trạng thái:** ✅ SƠ ĐỒ KHỚP 100% VỚI CODE

---

## 📊 Sơ đồ luồng chính

```
Login Screen
  ↓
Người dùng nhập Email + Mật khẩu
  ↓
Nhấn nút "Đăng nhập"
  ↓
Validate dữ liệu
  ├── Không hợp lệ
  │     ↓
  │     Hiển thị thông báo lỗi
  │     ↓
  │     Người dùng nhập lại
  │
  └── Hợp lệ
        ↓
        Gọi Firebase Auth (signInWithEmailAndPassword)
        ↓
        Kết quả:
          ├── Thất bại (sai mật khẩu / không có tài khoản / lỗi mạng)
          │     ↓
          │     Hiển thị thông báo lỗi
          │
          └── Thành công
                ↓
                Điều hướng tới Main Screen
```

---

## 🔍 Chi tiết implementation

### 1. **Login Screen UI**

**File:** [`lib/features/auth/login_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/auth/login_screen.dart)

**Các trường nhập liệu:**

#### Email Field (Dòng 126-142)
```dart
SimpleTextField(
  controller: _emailController,
  label: 'Email',
  hint: 'example@email.com',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';  // ✅ Validate: không để trống
    }
    if (!value.contains('@')) {
      return 'Email không hợp lệ';     // ✅ Validate: phải có @
    }
    return null;
  },
),
```

#### Password Field (Dòng 143-170)
```dart
SimpleTextField(
  controller: _passwordController,
  label: 'Mật khẩu',
  hint: '••••••••',
  prefixIcon: Icons.lock_outlined,
  obscureText: !_isPasswordVisible,  // ✅ Ẩn/hiện mật khẩu
  textInputAction: TextInputAction.done,
  onSubmitted: (_) => _handleLogin(),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';          // ✅ Validate: không để trống
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự'; // ✅ Validate: min 6 ký tự
    }
    return null;
  },
),
```

---

### 2. **Validation - Kiểm tra dữ liệu**

**Hàm xử lý đăng nhập:** (Dòng 36-61)

```dart
Future<void> _handleLogin() async {
  // ✅ BƯỚC 1: Validate dữ liệu
  if (!_formKey.currentState!.validate()) {
    // ❌ Validation thất bại
    // → Hiển thị thông báo lỗi ngay tại từng field
    // → Người dùng nhập lại
    return;
  }

  // ✅ BƯỚC 2: Hiển thị loading state
  setState(() => _isLoading = true);

  try {
    // ✅ BƯỚC 3: Gọi Firebase Auth
    await _authService.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // ✅ BƯỚC 4: Đăng nhập thành công
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  } catch (e) {
    // ❌ BƯỚC 5: Đăng nhập thất bại
    if (mounted) {
      setState(() => _isLoading = false);
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

### 3. **Firebase Authentication**

**File:** [`lib/core/services/auth_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/auth_service.dart#L18-L30)

```dart
Future<UserCredential> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    // ✅ Gọi Firebase Auth
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    // ❌ Xử lý lỗi Firebase
    throw _handleAuthException(e);
  }
}
```

---

### 4. **Xử lý lỗi chi tiết**

**File:** [`auth_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/auth_service.dart#L176-L207)

```dart
String _handleAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Không tìm thấy tài khoản với email này.';
      
    case 'wrong-password':
      return 'Mật khẩu không đúng.';
      
    case 'invalid-email':
      return 'Email không hợp lệ.';
      
    case 'user-disabled':
      return 'Tài khoản này đã bị vô hiệu hóa.';
      
    case 'too-many-requests':
      return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      
    case 'network-request-failed':
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      
    case 'invalid-credential':
      return 'Thông tin xác thực không hợp lệ.';
      
    default:
      return 'Đã xảy ra lỗi: ${e.message ?? 'Lỗi không xác định'}';
  }
}
```

---

## 📋 Bảng luồng chi tiết

| Bước | Hành động | Code | Kết quả |
|------|-----------|------|---------|
| **1** | Người dùng nhập Email + Password | `_emailController`, `_passwordController` | Input fields |
| **2** | Nhấn nút "Đăng nhập" | `onPressed: _handleLogin` | Trigger validation |
| **3A** | Validate Email | `validator: (value) { ... }` | ✅ Hợp lệ / ❌ Không hợp lệ |
| **3B** | Validate Password | `validator: (value) { ... }` | ✅ Hợp lệ / ❌ Không hợp lệ |
| **4A** | Nếu **KHÔNG** hợp lệ | `if (!_formKey.currentState!.validate()) return;` | ❌ Hiển thị lỗi ngay field |
| **4B** | Nếu **HỢP LỆ** | `setState(() => _isLoading = true)` | ✅ Tiếp tục xử lý |
| **5** | Gọi Firebase Auth | `_authService.signInWithEmailAndPassword(...)` | Chờ kết quả |
| **6A** | Đăng nhập **THÀNH CÔNG** | `Navigator.pushReplacementNamed('/main')` | ✅ → Main Screen |
| **6B** | Đăng nhập **THẤT BẠI** | `catch (e) { ... }` | ❌ Hiển thị SnackBar lỗi |
| **7** | Lỗi: Sai mật khẩu | `'wrong-password'` | "Mật khẩu không đúng." |
| **8** | Lỗi: Không có tài khoản | `'user-not-found'` | "Không tìm thấy tài khoản..." |
| **9** | Lỗi: Mạng | `'network-request-failed'` | "Lỗi kết nối mạng..." |

---

## ✅ Case Studies - Các trường hợp cụ thể

### **Case 1: Email không hợp lệ**

```
Input: "test" (không có @)
  ↓
Validate Email: FAIL
  ↓
Hiển thị: "Email không hợp lệ"
  ↓
Người dùng nhập lại
```

### **Case 2: Password quá ngắn**

```
Input: Password = "123" (< 6 ký tự)
  ↓
Validate Password: FAIL
  ↓
Hiển thị: "Mật khẩu phải có ít nhất 6 ký tự"
  ↓
Người dùng nhập lại
```

### **Case 3: Email không tồn tại**

```
Input: Email = "notexist@test.com", Password = "123456"
  ↓
Validate: PASS ✅
  ↓
Firebase Auth: signInWithEmailAndPassword()
  ↓
FirebaseAuthException: 'user-not-found'
  ↓
_handleAuthException('user-not-found')
  ↓
Hiển thị SnackBar: "Không tìm thấy tài khoản với email này."
```

### **Case 4: Sai mật khẩu**

```
Input: Email = "user@test.com", Password = "wrongpass"
  ↓
Validate: PASS ✅
  ↓
Firebase Auth: signInWithEmailAndPassword()
  ↓
FirebaseAuthException: 'wrong-password'
  ↓
_handleAuthException('wrong-password')
  ↓
Hiển thị SnackBar: "Mật khẩu không đúng."
```

### **Case 5: Đăng nhập thành công**

```
Input: Email = "user@test.com", Password = "correct123"
  ↓
Validate: PASS ✅
  ↓
Firebase Auth: signInWithEmailAndPassword()
  ↓
UserCredential: user object returned
  ↓
Navigator.pushReplacementNamed('/main')
  ↓
→ Main Screen (5 tabs)
```

---

## 🔐 Validation Rules - Chi tiết

### Email Validation
| Điều kiện | Validation | Thông báo lỗi |
|-----------|------------|---------------|
| Rỗng | `value == null \|\| value.isEmpty` | "Vui lòng nhập email" |
| Không có @ | `!value.contains('@')` | "Email không hợp lệ" |
| Hợp lệ | Có ký tự @ | ✅ Pass |

### Password Validation
| Điều kiện | Validation | Thông báo lỗi |
|-----------|------------|---------------|
| Rỗng | `value == null \|\| value.isEmpty` | "Vui lòng nhập mật khẩu" |
| < 6 ký tự | `value.length < 6` | "Mật khẩu phải có ít nhất 6 ký tự" |
| ≥ 6 ký tự | `value.length >= 6` | ✅ Pass |

---

## 🎨 UI States - Trạng thái giao diện

### Loading State
```dart
bool _isLoading = false;

// Khi đang đăng nhập
setState(() => _isLoading = true);

// Hiển thị:
// - Button disabled
// - CircularProgressIndicator
// - User không thể tương tác
```

### Error State
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,  // ✅ Màu đỏ cho error
  ),
);

// Hiển thị SnackBar ở bottom của màn hình
// Auto-dismiss sau vài giây
```

### Success State
```dart
// Không hiển thị notification
// Navigate trực tiếp tới Main Screen
Navigator.of(context).pushReplacementNamed('/main');
```

---

## 🔄 Phương thức đăng nhập bổ sung

### Google Sign-In (Dòng 63-85)

```dart
Future<void> _handleGoogleSignIn() async {
  setState(() => _isGoogleLoading = true);

  try {
    final userCredential = await _authService.signInWithGoogle();

    if (userCredential != null && mounted) {
      // ✅ Thành công → Main Screen
      Navigator.of(context).pushReplacementNamed('/main');
    } else if (mounted) {
      // User hủy đăng nhập
      setState(() => _isGoogleLoading = false);
    }
  } catch (e) {
    // ❌ Lỗi
    if (mounted) {
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Luồng Google Sign-In:**
```
Nhấn nút "Đăng nhập với Google"
  ↓
Google Sign-In popup
  ├─ User chọn tài khoản → Success → Main Screen
  └─ User hủy → Quay lại Login Screen
```

---

## 🔗 Links liên quan

### Màn hình khác từ Login Screen

**1. Forgot Password** (Dòng 173-183)
```dart
TextButton(
  onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
  child: const Text('Quên mật khẩu?'),
)
```

**2. Register** (Dòng 265-280)
```dart
TextButton(
  onPressed: () => Navigator.of(context).pushNamed('/register'),
  child: Text('Đăng ký'),
)
```

---

## 📊 State Management trong Login

| State Variable | Type | Mục đích |
|----------------|------|----------|
| `_formKey` | `GlobalKey<FormState>` | Quản lý form validation |
| `_emailController` | `TextEditingController` | Input email |
| `_passwordController` | `TextEditingController` | Input password |
| `_isPasswordVisible` | `bool` | Toggle hiện/ẩn password |
| `_isLoading` | `bool` | Loading state cho Email login |
| `_isGoogleLoading` | `bool` | Loading state cho Google login |

---

## ✅ Xác nhận tổng hợp

### Sơ đồ vs Code

| Thành phần trong Sơ đồ | Implementation | File | Trạng thái |
|------------------------|----------------|------|------------|
| Login Screen | ✅ UI với Email + Password fields | `login_screen.dart` | ✅ ĐÚNG |
| Người dùng nhập Email + Password | ✅ TextEditingController | `login_screen.dart:22-23` | ✅ ĐÚNG |
| Nhấn nút "Đăng nhập" | ✅ onSubmit: `_handleLogin` | `login_screen.dart:124` | ✅ ĐÚNG |
| Validate dữ liệu | ✅ Form validators | `login_screen.dart:133-169` | ✅ ĐÚNG |
| Không hợp lệ → Hiển thị lỗi | ✅ Return error message | `login_screen.dart:135,138,163,166` | ✅ ĐÚNG |
| Người dùng nhập lại | ✅ Stay on login screen | Auto behavior | ✅ ĐÚNG |
| Hợp lệ → Gọi Firebase Auth | ✅ `signInWithEmailAndPassword` | `auth_service.dart:18-30` | ✅ ĐÚNG |
| Thất bại → Hiển thị lỗi | ✅ SnackBar with error | `login_screen.dart:53-58` | ✅ ĐÚNG |
| Thành công → Main Screen | ✅ `pushReplacementNamed('/main')` | `login_screen.dart:48` | ✅ ĐÚNG |

---

## 🎯 Kết luận

> [!NOTE]
> **Sơ đồ luồng đăng nhập KHỚP 100% với code implementation!**

**Các điểm chính:**
- ✅ Validation 2 cấp: Client-side (Flutter) + Server-side (Firebase)
- ✅ Xử lý lỗi đầy đủ với thông báo tiếng Việt
- ✅ Loading states cho UX tốt hơn
- ✅ Support cả Email/Password và Google Sign-In
- ✅ Error messages rõ ràng, dễ hiểu

**Luồng chính:**
```
Input → Validate → Firebase Auth → Success/Fail → Navigate/Show Error
```

**Hoàn toàn đúng với sơ đồ đã vẽ!** ✅
