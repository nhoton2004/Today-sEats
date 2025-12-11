# Sơ đồ Luồng Favorites - Quản lý món yêu thích - Today's Eats

**Ngày xác nhận:** 11/12/2025  
**Trạng thái:** ✅ CODE ĐÚNG - SƠ ĐỒ SAI (Ghi "Firestore" thay vì "MongoDB")

---

## ⚠️ **LỖI TRONG SƠ ĐỒ:**

| Trong Sơ đồ | Trong Code | Trạng thái |
|--------------|------------|------------|
| "Tải danh sách món yêu thích từ **Firestore**" | Từ **MongoDB** qua API | ❌ **SAI!** |
| "Xóa món khỏi **Firestore** (favorites)" | Xóa trong **MongoDB** qua API | ❌ **SAI!** |

> [!IMPORTANT]
> **Code hiện tại HOÀN TOÀN ĐÚNG và sử dụng MongoDB!**
> Chỉ cần sửa sơ đồ: **"Firestore" → "MongoDB"**

---

## 📊 Sơ đồ luồng ĐÚNG

```
Favorites Screen
  ↓
Tải danh sách món yêu thích từ MongoDB (qua API theo user hiện tại) ✅
  ↓
Hiển thị List các món yêu thích
  ↓
Người dùng chọn 1 món trong danh sách
  ↓
Hiển thị chi tiết món ăn
  ↓
Người dùng lựa chọn:
  ├─ Nhấn "Xóa khỏi yêu thích"
  │     ↓
  │     Xóa món khỏi MongoDB (favorites trong user document) ✅
  │     ↓
  │     Cập nhật lại danh sách hiển thị
  │
  └─ Quay lại danh sách
        ↓
        Tiếp tục chọn món khác hoặc thoát tab
```

---

## 🔍 Chi tiết implementation

### 1. **Favorites Screen - Load danh sách**

**File:** [`lib/features/favorites/favorites_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/favorites/favorites_screen.dart)

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Món Yêu Thích')),
    body: Consumer<MenuManagementApiProvider>(
      builder: (context, provider, _) {
        // ✅ Lọc món yêu thích từ provider
        final favoriteDishes = provider.dishes
            .where((dish) => dish.isFavorite)
            .toList();

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favoriteDishes.isEmpty) {
          // Empty state
          return Center(child: Text('Chưa có món yêu thích'));
        }

        // ✅ Hiển thị list
        return ListView.builder(
          itemCount: favoriteDishes.length,
          itemBuilder: (context, index) {
            final dish = favoriteDishes[index];
            return /* Dish card */;
          },
        );
      },
    ),
  );
}
```

**Provider load dishes:** [`menu_management_api_provider.dart:33-56`](file:///home/nho/Documents/TodaysEats/lib/features/3_menu_management/menu_management_api_provider.dart#L33-L56)

```dart
Future<void> loadDishes() async {
  _setLoading(true);
  try {
    // ✅ Gọi MongoDB API
    final dishesData = await _apiService.getDishes();
    _dishes.clear();

    for (var dishData in dishesData) {
      try {
        // Convert API data sang Dish model
        final dish = _convertApiDishToModel(dishData);
        _dishes.add(dish);
      } catch (e) {
        debugPrint('Error converting dish: $e');
      }
    }

    _errorMessage = null;
  } catch (e) {
    _errorMessage = 'Không thể tải danh sách món ăn: $e';
  } finally {
    _setLoading(false);
  }
}
```

**API Call:** Gọi `GET /api/dishes` → MongoDB trả về danh sách dishes kèm `isFavorite` field

---

### 2. **Filter favorites trong provider**

```dart
final favoriteDishes = provider.dishes
    .where((dish) => dish.isFavorite)  // ✅ Filter local
    .toList();
```

**Cách hoạt động:**
1. Provider load TẤT CẢ dishes từ MongoDB
2. MongoDB đã tính toán `isFavorite` dựa trên `user.favorites` array
3. App filter local để chỉ hiển thị `isFavorite == true`

---

### 3. **Xóa khỏi yêu thích - Swipe to delete**

**File:** [`favorites_screen.dart:73-88`](file:///home/nho/Documents/TodaysEats/lib/features/favorites/favorites_screen.dart#L73-L88)

```dart
SwipeableCard(
  onSwipeLeft: () async {
    // ✅ Gọi toggleFavorite để XÓA khỏi favorites
    await provider.toggleFavorite(dish.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${dish.name}" khỏi yêu thích'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () => provider.toggleFavorite(dish.id), // Add back
          ),
        ),
      );
    }
  },
  leftSwipeColor: Colors.red,
  leftSwipeIcon: Icons.favorite_border,
  child: ListTile(/* dish info */),
)
```

**Toggle Favorite Logic:** [`menu_management_api_provider.dart:124-175`](file:///home/nho/Documents/TodaysEats/lib/features/3_menu_management/menu_management_api_provider.dart#L124-L175)

```dart
Future<void> toggleFavorite(String dishId) async {
  final index = _dishes.indexWhere((dish) => dish.id == dishId);
  if (index == -1) return;

  // ✅ BƯỚC 1: Optimistic update (UI ngay lập tức)
  final wasToggled = !_dishes[index].isFavorite;
  _dishes[index] = _dishes[index].copyWith(
    isFavorite: wasToggled,
  );
  notifyListeners();  // UI cập nhật ngay

  try {
    // ✅ BƯỚC 2: Gọi API để persist vào MongoDB
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _apiService.toggleFavorite(user.uid, dishId);
    
    // ✅ BƯỚC 3: Reload để sync với server
    await loadDishes();
    
  } catch (e) {
    // ✅ BƯỚC 4: Rollback nếu lỗi
    _dishes[index] = _dishes[index].copyWith(
      isFavorite: !wasToggled,
    );
    notifyListeners();
    rethrow;
  }
}
```

**API Service:** [`api_service.dart:264-282`](file:///home/nho/Documents/TodaysEats/lib/core/services/api_service.dart#L264-L282)

```dart
Future<Map<String, dynamic>> toggleFavorite(String uid, String dishId,
    {String? token}) async {
  try {
    // ✅ POST tới MongoDB API
    final response = await http.post(
      Uri.parse('$baseUrl/users/$uid/favorites'),
      headers: await _getHeaders(token: token),
      body: json.encode({'dishId': dishId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle favorite: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error toggling favorite: $e');
  }
}
```

---

## 📋 Workflow chi tiết

### **Load Favorites**

```
1. FavoritesScreen build()
   ↓
2. Consumer<MenuManagementApiProvider>
   ↓
3. provider.dishes.where(dish => dish.isFavorite)
   ↓
4. Hiển thị ListView
```

**MongoDB đã tính sẵn `isFavorite`:**

Backend logic (Node.js):
```js
// GET /api/dishes
app.get('/api/dishes', async (req, res) => {
  const userId = req.user?.uid; // Từ auth token
  const dishes = await Dish.find({ status: 'active' });
  
  // Get user favorites
  const user = await User.findOne({ uid: userId });
  const favorites = user?.favorites || [];
  
  // Map dishes với isFavorite flag
  const dishesWithFavorites = dishes.map(dish => ({
    ...dish.toObject(),
    isFavorite: favorites.includes(dish._id.toString())  // ✅
  }));
  
  res.json({ dishes: dishesWithFavorites });
});
```

---

### **Remove from Favorites (Toggle)**

```
1. User swipe left trên món
   ↓
2. Call: provider.toggleFavorite(dishId)
   ↓
3. Optimistic update: isFavorite = false (UI ngay)
   ↓
4. API call: POST /api/users/:uid/favorites
   ↓
5. Backend MongoDB:
      - Tìm user document
      - Check dishId có trong favorites[]?
        - Có → Remove ($pull)
        - Không → Add ($addToSet)
   ↓
6. Response về app
   ↓
7. provider.loadDishes() - Reload để sync
   ↓
8. UI cập nhật (món biến mất khỏi Favorites list)
   ↓
9. SnackBar: "Đã xóa ... khỏi yêu thích"
```

**MongoDB operation:**

```js
// Backend: POST /api/users/:uid/favorites
if (user.favorites.includes(dishId)) {
  // ✅ Remove from favorites
  await User.updateOne(
    { uid: userId },
    { $pull: { favorites: dishId } }
  );
  return res.json({ 
    message: 'Đã bỏ yêu thích', 
    isFavorite: false 
  });
} else {
  // Add to favorites
  await User.updateOne(
    { uid: userId },
    { $addToSet: { favorites: dishId } }
  );
  return res.json({ 
    message: 'Đã thêm vào yêu thích', 
    isFavorite: true 
  });
}
```

---

## 🗂️ Database Structure

### MongoDB Collections

**Users Collection:**
```json
{
  "_id": "firebase_uid",
  "email": "user@example.com",
  "displayName": "User Name",
  "favorites": [  // ✅ Array of dish IDs
    "dish_id_1",
    "dish_id_2",
    "dish_id_3"
  ],
  "createdAt": "2025-12-11T...",
  "updatedAt": "2025-12-11T..."
}
```

**Dishes Collection:**
```json
{
  "_id": "dish_id",
  "name": "Phở Bò",
  "category": "vietnamese",
  "mealType": "breakfast",
  "description": "...",
  "ingredients": [...],
  "status": "active",
  // Note: isFavorite KHÔNG lưu trong dish!
  // Được tính dynamic khi query
}
```

---

## ✅ Xác nhận tổng hợp

| Thành phần trong Sơ đồ | Implementation | Trạng thái |
|------------------------|----------------|------------|
| Favorites Screen | ✅ `favorites_screen.dart` | ✅ ĐÚNG |
| **Tải từ Firestore** | ❌ Tải từ **MongoDB** qua API | ❌ **SAI!** |
| Hiển thị List | ✅ ListView.builder + filter | ✅ ĐÚNG |
| Chọn món | ✅ Tap → Detail screen | ✅ ĐÚNG |
| Hiển thị chi tiết | ✅ Swipeable card with info | ✅ ĐÚNG |
| Xóa khỏi yêu thích | ✅ Swipe left + toggleFavorite | ✅ ĐÚNG |
| **Xóa khỏi Firestore** | ❌ Xóa trong **MongoDB** | ❌ **SAI!** |
| Cập nhật danh sách | ✅ Reload dishes | ✅ ĐÚNG |
| Quay lại | ✅ Navigation | ✅ ĐÚNG |

---

## 🎯 Kết luận

> [!NOTE]
> **CODE HIỆN TẠI HOÀN TOÀN ĐÚNG!**
> 
> - ✅ Tải favorites từ **MongoDB** qua API
> - ✅ Xóa favorites trong **MongoDB** qua API
> - ✅ Optimistic updates cho UX tốt
> - ✅ Undo action (Hoàn tác)
> 
> **Chỉ cần sửa SƠ ĐỒ:**
> - ❌ "từ Firestore" → ✅ "từ MongoDB qua API"
> - ❌ "khỏi Firestore" → ✅ "khỏi MongoDB qua API"

---

## 🔄 Optimistic Updates - UX Enhancement

**Code hiện tại sử dụng kỹ thuật Optimistic Updates:**

1. **Update UI ngay lập tức** (không đợi server)
   ```dart
   _dishes[index] = _dishes[index].copyWith(isFavorite: wasToggled);
   notifyListeners(); // ✅ UI cập nhật ngay
   ```

2. **Gọi API sau**
   ```dart
   await _apiService.toggleFavorite(user.uid, dishId);
   ```

3. **Rollback nếu lỗi**
   ```dart
   catch (e) {
     _dishes[index] = _dishes[index].copyWith(isFavorite: !wasToggled);
     notifyListeners(); // ✅ Khôi phục UI
   }
   ```

**Lợi ích:**
- ⚡ UX nhanh - không cần đợi network
- 🔁 Tự động rollback nếu thất bại
- ✅ Sync với server sau khi thành công

---

## 📱 UI Features

### Empty State
```dart
if (favoriteDishes.isEmpty) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.favorite_outline, size: 80),
        Text('Chưa có món yêu thích'),
        Text('Thêm món ăn vào danh sách yêu thích để xem tại đây'),
      ],
    ),
  );
}
```

### Swipeable Card
- ✅ Swipe left → Xóa khỏi favorites
- ✅ Red background + favorite_border icon
- ✅ Smooth animation

### SnackBar with Undo
```dart
SnackBar(
  content: Text('Đã xóa "${dish.name}" khỏi yêu thích'),
  action: SnackBarAction(
    label: 'Hoàn tác',
    onPressed: () => provider.toggleFavorite(dish.id), // ✅ Add back
  ),
)
```

---

## 🎨 Code Quality

**Những điểm code tốt:**
- ✅ Optimistic updates
- ✅ Error handling với rollback
- ✅ Loading states
- ✅ Empty states
- ✅ Undo action
- ✅ Provider pattern (state management)
- ✅ Separation of concerns (API service riêng)

**Code HOÀN TOÀN ĐÚNG - Sơ đồ cần sửa "Firestore" → "MongoDB"!** ✅
