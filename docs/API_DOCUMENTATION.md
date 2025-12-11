# Tài Liệu API - TodaysEats

## Tổng Quan

**Base URL:** `http://localhost:5000/api`  
**Phiên bản:** 1.0  
**Xác thực:** Firebase Authentication (JWT Token)

---

## 🔐 Xác Thực (Authentication)

### Firebase ID Token

Hầu hết các API yêu cầu xác thực bằng Firebase ID Token.

**Header:**
```
Authorization: Bearer <firebase_id_token>
```

**Cách lấy token (Flutter):**
```dart
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken();
```

**Phản hồi lỗi xác thực:**

```json
{
  "error": "Unauthorized",
  "message": "No token provided"
}
```

---

## 📋 Endpoints - Món Ăn (Dishes)

### 1. Lấy Danh Sách Món Ăn

**GET** `/dishes`

**Mô tả:** Lấy danh sách món ăn với bộ lọc tùy chọn

**Query Parameters:**

| Tham số | Loại | Bắt buộc | Mô tả | Ví dụ |
|---------|------|----------|-------|-------|
| category | String | Không | Lọc theo danh mục | `Món chính` |
| mealType | String | Không | Lọc theo bữa ăn | `breakfast`, `lunch`, `dinner` |
| status | String | Không | Trạng thái món ăn | `active`, `inactive` |
| search | String | Không | Tìm kiếm theo tên | `Phở` |
| page | Number | Không | Trang (mặc định: 1) | `1` |
| limit | Number | Không | Số món/trang (mặc định: 20) | `20` |

**Response thành công (200):**
```json
{
  "dishes": [
    {
      "_id": "675957234f1e4a5d6c8b9012",
      "name": "Phở Bò",
      "category": "Món chính",
      "description": "Món phở truyền thống với nước dùng thơm ngon",
      "mealType": "breakfast",
      "tags": ["việt nam", "phở", "sáng"],
      "status": "active",
      "preparationTime": 30,
      "cookingTime": 45,
      "servings": 1,
      "createdBy": "uYklmQ93zrToOuwWfyAKlsDmov32",
      "createdAt": "2024-12-11T07:00:00.000Z",
      "updatedAt": "2024-12-11T07:00:00.000Z"
    }
  ],
  "total": 51,
  "page": 1,
  "pages": 3
}
```

**Ví dụ request:**
```bash
# Lấy tất cả món breakfast
curl http://localhost:5000/api/dishes?mealType=breakfast

# Lấy món chính, active
curl http://localhost:5000/api/dishes?category=Món%20chính&status=active

# Tìm kiếm món có tên "Phở"
curl http://localhost:5000/api/dishes?search=Phở
```

---

### 2. Lấy Chi Tiết Món Ăn

**GET** `/dishes/:id`

**Mô tả:** Lấy thông tin chi tiết của một món ăn

**Path Parameters:**

| Tham số | Loại | Mô tả |
|---------|------|-------|
| id | String | MongoDB ObjectID của món ăn |

**Response thành công (200):**
```json
{
  "_id": "675957234f1e4a5d6c8b9012",
  "name": "Phở Bò",
  "category": "Món chính",
  "description": "Món phở truyền thống với nước dùng thơm ngon",
  "mealType": "breakfast",
  "tags": ["việt nam", "phở", "sáng"],
  "ingredients": ["Bánh phở", "Thịt bò", "Hành", "Ngò"],
  "preparationTime": 30,
  "cookingTime": 45,
  "servings": 1,
  "difficulty": "medium",
  "rating": 4.5,
  "ratingCount": 120,
  "imageUrl": "https://todays-eats-images.s3.ap-southeast-1.amazonaws.com/...",
  "imageKey": "dishes/abc123.jpg",
  "status": "active",
  "createdBy": "uYklmQ93zrToOuwWfyAKlsDmov32",
  "createdAt": "2024-12-11T07:00:000Z",
  "updatedAt": "2024-12-11T07:00:00.000Z"
}
```

**Response lỗi (404):**
```json
{
  "error": "Dish not found"
}
```

---

### 3. Tạo Món Ăn Mới

**POST** `/dishes`

**Xác thực:** ✅ Bắt buộc (Firebase Token)

**Mô tả:** Tạo món ăn mới

**Request Body:**
```json
{
  "name": "Bún Chả",
  "category": "Món chính",
  "description": "Bún chả Hà Nội với thịt nướng thơm",
  "mealType": "lunch",
  "tags": ["việt nam", "bún", "nướng"],
  "ingredients": ["Bún", "Thịt nướng", "Nước mắm", "Rau sống"],
  "preparationTime": 30,
  "cookingTime": 20,
  "servings": 1,
  "difficulty": "medium",
  "createdBy": "uYklmQ93zrToOuwWfyAKlsDmov32"
}
```

**Response thành công (201):**
```json
{
  "_id": "675957234f1e4a5d6c8b9999",
  "name": "Bún Chả",
  ...
  "createdAt": "2024-12-11T08:00:00.000Z"
}
```

**Response lỗi (401):**
```json
{
  "error": "Unauthorized",
  "message": "Authentication required to create dishes"
}
```

---

### 4. Cập Nhật Món Ăn

**PUT** `/dishes/:id`

**Xác thực:** ✅ Bắt buộc (Firebase Token)

**Phân quyền:** Chỉ người tạo hoặc admin

**Mô tả:** Cập nhật thông tin món ăn

**Request Body:**
```json
{
  "name": "Phở Bò Đặc Biệt",
  "description": "Phở bò với nhiều topping hơn"
}
```

**Response thành công (200):**
```json
{
  "_id": "675957234f1e4a5d6c8b9012",
  "name": "Phở Bò Đặc Biệt",
  "description": "Phở bò với nhiều topping hơn",
  "updatedAt": "2024-12-11T09:00:00.000Z"
}
```

**Response lỗi (403):**
```json
{
  "error": "Forbidden",
  "message": "You can only update your own dishes"
}
```

---

### 5. Xóa Món Ăn

**DELETE** `/dishes/:id`

**Xác thực:** ✅ Bắt buộc (Firebase Token)

**Phân quyền:** Chỉ người tạo hoặc admin

**Mô tả:** Xóa món ăn (bao gồm cả ảnh trên S3)

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Dish deleted successfully"
}
```

**Response lỗi (403):**
```json
{
  "error": "Forbidden",
  "message": "You can only delete your own dishes"
}
```

---

## 👥 Endpoints - Người Dùng (Users)

### 1. Tạo/Cập Nhật Người Dùng

**POST** `/users`

**Mô tả:** Tạo mới hoặc cập nhật thông tin người dùng

**Request Body:**
```json
{
  "uid": "uYklmQ93zrToOuwWfyAKlsDmov32",
  "email": "user@example.com",
  "displayName": "Nguyễn Văn A",
  "photoURL": "https://...",
  "role": "user"
}
```

**Response thành công (200):**
```json
{
  "_id": "675957234f1e4a5d6c8b8888",
  "uid": "uYklmQ93zrToOuwWfyAKlsDmov32",
  "email": "user@example.com",
  "displayName": "Nguyễn Văn A",
  "role": "user",
  "favorites": [],
  "isActive": true,
  "createdAt": "2024-12-11T07:00:00.000Z"
}
```

---

### 2. Lấy Thông Tin Người Dùng

**GET** `/users/:uid`

**Mô tả:** Lấy thông tin người dùng theo Firebase UID

**Response thành công (200):**
```json
{
  "_id": "675957234f1e4a5d6c8b8888",
  "uid": "uYklmQ93zrToOuwWfyAKlsDmov32",
  "email": "user@example.com",
  "displayName": "Nguyễn Văn A",
  "role": "user",
  "favorites": ["675957234f1e4a5d6c8b9012"],
  "stats": {
    "dishesCreated": 5,
    "ratingsGiven": 12
  },
  "isActive": true
}
```

---

## 🏥 Health Check

**GET** `/health`

**Mô tả:** Kiểm tra trạng thái hệ thống

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-11T10:00:00.000Z",
  "database": "connected",
  "firebase": "enabled",
  "s3": "configured"
}
```

---

## ❌ Mã Lỗi (Error Codes)

| HTTP Code | Error | Ý nghĩa |
|-----------|-------|---------|
| 200 | OK | Thành công |
| 201 | Created | Tạo thành công |
| 400 | Bad Request | Dữ liệu không hợp lệ |
| 401 | Unauthorized | Chưa xác thực |
| 403 | Forbidden | Không có quyền |
| 404 | Not Found | Không tìm thấy |
| 500 | Internal Server Error | Lỗi server |

**Format lỗi chung:**
```json
{
  "error": "Error Type",
  "message": "Chi tiết lỗi"
}
```

---

## 📝 Ghi Chú

### Pagination

Tất cả API danh sách đều hỗ trợ phân trang:
- `page`: Trang hiện tại (mặc định: 1)
- `limit`: Số item/trang (mặc định: 20, max: 100)

### Filtering

API `/dishes` hỗ trợ lọc theo:
- `category`: Danh mục món ăn
- `mealType`: Bữa ăn (breakfast, lunch, dinner, snack)
- `status`: Trạng thái (active, inactive)
- `search`: Tìm kiếm text (name, description)

### Tags

Tags được sử dụng để lọc theo ẩm thực:
- `việt nam`: Món Việt
- `châu á`: Món Châu Á
- `âu mỹ`: Món Âu Mỹ

---

**Phiên bản:** 1.0  
**Cập nhật:** 11/12/2024
