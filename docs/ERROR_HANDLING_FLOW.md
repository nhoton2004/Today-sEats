# Luồng Xử Lý Lỗi (Error Handling Flow) - Today's Eats ✅

**Ngày implement:** 11/12/2025  
**Trạng thái:** ✅ **ĐÃ CÓ SẴN + CẢI THIỆN**

---

## 📊 Flowchart

```
Người dùng thực hiện hành động
  ↓
Hệ thống gọi Firebase / API / AI
  ↓
Nhận phản hồi:
  ├─ Thành công ✅
  │     ↓
  │     Hiển thị thông báo thành công (SnackBar xanh)
  │     ↓
  │     Tiếp tục luồng chính
  │
  └─ Thất bại ❌
        ↓
        Phân loại lỗi:
        ├─ Lỗi mạng (SocketException, Network error)
        ├─ Lỗi Firebase Auth (wrong-password, user-not-found, ...)
        ├─ Lỗi API (500, 404, timeout, ...)
        └─ Lỗi khác
        ↓
        Hiển thị thông báo lỗi cụ thể (SnackBar đỏ)
        ↓
        Gợi ý cách sửa:
        - 💡 Kiểm tra kết nối mạng
        - 💡 Kiểm tra lại thông tin đăng nhập
        - 💡 Thử lại sau
        ↓
        Cho phép người dùng:
        ├─ Nhấn "Thử lại" (retry button)
        ├─ Nhập lại thông tin
        └─ Kiểm tra kết nối mạng
```

---

## 🎯 Nên có để bảo cao mạnh hơn

✅ **Giáo viên thường hỏi:**
- "App xử lý lỗi như thế nào?"
- "Nếu không có mạng thì app hiển thị gì?"
- "Người dùng biết sửa lỗi ở đâu?"

✅ **UX tốt hơn:**
- User-friendly messages (không hiển thị raw error)
- Gợi ý cách fix (kiểm tra mạng, thử lại, ...)
- Retry button để thử lại ngay

---

## 🔧 Implementation

### 1. ErrorHandler Utility
**File:** [`lib/core/utils/error_handler.dart`](file:///home/nho/Documents/TodaysEats/lib/core/utils/error_handler.dart)

**Features:**
- ✅ `showError()` - Hiển thị lỗi với gợi ý và nút "Thử lại"
- ✅ `showSuccess()` - Hiển thị thành công
- ✅ `showWarning()` - Hiển thị cảnh báo
- ✅ `showLoading()` / `hideLoading()` - Loading dialog
- ✅ Firebase Auth error messages (tiếng Việt)
- ✅ Network error detection
- ✅ API error handling
- ✅ Error logging for debugging

---

### 2. Usage Examples

#### Basic Error Handling
```dart
try {
  await _authService.signInWithEmailAndPassword(email, password);
  
  // Success
  if (mounted) {
    ErrorHandler.showSuccess(context, message: 'Đăng nhập thành công!');
    Navigator.pushReplacementNamed(context, '/main');
  }
} catch (e) {
  // Error with retry
  if (mounted) {
    ErrorHandler.showError(
      context,
      error: e,
      onRetry: () => _handleLogin(),  // Retry callback
    );
  }
}
```

#### Custom Error Message
```dart
try {
  await _apiService.createDish(dishData);
  ErrorHandler.showSuccess(context, message: 'Đã thêm món ăn!');
} catch (e) {
  ErrorHandler.showError(
    context,
    error: e,
    customMessage: 'Không thể thêm món ăn. Vui lòng thử lại.',
    onRetry: () => _handleAddDish(),
  );
}
```

#### Loading State
```dart
Future<void> _loadData() async {
  ErrorHandler.showLoading(context, message: 'Đang tải...');
  
  try {
    await _apiService.getDishes();
    ErrorHandler.hideLoading(context);
    ErrorHandler.showSuccess(context, message: 'Tải dữ liệu thành công!');
  } catch (e) {
    ErrorHandler.hideLoading(context);
    ErrorHandler.showError(context, error: e);
  }
}
```

#### Warning Message
```dart
if (dishes.isEmpty) {
  ErrorHandler.showWarning(
    context,
    message: 'Chưa có món ăn nào. Thêm món mới để bắt đầu!',
  );
}
```

---

## 🔄 Error Types & Messages

### Firebase Auth Errors

| Error Code | User-Friendly Message | Suggestion |
|------------|----------------------|------------|
| `user-not-found` | Không tìm thấy tài khoản | 💡 Kiểm tra lại email và mật khẩu |
| `wrong-password` | Mật khẩu không đúng | 💡 Kiểm tra lại email và mật khẩu |
| `email-already-in-use` | Email đã được sử dụng | 💡 Thử đăng nhập thay vì đăng ký |
| `invalid-email` | Email không hợp lệ | - |
| `weak-password` | Mật khẩu quá yếu | (tối thiểu 6 ký tự) |
| `too-many-requests` | Quá nhiều yêu cầu | 💡 Đợi vài phút rồi thử lại |
| `network-request-failed` | Lỗi kết nối mạng | 💡 Bật Wi-Fi hoặc dữ liệu di động |

---

### Network Errors

| Error Type | Detection | Message | Suggestion |
|------------|-----------|---------|------------|
| No Internet | `SocketException` | Không có kết nối mạng | 💡 Kiểm tra kết nối mạng |
| DNS Lookup Fail | `Failed host lookup` | Không có kết nối mạng | 💡 Kiểm tra kết nối mạng |
| Timeout | `TimeoutException` | Kết nối quá lâu | 💡 Kiểm tra kết nối mạng hoặc thử lại |

---

### API Errors

| Status Code | Message | Suggestion |
|-------------|---------|------------|
| 404 | Không tìm thấy | - |
| 500 | Không thể kết nối đến máy chủ | 💡 Máy chủ đang gặp sự cố, thử lại sau |
| Timeout | Kết nối quá lâu | 💡 Kiểm tra mạng hoặc thử lại |

---

## 📱 UI Examples

### Error SnackBar
```dart
// Red background
// Icon: none (can add)
// Title: "Không có kết nối mạng"
// Subtitle: "💡 Kiểm tra kết nối mạng của bạn"
// Action: "Thử lại" button (if onRetry provided)
```

### Success SnackBar
```dart
// Green background
// Icon: ✓ check_circle
// Message: "Đã thêm món ăn thành công!"
// Duration: 2 seconds
```

### Warning SnackBar
```dart
// Orange background  
// Icon: ⚠ warning_amber
// Message: "Chưa có món ăn nào"
// Duration: 3 seconds
```

### Loading Dialog
```dart
// Center modal
// CircularProgressIndicator
// Message: "Đang tải..." (optional)
// Non-dismissible
```

---

## ✅ Error Handling trong App

### Existing Error Handling

**App đã có error handling ở nhiều nơi:**

1. **Auth Screens** ✅
   - [`login_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/auth/login_screen.dart)
   - [`register_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/auth/register_screen.dart)
   - [`forgot_password_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/auth/forgot_password_screen.dart)

2. **Admin Panel** ✅
   - [`admin_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/admin/admin_screen.dart)
   - Create/Update/Delete dishes

3. **Profile** ✅
   - [`profile_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart)
   - [`edit_profile_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/profile/edit_profile_screen.dart)

4. **Dish Management** ✅
   - [`dish_detail_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/4_dish_detail/dish_detail_screen.dart)
   - Toggle favorites

5. **Services** ✅
   - [`auth_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/auth_service.dart) - Firebase errors
   - [`api_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/api_service.dart) - API errors
   - [`ai_service.dart`](file:///home/nho/Documents/TodaysEats/lib/core/services/ai_service.dart) - AI errors

---

### Improvement với ErrorHandler

**Before (old style):**
```dart
catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),  // ❌ Raw error
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

**After (với ErrorHandler):**
```dart
catch (e) {
  if (mounted) {
    ErrorHandler.showError(
      context,
      error: e,  // ✅ Auto user-friendly message
      onRetry: () => _handleAction(),  // ✅ Retry button
    );
  }
}
```

---

## 🧪 Testing Error Scenarios

### 1. Network Errors
```dart
// Turn off Wi-Fi/Data
// Try login → Should show "Không có kết nối mạng"
// With suggestion: "💡 Kiểm tra kết nối mạng"
```

### 2. Auth Errors
```dart
// Wrong password
await signIn('test@test.com', 'wrong_password');
// → "Mật khẩu không đúng"
// → "💡 Kiểm tra lại email và mật khẩu"

// Email already exists
await register('existing@email.com', 'password');
// → "Email này đã được sử dụng"
// → "💡 Thử đăng nhập thay vì đăng ký"
```

### 3. API Errors
```dart
// Backend not running
await createDish({...});
// → "Không thể kết nối đến máy chủ"
// → Retry button available
```

### 4. Timeout
```dart
// Slow network
await loadDishes();
// → "Kết nối quá lâu, vui lòng thử lại"
// → "💡 Kiểm tra kết nối mạng hoặc thử lại"
```

---

## 📊 Error Handling Best Practices

### ✅ DO

1. **Always catch errors**
   ```dart
   try {
     await someAsyncOperation();
   } catch (e) {
     ErrorHandler.showError(context, error: e);
   }
   ```

2. **Provide retry mechanism**
   ```dart
   ErrorHandler.showError(
     context,
     error: e,
     onRetry: () => _retryOperation(),
   );
   ```

3. **Show loading states**
   ```dart
   ErrorHandler.showLoading(context);
   try {
     await operation();
     ErrorHandler.hideLoading(context);
   } catch (e) {
     ErrorHandler.hideLoading(context);
     ErrorHandler.showError(context, error: e);
   }
   ```

4. **Log errors for debugging**
   ```dart
   catch (e, stackTrace) {
     ErrorHandler.logError('Login', e, stackTrace);
     ErrorHandler.showError(context, error: e);
   }
   ```

---

### ❌ DON'T

1. **Don't expose raw errors to users**
   ```dart
   // ❌ BAD
   Text('Error: ${e.toString()}')
   
   // ✅ GOOD
   ErrorHandler.showError(context, error: e)
   ```

2. **Don't ignore errors silently**
   ```dart
   // ❌ BAD
   catch (e) {
     print('Error'); // Only print
   }
   
   // ✅ GOOD
   catch (e) {
     ErrorHandler.showError(context, error: e);
     ErrorHandler.logError('Operation', e);
   }
   ```

3. **Don't block UI without dismissing**
   ```dart
   // ❌ BAD
   showLoading();
   await operation(); // If error, loading never hides!
   
   // ✅ GOOD
   try {
     showLoading();
     await operation();
   } finally {
     hideLoading();
   }
   ```

---

## 🎯 Summary

| Feature | Status | Implementation |
|---------|--------|----------------|
| Error detection | ✅ Done | try-catch in all async operations |
| User-friendly messages | ✅ Done | ErrorHandler utility |
| Error suggestions | ✅ Done | Network, Auth, API specific tips |
| Retry mechanism | ✅ Done | onRetry callback in ErrorHandler |
| Loading states | ✅ Done | showLoading/hideLoading |
| Success feedback | ✅ Done | showSuccess() |
| Warning messages | ✅ Done | showWarning() |
| Error logging | ✅ Done | logError() for debugging |

---

## 📝 Notes

**Ưu điểm của ErrorHandler:**
- ✅ Consistent UI across app
- ✅ User-friendly messages (tiếng Việt)
- ✅ Automatic error type detection
- ✅ Built-in retry mechanism
- ✅ Easy to use (1 line of code)

**App behavior:**
- Network error → Gợi ý kiểm tra mạng
- Auth error → Gợi ý kiểm tra thông tin
- API error → Cho phép thử lại
- All errors → Log to console for debugging

**Future enhancements:**
- [ ] Error analytics (track errors to Firebase Analytics)
- [ ] Offline mode support
- [ ] Error page for critical errors
- [ ] Custom error dialogs for specific scenarios

**App đã có error handling tốt! ErrorHandler giúp standardize và improve UX!** ✅
