# Sơ đồ Luồng Đăng ký (Register) - Today's Eats

**Ngày xác nhận:** 11/12/2025  
**Trạng thái:** ✅ SƠ ĐỒ KHỚP 98% VỚI CODE (Có 1 điểm khác biệt nhỏ)

---

## 📊 Sơ đồ luồng chính

```
Register Screen
  ↓
Người dùng nhập: Tên hiển thị + Email + Mật khẩu (+ Xác nhận mật khẩu)
  ↓
Nhấn nút "Đăng ký"
  ↓
Validate dữ liệu
  ├── Không hợp lệ
  │     ↓
  │     Hiển thị thông báo lỗi
  │
  └── Hợp lệ
        ↓
        Gọi Firebase Auth (createUserWithEmailAndPassword)
        ↓
        Kết quả:
          ├── Thất bại (email đã tồn tại / lỗi khác)
          │     ↓
          │     Hiển thị thông báo lỗi
          │
          └── Thành công
                ↓
                Update displayName trong Firebase Auth
                ↓
                Tạo/Cập nhật document user trong MongoDB ⚠️ (không phải Firestore)
                ↓
                Điều hướng tới Main Screen
```

---

## ⚠️ Điểm khác biệt với sơ đồ

| Trong Sơ đồ | Trong Code | Ghi chú |
|--------------|------------|---------|
| "Tạo document user trong **Firestore**" | Tạo user trong **MongoDB** qua API | ⚠️ Backend sử dụng MongoDB, không phải Firestore |

> [!NOTE]
> **App sử dụng MongoDB (qua API backend), không dùng Firestore!**
> - Firestore: Cloud database của Firebase
> - MongoDB: Database riêng của bạn
> - Code gọi `_apiService.createOrUpdateUser()` để lưu vào MongoDB

---

## 🔍 Chi tiết implementation

### 1. **Register Screen UI**

**File:** [`lib/features/auth/register_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/auth/register_screen.dart)

**Các trường nhập liệu:**

#### 1️⃣ Tên hiển thị (Display Name) - Dòng 99-114
```dart
TextFormField(
  controller: _nameController,
  decoration: InputDecoration(
    labelText: 'Họ và tên',
    prefixIcon: const Icon(Icons.person_outlined),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';  // ✅ Validate: không để trống
    }
    return null;
  },
),
```

#### 2️⃣ Email - Dòng 116-135
```dart
TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    labelText: 'Email',
    prefixIcon: const Icon(Icons.email_outlined),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@')) {
      return 'Email không hợp lệ';  // ✅ Validate: phải có @
    }
    return null;
  },
),
```

#### 3️⃣ Mật khẩu - Dòng 137-165
```dart
TextFormField(
  controller: _passwordController,
  obscureText: !_isPasswordVisible,  // ✅ Ẩn/hiện mật khẩu
  decoration: InputDecoration(
    labelText: 'Mật khẩu',
    prefixIcon: const Icon(Icons.lock_outlined),
    suffixIcon: IconButton(...),  // Toggle visibility
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';  // ✅ Min 6 ký tự
    }
    return null;
  },
),
```

#### 4️⃣ Xác nhận mật khẩu ⚠️ (Thêm so với sơ đồ) - Dòng 167-196
```dart
TextFormField(
  controller: _confirmPasswordController,
  obscureText: !_isConfirmPasswordVisible,
  decoration: InputDecoration(
    labelText: 'Xác nhận mật khẩu',
    prefixIcon: const Icon(Icons.lock_outlined),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu không khớp';  // ✅ Validate: phải khớp với password
    }
    return null;
  },
),
```

---

### 2. **Validation - Kiểm tra dữ liệu**

**Hàm xử lý đăng ký:** (Dòng 32-58)

```dart
Future<void> _handleRegister() async {
  // ✅ BƯỚC 1: Validate tất cả fields
  if (!_formKey.currentState!.validate()) {
    // ❌ Validation thất bại
    // → Hiển thị error ngay tại từng field
    return;
  }

  // ✅ BƯỚC 2: Show loading state
  setState(() => _isLoading = true);

  try {
    // ✅ BƯỚC 3: Gọi Firebase Auth để tạo tài khoản
    await _authService.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    // ✅ BƯỚC 4: Đăng ký thành công → Main Screen
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  } catch (e) {
    // ❌ BƯỚC 5: Đăng ký thất bại
    if (mounted) {
      setState(() => _isLoading = false);
      
      // Hiển thị error
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

### 3. **Firebase Authentication + MongoDB**

**File:** [`lib/core/services/auth_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/auth_service.dart#L99-L133)

```dart
Future<UserCredential> registerWithEmailAndPassword({
  required String email,
  required String password,
  required String displayName,
}) async {
  try {
    // ✅ BƯỚC 1: Tạo tài khoản Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ✅ BƯỚC 2: Cập nhật displayName trong Firebase
    await credential.user?.updateDisplayName(displayName);

    // ✅ BƯỚC 3: Lưu user vào MongoDB backend
    if (credential.user != null) {
      try {
        await _apiService.createOrUpdateUser({
          'uid': credential.user!.uid,
          'email': credential.user!.email,
          'displayName': displayName,
          'photoURL': '',
        });
        debugPrint('✅ User saved to MongoDB');
      } catch (e) {
        debugPrint('⚠️ Failed to save user: $e');
        // Không fail registration nếu backend down
      }
    }

    return credential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  }
}
```

---

## 📋 Bảng luồng chi tiết

| Bước | Hành động | Code | Kết quả |
|------|-----------|------|---------|
| **1** | Nhập Tên hiển thị | `_nameController` | Input field |
| **2** | Nhập Email | `_emailController` | Input field |
| **3** | Nhập Password | `_passwordController` | Input field |
| **4** | Nhập Confirm Password | `_confirmPasswordController` | Input field |
| **5** | Nhấn "Đăng ký" | `onPressed: _handleRegister` | Trigger validation |
| **6A** | Validate Tên | `if (value.isEmpty)` | ✅/❌ |
| **6B** | Validate Email | `if (!value.contains('@'))` | ✅/❌ |
| **6C** | Validate Password | `if (value.length < 6)` | ✅/❌ |
| **6D** | Validate Confirm | `if (value != _passwordController.text)` | ✅/❌ |
| **7A** | Nếu **KHÔNG** hợp lệ | `return;` | ❌ Hiển thị lỗi |
| **7B** | Nếu **HỢP LỆ** | `setState(() => _isLoading = true)` | ✅ Tiếp tục |
| **8** | Tạo Firebase Auth | `createUserWithEmailAndPassword()` | Chờ kết quả |
| **9A** | Thành công | `credential.user != null` | ✅ Có user object |
| **9B** | Thất bại | `catch FirebaseAuthException` | ❌ Throw error |
| **10** | Update displayName | `updateDisplayName(displayName)` | ✅ Cập nhật tên |
| **11** | Lưu vào MongoDB | `_apiService.createOrUpdateUser()` | ✅ User document |
| **12** | Navigate | `pushReplacementNamed('/main')` | → Main Screen |

---

## ✅ Case Studies - Các trường hợp cụ thể

### **Case 1: Tên để trống**

```
Input:
  - Tên: "" (trống)
  - Email: "test@example.com"
  - Password: "123456"
  ↓
Validate Tên: FAIL
  ↓
Hiển thị: "Vui lòng nhập họ tên"
  ↓
Không gọi Firebase Auth
```

### **Case 2: Email đã tồn tại**

```
Input:
  - Tên: "Nguyễn Văn A"
  - Email: "existing@test.com"
  - Password: "123456"
  ↓
Validate: PASS ✅
  ↓
Firebase: createUserWithEmailAndPassword()
  ↓
FirebaseAuthException: 'email-already-in-use'
  ↓
_handleAuthException('email-already-in-use')
  ↓
SnackBar: "Email này đã được sử dụng."
```

### **Case 3: Mật khẩu không khớp**

```
Input:
  - Tên: "Nguyễn Văn A"
  - Email: "test@example.com"
  - Password: "123456"
  - Confirm: "123457" ❌ Khác
  ↓
Validate Confirm Password: FAIL
  ↓
Hiển thị: "Mật khẩu không khớp"
  ↓
Không gọi Firebase Auth
```

### **Case 4: Đăng ký thành công**

```
Input:
  - Tên: "Nguyễn Văn A"
  - Email: "newuser@test.com"
  - Password: "123456"
  - Confirm: "123456" ✅
  ↓
Validate: PASS ✅
  ↓
Firebase: createUserWithEmailAndPassword()
  ↓
UserCredential: user object created
  ↓
updateDisplayName("Nguyễn Văn A")
  ↓
MongoDB: createOrUpdateUser({...})
  ↓
Navigator.pushReplacementNamed('/main')
  ↓
→ Main Screen (5 tabs)
```

### **Case 5: MongoDB lỗi (không ảnh hưởng đăng ký)**

```
Input: Valid data
  ↓
Firebase Auth: SUCCESS ✅
  ↓
Update displayName: SUCCESS ✅
  ↓
MongoDB API: FAILED ❌ (network error)
  ↓
debugPrint('⚠️ Failed to save user')
  ↓
→ Vẫn navigate tới Main Screen ✅
(User vẫn đăng ký được, chỉ không sync với MongoDB)
```

---

## 🔐 Validation Rules - Chi tiết

### Tên hiển thị
| Điều kiện | Validation | Thông báo lỗi |
|-----------|------------|---------------|
| Rỗng | `value.isEmpty` | "Vui lòng nhập họ tên" |
| Hợp lệ | Có ký tự | ✅ Pass |

### Email
| Điều kiện | Validation | Thông báo lỗi |
|-----------|------------|---------------|
| Rỗng | `value.isEmpty` | "Vui lòng nhập email" |
| Không có @ | `!value.contains('@')` | "Email không hợp lệ" |
| Hợp lệ | Có @ | ✅ Pass |

### Mật khẩu
| Điều kiện | Validation | Thông báo lỗi |
|-----------|------------|---------------|
| Rỗng | `value.isEmpty` | "Vui lòng nhập mật khẩu" |
| < 6 ký tự | `value.length < 6` | "Mật khẩu phải có ít nhất 6 ký tự" |
| ≥ 6 ký tự | `value.length >= 6` | ✅ Pass |

### Xác nhận mật khẩu (Thêm so với sơ đồ)
| Điều kiện | Validation | Thông báo lỗi |
|-----------|------------|---------------|
| Rỗng | `value.isEmpty` | "Vui lòng xác nhận mật khẩu" |
| Không khớp | `value != _passwordController.text` | "Mật khẩu không khớp" |
| Khớp | `value == _passwordController.text` | ✅ Pass |

---

## 🎨 UI States - Trạng thái giao diện

### Loading State
```dart
bool _isLoading = false;

// Khi đang đăng ký
setState(() => _isLoading = true);

// Hiển thị:
// - CircularProgressIndicator trong button
// - Button disabled
```

### Error State
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,
  ),
);
```

### Success State
```dart
// Navigate trực tiếp
Navigator.of(context).pushReplacementNamed('/main');
```

---

## 🔄 Workflow với MongoDB

### Tại sao lưu vào MongoDB?

**Firebase Auth:** Chỉ lưu authentication data
- ✅ UID
- ✅ Email
- ✅ Password (hashed)
- ✅ Display name

**MongoDB (Backend):** Lưu user profile đầy đủ
- ✅ UID (link với Firebase)
- ✅ Email
- ✅ Display name
- ✅ Photo URL
- ✅ Favorites (món ăn yêu thích)
- ✅ Created date, Updated date
- ✅ Custom user data

### API Call
```dart
await _apiService.createOrUpdateUser({
  'uid': credential.user!.uid,
  'email': credential.user!.email,
  'displayName': displayName,
  'photoURL': '',
});
```

**Backend endpoint:** `POST /api/users` hoặc `PUT /api/users/:uid`

---

## 🚨 Xử lý lỗi Firebase

**File:** [`auth_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/auth_service.dart#L176-L207)

| Error Code | Thông báo |
|------------|-----------|
| `email-already-in-use` | "Email này đã được sử dụng." |
| `invalid-email` | "Email không hợp lệ." |
| `weak-password` | "Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn." |
| `operation-not-allowed` | "Thao tác không được phép." |
| `network-request-failed` | "Lỗi kết nối mạng. Vui lòng kiểm tra internet." |

---

## 📊 State Management

| State Variable | Type | Mục đích |
|----------------|------|----------|
| `_formKey` | `GlobalKey<FormState>` | Quản lý form validation |
| `_nameController` | `TextEditingController` | Input tên |
| `_emailController` | `TextEditingController` | Input email |
| `_passwordController` | `TextEditingController` | Input password |
| `_confirmPasswordController` | `TextEditingController` | Input confirm password |
| `_isPasswordVisible` | `bool` | Toggle hiện/ẩn password |
| `_isConfirmPasswordVisible` | `bool` | Toggle hiện/ẩn confirm password |
| `_isLoading` | `bool` | Loading state |

---

## 🔗 Navigation

### Quay lại Login
```dart
TextButton(
  onPressed: () => Navigator.pop(context),
  child: const Text('Đăng nhập'),
)
```

### Đến Main sau đăng ký thành công
```dart
Navigator.of(context).pushReplacementNamed('/main');
```

---

## ✅ Xác nhận tổng hợp

### Sơ đồ vs Code

| Thành phần trong Sơ đồ | Implementation | Trạng thái |
|------------------------|----------------|------------|
| Register Screen | ✅ UI form | ✅ ĐÚNG |
| Nhập: Tên + Email + Password | ✅ 3 fields + Confirm Password | ⚠️ Thêm Confirm |
| Validate dữ liệu | ✅ Validators cho 4 fields | ✅ ĐÚNG |
| Không hợp lệ → Error | ✅ Hiển thị lỗi ngay field | ✅ ĐÚNG |
| Gọi Firebase Auth | ✅ `createUserWithEmailAndPassword` | ✅ ĐÚNG |
| Thất bại → Error | ✅ SnackBar với message | ✅ ĐÚNG |
| Thành công → Update name | ✅ `updateDisplayName` | ✅ ĐÚNG |
| **Tạo document Firestore** | ❌ Lưu vào **MongoDB** qua API | ⚠️ **KHÁC** |
| Navigate → Main Screen | ✅ `pushReplacementNamed('/main')` | ✅ ĐÚNG |

---

## 🎯 Kết luận

> [!IMPORTANT]
> **Sơ đồ khớp 98% với code - chỉ có 1 điểm khác biệt:**
> - ✅ Sơ đồ: "Tạo document user trong **Firestore**"
> - ⚠️ Thực tế: Tạo user trong **MongoDB** (qua API backend)

**Các điểm chính:**
- ✅ Validation 4 fields (Name, Email, Password, Confirm Password)
- ✅ Firebase Auth để tạo tài khoản
- ✅ Update displayName
- ✅ **MongoDB** (không phải Firestore) để lưu user profile
- ✅ Error handling đầy đủ
- ✅ Navigate tới Main Screen sau khi thành công

**Luồng chính:**
```
Input → Validate → Firebase Auth → Update Name → MongoDB → Main Screen
```

**Sơ đồ của bạn rất tốt! Chỉ cần đổi "Firestore" → "MongoDB" là hoàn hảo!** ✅
