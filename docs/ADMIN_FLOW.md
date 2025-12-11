# Sơ đồ Luồng Admin - Quản trị món ăn - Today's Eats

**Ngày xác nhận:** 11/12/2025  
**Trạng thái:** ❌ **CODE CHƯA KHỚP VỚI SƠ ĐỒ - CHỈ LÀ UI DEMO**

---

## ⚠️ **VẤN ĐỀ NGHIÊM TRỌNG:**

| Trong Sơ đồ | Trong Code | Trạng thái |
|--------------|------------|------------|
| "Tải danh sách từ **Firestore**" | ❌ Dữ liệu **hardcoded** local | ❌ **SAI!** |
| "Thêm document vào **Firestore**" | ❌ **TODO** - chưa implement | ❌ **SAI!** |
| "Cập nhật document trong **Firestore**" | ❌ **TODO** - chưa implement | ❌ **SAI!** |
| "Xóa document trên **Firestore**" | ❌ Chỉ xóa local state | ❌ **SAI!** |

> [!CAUTION]
> **AdminScreen hiện tại CHỈ LÀ UI DEMO!**
> - ❌ Data hardcoded (3 món ăn mẫu)
> - ❌ Không kết nối database (Firestore hay MongoDB)
> - ❌ Thêm món: TODO
> - ❌ Sửa món: TODO  
> - ❌ Xóa món: Chỉ xóa local state (không persist)
> - ❌ Thống kê: Dữ liệu fake

---

## 📊 **Code hiện tại (Demo UI)**

**File:** [`lib/features/admin/admin_screen.dart`](file:///home/nho/Documents/TodaysEats/lib/features/admin/admin_screen.dart)

```dart
class _AdminScreenState extends State<AdminScreen> {
  // ❌ Dữ liệu HARDCODED - không load từ database
  final List<Map<String, dynamic>> _dishes = [
    {
      'name': 'Phở Bò',
      'category': 'Món chính',
      'status': 'active',
      'image': 'https://images.unsplash.com/...',
    },
    {
      'name': 'Bún Chả',
      'category': 'Món chính',
      'status': 'active',
      'image': 'https://images.unsplash.com/...',
    },
    {
      'name': 'Bánh Mì',
      'category': 'Món ăn sáng',
      'status': 'inactive',
      'image': 'https://images.unsplash.com/...',
    },
  ];
  
  // ❌ TODO - Chưa implement
  void _showAddDishDialog() {
    // ...
    onPressed: () {
      // TODO: Implement add dish  ❌
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm món ăn')),
      );
    }
  }
  
  // ❌ TODO - Chưa implement
  void _showEditDishDialog(Map<String, dynamic> dish, int index) {
    // TODO: Implement edit dialog  ❌
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa ${dish['name']}')),
    );
  }
  
  // ❌ Chỉ xóa local state - KHÔNG xóa trong database
  void _showDeleteDishDialog(int index) {
    onPressed: () {
      setState(() => _dishes.removeAt(index));  // ❌ Local only!
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa món ăn')),
      );
    }
  }
}
```

---

## 📋 **Sơ đồ ĐÚNG (Theo yêu cầu):**

```
Admin Panel
  ↓
Đăng nhập với tài khoản có quyền Admin
  ↓
Tải danh sách món ăn từ MongoDB (qua API) ✅ (Sửa từ Firestore)
  ↓
Hiển thị danh sách món ăn
  ↓
Admin lựa chọn:
  
├─ 1) Thêm món ăn mới
│     ↓
│     Nhập thông tin: Tên, Ảnh, Nguyên liệu, Mô tả, Loại món,...
│     ↓
│     Nhấn "Lưu"
│     ↓
│     POST /api/dishes (MongoDB) ✅
│     ↓
│     Cập nhật lại danh sách món
│
├─ 2) Sửa món ăn
│     ↓
│     Chọn 1 món trong danh sách
│     ↓
│     Chỉnh sửa thông tin
│     ↓
│     Nhấn "Lưu"
│     ↓
│     PUT /api/dishes/:id (MongoDB) ✅
│     ↓
│     Cập nhật lại danh sách món
│
└─ 3) Xóa món ăn
      ↓
      Chọn 1 món trong danh sách
      ↓
      Nhấn "Xóa"
      ↓
      Xác nhận xóa
      ↓
      DELETE /api/dishes/:id (MongoDB) ✅
      ↓
      Cập nhật lại danh sách món
```

**Lưu ý: App sử dụng MongoDB, KHÔNG phải Firestore!**

---

## ❌ **So sánh Chi tiết:**

### 1. Load Danh sách món

**Sơ đồ:** "Tải danh sách từ Firestore"
```javascript
// Expected
const dishes = await Firestore.collection('dishes').get();
```

**Code thực tế:** Hardcoded local array
```dart
// ❌ WRONG - Static data
final List<Map<String, dynamic>> _dishes = [
  {'name': 'Phở Bò', ...},
  {'name': 'Bún Chả', ...},
  {'name': 'Bánh Mì', ...},
];
```

**Đúng phải là:** Load từ MongoDB qua API
```dart
// ✅ CORRECT
Future<void> _loadDishes() async {
  final dishes = await _apiService.getDishes();
  setState(() => _dishes = dishes);
}
```

---

### 2. Thêm món ăn

**Sơ đồ:** "Thêm document mới vào Firestore"

**Code thực tế:**
```dart
void _showAddDishDialog() {
  // ...
  onPressed: () {
    // TODO: Implement add dish  ❌ CHỈ CÓ TODO!
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm món ăn')),  // ❌ Fake message
    );
  }
}
```

**Đúng phải là:** Gọi API MongoDB
```dart
// ✅ CORRECT
Future<void> _addDish(Map<String, dynamic> dishData) async {
  try {
    final token = await _getAuthToken();
    await _apiService.createDish(dishData, token: token);
    
    await _loadDishes(); // Reload list
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã thêm món ăn thành công!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
    );
  }
}
```

---

### 3. Sửa món ăn

**Sơ đồ:** "Cập nhật document trong Firestore"

**Code thực tế:**
```dart
void _showEditDishDialog(Map<String, dynamic> dish, int index) {
  // TODO: Implement edit dialog  ❌ CHỈ CÓ TODO!
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Chỉnh sửa ${dish['name']}')),  // ❌ Fake message
  );
}
```

**Đúng phải là:** Gọi API MongoDB
```dart
// ✅ CORRECT
Future<void> _updateDish(String dishId, Map<String, dynamic> updates) async {
  try {
    final token = await _getAuthToken();
    await _apiService.updateDish(dishId, updates, token: token);
    
    await _loadDishes(); // Reload list
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã cập nhật món ăn thành công!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
    );
  }
}
```

---

### 4. Xóa món ăn

**Sơ đồ:** "Xóa document trên Firestore"

**Code thực tế:**
```dart
void _showDeleteDishDialog(int index) {
  // ...
  onPressed: () {
    setState(() => _dishes.removeAt(index));  // ❌ CHỈ XÓA LOCAL!
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa món ăn')),  // ❌ Fake
    );
  }
}
```

**Đúng phải là:** Gọi API MongoDB
```dart
// ✅ CORRECT
Future<void> _deleteDish(String dishId) async {
  try {
    final token = await _getAuthToken();
    await _apiService.deleteDish(dishId, token: token);
    
    await _loadDishes(); // Reload list
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã xóa món ăn thành công!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
    );
  }
}
```

---

## 🎯 **Kết luận - TẤT CẢ ĐỀU SAI!**

| Chức năng | Sơ đồ | Code | Khớp? |
|-----------|-------|------|-------|
| Load dishes | ✅ Từ Firestore (nên là MongoDB) | ❌ Hardcoded | ❌ SAI |
| Thêm món | ✅ Thêm vào Firestore (nên là MongoDB) | ❌ TODO | ❌ SAI |
| Sửa món | ✅ Cập nhật Firestore (nên là MongoDB) | ❌ TODO | ❌ SAI |
| Xóa món | ✅ Xóa Firestore (nên là MongoDB) | ❌ Local only | ❌ SAI |

> [!WARNING]
> **AdminScreen hiện tại HOÀN TOÀN LÀ FAKE!**
> - Data hardcoded
> - CRUD operations chưa được implement
> - Thống kê là dữ liệu giả
> - Không có quyền admin check
> - Không kết nối database

---

## ✅ **Cần implement:**

### 1. Admin Permission Check
```dart
Future<bool> _isAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  // Check user role in MongoDB
  final userData = await _apiService.getUserByUid(user.uid);
  return userData['role'] == 'admin';
}
```

### 2. Load Dishes from MongoDB
```dart
Future<void> _loadDishes() async {
  setState(() => _isLoading = true);
  try {
    final dishes = await _apiService.getDishes(limit: 1000); // Get all for admin
    setState(() {
      _dishes = dishes;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    _showError('Không thể tải danh sách món: $e');
  }
}
```

### 3. Complete Add Dialog
```dart
Future<void> _handleAddDish() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    
    await _apiService.createDish({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'mealType': _selectedMealType,
      'ingredients': _ingredients,
      'price': _price,
      'status': 'active',
    }, token: token);
    
    await _loadDishes(); // Reload
    Navigator.pop(context);
    
    _showSuccess('Đã thêm món ăn thành công!');
  } catch (e) {
    _showError('Lỗi khi thêm món: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 4. Complete Edit Dialog
```dart
Future<void> _handleEditDish(String dishId) async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    
    await _apiService.updateDish(dishId, {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'mealType': _selectedMealType,
      // ... other fields
    }, token: token);
    
    await _loadDishes();
    Navigator.pop(context);
    
    _showSuccess('Đã cập nhật món ăn thành công!');
  } catch (e) {
    _showError('Lỗi khi cập nhật món: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 5. Complete Delete Function
```dart
Future<void> _handleDeleteDish(String dishId, String dishName) async {
  setState(() => _isLoading = true);
  
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    
    await _apiService.deleteDish(dishId, token: token);
    
    await _loadDishes();
    Navigator.pop(context);
    
    _showSuccess('Đã xóa "$dishName" thành công!');
  } catch (e) {
    Navigator.pop(context);
    _showError('Lỗi khi xóa món: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## 🗂️ **Backend Requirements:**

App cần các MongoDB API endpoints sau (đã có sẵn trong code):

- ✅ `GET /api/dishes` - Load danh sách món
- ✅ `POST /api/dishes` - Thêm món mới (cần token)
- ✅ `PUT /api/dishes/:id` - Cập nhật món (cần token)
- ✅ `DELETE /api/dishes/:id` - Xóa món (cần token)
- ⚠️ `GET /api/users/:uid` - Check role admin

**Backend cần verify:**
- Firebase Auth token
- User role = 'admin'
- Chỉ admin mới được CRUD dishes

---

## 🎨 **UI Improvements Needed:**

1. **Loading states** - CircularProgressIndicator khi load/save
2. **Error handling** - Hiển thị lỗi rõ ràng
3. **Empty state** - Khi chưa có món nào
4. **Form validation** - Đầy đủ validation rules
5. **Image picker** - Upload ảnh món ăn
6. **Rich form** - Thêm nhiều fields (ingredients, cookingTime, servings, v.v.)

---

## 📝 **Notes:**

**Sơ đồ nói "Firestore"** nhưng app dùng **MongoDB** - Đây là điểm khác biệt nhất!

Toàn bộ admin panel cần được **REBUILD HOÀN TOÀN** để:
1. Kết nối MongoDB qua API
2. Implement đầy đủ CRUD
3. Add admin permission check
4. Real-time statistics từ database
5. Better UX với loading/error states

**AdminScreen hiện tại = 🎨 UI Mockup, KHÔNG phải working code!** ❌
