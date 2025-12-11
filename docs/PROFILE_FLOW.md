# Sơ đồ Luồng Profile - Hồ sơ người dùng - Today's Eats

**Ngày xác nhận:** 11/12/2025  
**Trạng thái:** ⚠️ SƠ ĐỒ SAI - Code lấy từ Firebase Auth, không phải Firestore

---

## ⚠️ **LỖI QUAN TRỌNG TRONG SƠ ĐỒ:**

| Trong Sơ đồ | Trong Code | Trạng thái |
|--------------|------------|------------|
| "Tải thông tin người dùng từ **Firestore** (theo uid)" | Từ **Firebase Auth** + stats từ **MongoDB** | ❌ **SAI!** |
| "Cập nhật dữ liệu user trong **Firestore**" | ❌ **Không có** chức năng cập nhật | ❌ **SAI!** |

> [!IMPORTANT]
> **Thông tin user được lấy từ 2 nguồn:**
> 1. **Firebase Auth:** displayName, email, photoURL
> 2. **MongoDB API:** Thống kê (dishesCreated, favoritesCount, cookedCount)
> 
> **App KHÔNG sử dụng Firestore!**

---

## 📊 Sơ đồ luồng ĐÚNG

```
Profile Screen
  ↓
Tải thông tin người dùng:
  ├─ Thông tin cơ bản từ Firebase Auth (currentUser) ✅
  │  - displayName
  │  - email
  │  - photoURL
  │
  └─ Thống kê từ MongoDB API ✅
     - Số món ăn đã tạo
     - Số món yêu thích
     - Số món đã nấu
  ↓
Hiển thị: Tên, Email, Ảnh đại diện, Thống kê
  ↓
Người dùng lựa chọn:
  ├─ Chỉnh sửa thông tin ⚠️ (TODO - Chưa implement)
  ├─ Cài đặt → SettingsScreen
  ├─ Thông báo (TODO)
  ├─ Trợ giúp (TODO)
  ├─ Về ứng dụng (TODO)
  │
  └─ Đăng xuất (Logout)
        ↓
        Hiển thị confirm dialog
        ↓
        Gọi Firebase Auth (signOut) ✅
        ↓
        Điều hướng về Login Screen
```

---

## 🔍 Chi tiết implementation

### 1. **Load thông tin user - Firebase Auth**

**File:** [`lib/features/profile/profile_screen.dart:54-65`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart#L54-L65)

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: StreamBuilder<User?>(
      // ✅ Lắng nghe Firebase Auth state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user == null) {
          return const Center(child: Text('Chưa đăng nhập'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, user),  // ✅ Firebase Auth User
              _buildStatsSection(),         // ✅ MongoDB stats
              _buildMenuSection(context),
            ],
          ),
        );
      },
    ),
  );
}
```

**Firebase Auth User object:**
```dart
User user = FirebaseAuth.instance.currentUser!;

// Properties available:
user.uid           // ✅ User ID
user.displayName   // ✅ Tên hiển thị
user.email         // ✅ Email
user.photoURL      // ✅ URL ảnh đại diện
user.emailVerified // ✅ Email đã verify chưa
```

---

### 2. **Hiển thị thông tin - Header**

**File:** [`profile_screen.dart:84-152`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart#L84-L152)

```dart
Widget _buildHeader(BuildContext context, User user) {
  // ✅ Lấy từ Firebase Auth User
  final displayName = user.displayName ?? 'Người dùng';
  final email = user.email ?? '';
  final photoURL = user.photoURL;

  return Container(
    child: Column(
      children: [
        CircleAvatar(
          radius: 50,
          // ✅ Nếu có photoURL → dùng NetworkImage
          // ✅ Nếu không → dùng UI Avatars API
          backgroundImage: photoURL != null && photoURL.isNotEmpty
              ? NetworkImage(photoURL)
              : NetworkImage(
                  'https://ui-avatars.com/api/'
                  '?name=${Uri.encodeComponent(displayName)}'
                  '&size=200&background=FF6B35&color=fff',
                ),
        ),
        const SizedBox(height: 16),
        // ✅ Hiển thị tên
        Text(displayName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        // ✅ Hiển thị email
        Text(email, style: TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    ),
  );
}
```

**UI Avatars API:** Tạo avatar tự động từ tên người dùng
- URL: `https://ui-avatars.com/api/?name=John+Doe&size=200&background=FF6B35&color=fff`
- Trả về: Hình ảnh avatar với chữ cái đầu tiên của tên

---

### 3. **Load thống kê - MongoDB API**

**File:** [`profile_screen.dart:27-47`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart#L27-L47)

```dart
Future<void> _loadUserStats() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    // ✅ GET stats từ MongoDB qua API
    final stats = await _apiService.getUserStats(user.uid);
    
    setState(() {
      _userStats = stats;
      _isLoadingStats = false;
    });
  } catch (e) {
    setState(() => _isLoadingStats = false);
    print('Error loading user stats: $e');
  }
}
```

**API Service:** [`api_service.dart:285-297`](file:///home/nho/Documents/TodaysEats/lib/core/services/api_service.dart#L285-L297)

```dart
Future<Map<String, dynamic>> getUserStats(String uid) async {
  try {
    // ✅ GET request tới MongoDB backend
    final response = await http.get(
      Uri.parse('$baseUrl/users/$uid/stats')
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user stats: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching user stats: $e');
  }
}
```

**Backend endpoint:** `GET /api/users/:uid/stats`

**Response format:**
```json
{
  "dishesCreated": 12,    // Số món ăn user đã tạo
  "favoritesCount": 25,   // Số món yêu thích
  "cookedCount": 8,       // Số món đã nấu (future feature)
  "uid": "firebase_uid"
}
```

---

### 4. **Hiển thị thống kê**

**File:** [`profile_screen.dart:155-196`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart#L155-L196)

```dart
Widget _buildStatsSection() {
  if (_isLoadingStats) {
    return const Center(child: CircularProgressIndicator());
  }

  // ✅ Lấy thống kê từ MongoDB response
  final dishesCreated = _userStats?['dishesCreated'] ?? 0;
  final favoritesCount = _userStats?['favoritesCount'] ?? 0;
  final cookedCount = _userStats?['cookedCount'] ?? 0;

  return Row(
    children: [
      Expanded(child: _buildStatCard(dishesCreated.toString(), 'Món ăn', Icons.restaurant_menu)),
      Expanded(child: _buildStatCard(favoritesCount.toString(), 'Yêu thích', Icons.favorite)),
      Expanded(child: _buildStatCard(cookedCount.toString(), 'Đã nấu', Icons.check_circle)),
    ],
  );
}
```

---

### 5. **Chỉnh sửa thông tin - CHƯA IMPLEMENT**

**File:** [`profile_screen.dart:234-241`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart#L234-L241)

```dart
_buildMenuItem(
  context,
  icon: Icons.person_outline,
  title: 'Thông tin cá nhân',
  onTap: () {
    // ⚠️ TODO: Navigate to edit profile
  },
),
```

> [!NOTE]
> **Chức năng chỉnh sửa profile CHƯA được implement!**
> - Sơ đồ có luồng "Chỉnh sửa thông tin" nhưng code chỉ có comment TODO
> - Không có màn hình edit profile
> - Không có API cập nhật user info

---

### 6. **Đăng xuất - Firebase Auth signOut**

**File:** [`profile_screen.dart:335-376`](file:///home/nho/Documents/TodaysEats/lib/features/profile/profile_screen.dart#L335-L376)

```dart
void _showLogoutDialog(BuildContext context) {
  final authService = AuthService();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              // ✅ Gọi signOut
              await authService.signOut();
              
              if (context.mounted) {
                Navigator.pop(context);  // Đóng dialog
                // ✅ Navigate về Login
                Navigator.pushReplacementNamed(context, '/login');
              }
            } catch (e) {
              // Error handling
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}
```

**Auth Service signOut:** [`auth_service.dart:145-155`](file:///home/nho/Documents/TodaysEats/lib/core/services/auth_service.dart#L145-L155)

```dart
Future<void> signOut() async {
  try {
    await Future.wait([
      _googleSignIn.signOut(),  // ✅ Sign out Google
      _auth.signOut(),          // ✅ Sign out Firebase
    ]);
  } catch (e) {
    // Ignore errors on sign out
    await _auth.signOut();
  }
}
```

---

## 📋 Workflow đầy đủ

### **Load Profile Data**

```
1. ProfileScreen build
   ↓
2. StreamBuilder<User?>(
     stream: FirebaseAuth.instance.authStateChanges()
   )
   ↓
3. Có user? 
   ├─ Yes → Tiếp tục
   └─ No → Hiển thị "Chưa đăng nhập"
   ↓
4. Parallel loading:
   ├─ Load từ Firebase Auth (currentUser)  ✅
   │  - displayName
   │  - email
   │  - photoURL
   │
   └─ Load từ MongoDB API ✅
      GET /api/users/:uid/stats
      ↓
      Response: {
        dishesCreated: 12,
        favoritesCount: 25,
        cookedCount: 8
      }
   ↓
5. Render UI với data
```

---

### **Logout Flow**

```
1. User nhấn "Đăng xuất"
   ↓
2. Hiển thị AlertDialog confirm
   ↓
3. User nhấn "Đăng xuất" (confirm)
   ↓
4. authService.signOut()
   ├─ GoogleSignIn.signOut()  ✅
   └─ FirebaseAuth.signOut()  ✅
   ↓
5. Navigator.pushReplacementNamed('/login')
   ↓
6. User về Login Screen
```

---

## 🗂️ Data Sources

### Firebase Auth (Authentication data)
```dart
FirebaseAuth.instance.currentUser
  ├─ uid: String
  ├─ displayName: String?
  ├─ email: String?
  ├─ photoURL: String?
  ├─ emailVerified: bool
  └─ phoneNumber: String?
```

**Đặc điểm:**
- ✅ Real-time updates qua `authStateChanges()` stream
- ✅ Automatically updated khi login/logout
- ✅ Persistent across app restarts
- ❌ **KHÔNG** lưu custom user data

---

### MongoDB (User statistics)
```json
// GET /api/users/:uid/stats
{
  "uid": "firebase_uid",
  "dishesCreated": 12,      // Số món user đã tạo
  "favoritesCount": 25,     // Số món yêu thích
  "cookedCount": 8,         // Số món đã nấu
  "joinedDate": "2025-01-01T00:00:00Z"
}
```

**Đặc điểm:**
- ✅ Custom business logic data
- ✅ Aggregated từ các collections khác
- ✅ RESTful API
- ❌ Không real-time (need manual reload)

---

## ✅ Xác nhận tổng hợp

| Thành phần trong Sơ đồ | Implementation | Trạng thái |
|------------------------|----------------|------------|
| Profile Screen | ✅ `profile_screen.dart` | ✅ ĐÚNG |
| **Tải từ Firestore** | ❌ Tải từ **Firebase Auth** + **MongoDB** | ❌ **SAI!** |
| Hiển thị tên, email, ảnh | ✅ Từ Firebase Auth User | ✅ ĐÚNG |
| Hiển thị thống kê | ✅ Từ MongoDB API | ✅ ĐÚNG (thiếu trong sơ đồ) |
| **Chỉnh sửa thông tin** | ❌ **TODO - Chưa implement** | ⚠️ **KHÁC** |
| **Cập nhật Firestore** | ❌ **Không có** | ❌ **SAI!** |
| Đăng xuất | ✅ Firebase Auth signOut | ✅ ĐÚNG |
| Navigate → Login | ✅ `pushReplacementNamed('/login')` | ✅ ĐÚNG |

---

## 🎯 Kết luận

> [!IMPORTANT]
> **3 LỖI CHÍNH trong sơ đồ:**
> 
> 1. **"Tải thông tin từ Firestore"** → SAI!
>    - ✅ Đúng: Từ **Firebase Auth** (thông tin cơ bản) + **MongoDB** (thống kê)
> 
> 2. **"Cập nhật dữ liệu user trong Firestore"** → SAI!
>    - ❌ Chức năng edit profile **CHƯA được implement**
>    - ❌ Không có API cập nhật user info
> 
> 3. **Thiếu thống kê** → Sơ đồ không đề cập
>    - ✅ Code có hiển thị stats từ MongoDB (dishesCreated, favoritesCount, cookedCount)

**Sơ đồ ĐÚNG phải là:**

```
Profile Screen
  ↓
Tải thông tin:
  ├─ Firebase Auth: displayName, email, photoURL ✅
  └─ MongoDB API: dishesCreated, favoritesCount, cookedCount ✅
  ↓
Hiển thị profile với stats
  ↓
Người dùng có thể:
  ├─ Xem thông tin (read-only) ✅
  ├─ Xem thống kê ✅
  ├─ Vào Settings ✅
  └─ Đăng xuất (Firebase Auth signOut) ✅
```

**App KHÔNG sử dụng Firestore! Dữ liệu từ Firebase Auth + MongoDB!** ✅
