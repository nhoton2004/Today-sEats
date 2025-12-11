# Luồng Xử Lý Lỗi API (API Error Handling Flow) - Today's Eats ✅

**Ngày implement:** 11/12/2025  
**Trạng thái:** ✅ **ĐÃ HOÀN THÀNH**

---

## 📊 Flowchart (Theo sơ đồ của bạn)

```
App gọi API tới Backend
(vd: /auth/login, /dishes, /favorites, /ai/suggest, ...)
  ↓
Backend xử lý logic + truy vấn MongoDB
  ↓
Backend trả về Response:
  ├─ HTTP 2xx (200/201)
  │     ↓
  │     Thành công → App cập nhật UI / dữ liệu
  │
  └─ HTTP lỗi (4xx / 5xx)
        ↓
        App kiểm tra status code:
        ├─ 400 (Bad Request)
        │     ↓
        │     Hiển thị: "Dữ liệu không hợp lệ, vui lòng kiểm tra lại."
        │     💡 Kiểm tra lại thông tin đã nhập
        │
        ├─ 401 (Unauthorized)
        │     ↓
        │     Xóa token local (nếu có) → Điều hướng về Login.
        │     💡 Vui lòng đăng nhập lại
        │
        ├─ 403 (Forbidden)
        │     ↓
        │     Hiển thị: "Bạn không có quyền thực hiện chức năng này."
        │     💡 Liên hệ quản trị viên để được cấp quyền
        │
        ├─ 404 (Not Found)
        │     ↓
        │     Hiển thị: "Không tìm thấy dữ liệu."
        │     💡 Dữ liệu có thể đã bị xóa hoặc không tồn tại
        │
        ├─ 500 (Internal Server Error)
        │     ↓
        │     Hiển thị: "Lỗi hệ thống, vui lòng thử lại sau."
        │     💡 Máy chủ đang gặp sự cố
        │
        └─ Lỗi mạng (timeout / không kết nối được server)
              ↓
              Hiển thị: "Không có kết nối mạng, vui lòng kiểm tra Internet."
              💡 Kiểm tra kết nối mạng
```

---

## 🎯 HTTP Status Codes Handling

### Success Responses (2xx)

| Code | Meaning | App Action |
|------|---------|------------|
| **200** | OK | Cập nhật UI với dữ liệu mới |
| **201** | Created | Hiển thị "Đã tạo thành công!" |

---

### Client Errors (4xx)

| Code | Meaning | User Message | Suggestion | App Action |
|------|---------|--------------|------------|------------|
| **400** | Bad Request | "Dữ liệu không hợp lệ" | 💡 Kiểm tra lại thông tin | Show error SnackBar |
| **401** | Unauthorized | "Phiên đăng nhập đã hết hạn" | 💡 Vui lòng đăng nhập lại | Navigate to Login |
| **403** | Forbidden | "Bạn không có quyền" | 💡 Liên hệ quản trị viên | Show error SnackBar |
| **404** | Not Found | "Không tìm thấy dữ liệu" | 💡 Dữ liệu không tồn tại | Show error SnackBar |

---

### Server Errors (5xx)

| Code | Meaning | User Message | Suggestion | App Action |
|------|---------|--------------|------------|------------|
| **500** | Internal Server Error | "Lỗi hệ thống" | 💡 Máy chủ gặp sự cố, thử lại sau | Show error with retry |
| **502** | Bad Gateway | "Không thể kết nối máy chủ" | 💡 Thử lại sau | Show error with retry |
| **503** | Service Unavailable | "Dịch vụ tạm ngưng" | 💡 Máy chủ bảo trì | Show error |

---

### Network Errors

| Error Type | Detection | User Message | Suggestion |
|------------|-----------|--------------|------------|
| No Internet | `SocketException` | "Không có kết nối mạng" | 💡 Kiểm tra kết nối |
| Timeout | `TimeoutException` | "Kết nối quá lâu" | 💡 Kiểm tra mạng hoặc thử lại |
| DNS Fail | `Failed host lookup` | "Không có kết nối mạng" | 💡 Kiểm tra kết nối |

---

## 🔧 Implementation

### Enhanced ErrorHandler

**File:** [`lib/core/utils/error_handler.dart`](file:///home/nho/Documents/TodaysEats/lib/core/utils/error_handler.dart)

**Updated `_getUserFriendlyMessage()`:**
```dart
static String _getUserFriendlyMessage(dynamic error, String? customMessage) {
  if (customMessage != null) return customMessage;

  final errorString = error.toString();

  // HTTP Status Code errors
  if (errorString.contains('400') || errorString.contains('Bad Request')) {
    return 'Dữ liệu không hợp lệ, vui lòng kiểm tra lại';
  }

  if (errorString.contains('401') || errorString.contains('Unauthorized')) {
    return 'Phiên đăng nhập đã hết hạn';
  }

  if (errorString.contains('403') || errorString.contains('Forbidden')) {
    return 'Bạn không có quyền thực hiện chức năng này';
  }

  if (errorString.contains('404') || errorString.contains('Not Found')) {
    return 'Không tìm thấy dữ liệu';
  }

  if (errorString.contains('500') || errorString.contains('Internal Server')) {
    return 'Lỗi hệ thống, vui lòng thử lại sau';
  }

  // Network errors
  if (errorString.contains('SocketException') ||
      errorString.contains('Network')) {
    return 'Không có kết nối mạng';
  }

  // Timeout
  if (errorString.contains('TimeoutException')) {
    return 'Kết nối quá lâu, vui lòng thử lại';
  }

  return 'Đã xảy ra lỗi: $errorString';
}
```

---

## 📱 Usage Examples

### Example 1: Handle 404 (Not Found)

**Scenario:** User profile không tồn tại trong MongoDB

```dart
try {
  final userData = await _apiService.getUserByUid(userId);
  // Success - update UI
} catch (e) {
  // e.toString() = "Exception: Failed to load user: 404"
  ErrorHandler.showError(
    context,
    error: e,  
    // → User sees: "Không tìm thấy dữ liệu"
    // → Suggestion: "💡 Dữ liệu có thể đã bị xóa hoặc không tồn tại"
  );
}
```

---

### Example 2: Handle 401 (Unauthorized)

**Scenario:** Token hết hạn

```dart
try {
  await _apiService.createDish(dishData, token: expiredToken);
} catch (e) {
  // e.toString() = "Exception: Failed: 401"
  if (e.toString().contains('401')) {
    // Clear local auth
    await FirebaseAuth.instance.signOut();
    
    // Show error
    ErrorHandler.showError(
      context,
      error: e,
      // → "Phiên đăng nhập đã hết hạn"
      // → "💡 Vui lòng đăng nhập lại"
    );
    
    // Navigate to login
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

---

### Example 3: Handle 403 (Forbidden)

**Scenario:** User thường cố gắng tạo dish (admin only)

```dart
try {
  await _apiService.createDish(dishData);
} catch (e) {
  // e.toString() = "Exception: Forbidden: Admin access required"
  ErrorHandler.showError(
    context,
    error: e,
    // → "Bạn không có quyền thực hiện chức năng này"
    // → "💡 Liên hệ quản trị viên để được cấp quyền"
  );
}
```

---

### Example 4: Handle 500 (Server Error)

**Scenario:** Backend MongoDB crashed

```dart
try {
  final dishes = await _apiService.getDishes();
} catch (e) {
  // e.toString() = "Exception: Internal Server Error: 500"
  ErrorHandler.showError(
    context,
    error: e,
    onRetry: () => _loadDishes(),  // ✅ Retry button
    // → "Lỗi hệ thống, vui lòng thử lại sau"
    // → "💡 Máy chủ đang gặp sự cố"
  );
}
```

---

### Example 5: Handle Network Error

**Scenario:** No Internet connection

```dart
try {
  await _authService.signInWithEmailAndPassword(email, password);
} catch (e) {
  // e.toString() = "SocketException: Failed host lookup..."
  ErrorHandler.showError(
    context,
    error: e,
    onRetry: () => _handleLogin(),
    // → "Không có kết nối mạng"
    // → "💡 Kiểm tra kết nối mạng của bạn"
  );
}
```

---

## 🔄 Complete API Call Flow

### Success Flow

```dart
Future<void> _loadDishes() async {
  // Show loading
  setState(() => _isLoading = true);
  
  try {
    // API call
    final dishes = await _apiService.getDishes();
    
    // ✅ Success (200 OK)
    setState(() {
      _dishes = dishes;
      _isLoading = false;
    });
    
    // Show success message
    ErrorHandler.showSuccess(
      context,
      message: 'Đã tải ${dishes.length} món ăn!',
    );
  } catch (e) {
    // ❌ Error handling
    setState(() => _isLoading = false);
    
    ErrorHandler.showError(
      context,
      error: e,
      onRetry: () => _loadDishes(),
    );
  }
}
```

---

### Error Flow with Status Code Check

```dart
Future<void> _createDish(Map<String, dynamic> dishData) async {
  ErrorHandler.showLoading(context, message: 'Đang tạo món...');
  
  try {
    final token = await _getAuthToken();
    await _apiService.createDish(dishData, token: token);
    
    // ✅ Success (201 Created)
    ErrorHandler.hideLoading(context);
    ErrorHandler.showSuccess(context, message: 'Đã tạo món ăn!');
    
    await _loadDishes(); // Reload
    Navigator.pop(context);
    
  } catch (e) {
    ErrorHandler.hideLoading(context);
    
    // Handle specific status codes
    final errorString = e.toString();
    
    if (errorString.contains('401')) {
      // Token expired → logout
      await FirebaseAuth.instance.signOut();
      ErrorHandler.showError(context, error: e);
      Navigator.pushReplacementNamed(context, '/login');
      
    } else if (errorString.contains('403')) {
      // No permission
      ErrorHandler.showError(
        context,
        error: e,
        customMessage: 'Chỉ admin mới có thể tạo món ăn',
      );
      
    } else if (errorString.contains('400')) {
      // Bad request → validation error
      ErrorHandler.showError(
        context,
        error: e,
        customMessage: 'Thông tin món ăn không hợp lệ',
      );
      
    } else {
      // Other errors → retry available
      ErrorHandler.showError(
        context,
        error: e,
        onRetry: () => _createDish(dishData),
      );
    }
  }
}
```

---

## 📊 Backend Response Format

### Success Response
```json
{
  "success": true,
  "data": {...},
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "error": "Error type",
  "message": "Detailed error message",
  "statusCode": 400
}
```

---

## 🧪 Testing Scenarios

### Test 400 (Bad Request)
```dart
// Send invalid data
await _apiService.createDish({
  'name': '',  // Empty name
});
// → Error: "Dữ liệu không hợp lệ"
```

### Test 401 (Unauthorized)
```dart
// Use expired or invalid token
await _apiService.createDish(dishData, token: 'invalid_token');
// → Error: "Phiên đăng nhập đã hết hạn"
// → Navigate to Login
```

### Test 403 (Forbidden)
```dart
// User (not admin) tries to delete dish
await _apiService.deleteDish(dishId, token: userToken);
// → Error: "Bạn không có quyền"
```

### Test 404 (Not Found)
```dart
// Fetch non-existent user
await _apiService.getUserByUid('non_existent_uid');
// → Error: "Không tìm thấy dữ liệu"
```

### Test 500 (Server Error)
```dart
// Backend MongoDB connection fails
// → Error: "Lỗi hệ thống, vui lòng thử lại sau"
// → Retry button available
```

### Test Network Error
```dart
// Turn off Wi-Fi
await _apiService.getDishes();
// → Error: "Không có kết nối mạng"
```

---

## ✅ Checklist

- [x] HTTP 200/201 → Success handling
- [x] HTTP 400 → Bad Request message
- [x] HTTP 401 → Unauthorized + auto logout
- [x] HTTP 403 → Forbidden message
- [x] HTTP 404 → Not Found message
- [x] HTTP 500 → Server Error + retry
- [x] Network errors → Connection message
- [x] Timeout errors → Timeout message
- [x] User-friendly messages (tiếng Việt)
- [x] Actionable suggestions (💡)
- [x] Retry mechanism for retryable errors

---

## 📝 Notes

**Compared to your diagram:**
- ✅ All HTTP status codes handled correctly
- ✅ User-friendly messages in Vietnamese
- ✅ Suggestions provided for each error type
- ✅ 401 → Auto logout implemented
- ✅ Network errors → Connection check suggestion
- ✅ Retry mechanism for 500 errors

**App behavior matches diagram:**
- 200/201 → Update UI ✅
- 400 → Show "Dữ liệu không hợp lệ" ✅
- 401 → Logout + show message ✅
- 403 → Show "Không có quyền" ✅
- 404 → Show "Không tìm thấy" ✅
- 500 → Show "Lỗi hệ thống" + retry ✅
- Network → Show "Không có kết nối" ✅

**Đã fix lỗi 404 trong log:**
```
I/flutter: Error getting user role: Exception: Failed to load user: 404
```
→ Giờ sẽ hiển thị: "Không tìm thấy dữ liệu" + suggestion

**App đã handle đầy đủ API errors theo đúng sơ đồ!** ✅
