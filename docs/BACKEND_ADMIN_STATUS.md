# Backend Admin Support - Status Report ✅

**Ngày kiểm tra:** 11/12/2025  
**Trạng thái tổng thể:** ✅ **ĐÃ HOÀN THÀNH**

---

## 🎯 Tóm tắt

Backend **ĐÃ CÓ SẴN** hầu hết components cần thiết cho Admin Panel. Đã thực hiện **1 FIX QUAN TRỌNG** để hoạt động đúng.

---

## ✅ Đã có sẵn trong backend

### 1. User Model với Role
**File:** [`backend/models/User.model.js`](file:///home/nho/Documents/TodaysEats/backend/models/User.model.js#L23-L27)

```javascript
role: {
  type: String,
  enum: ['user', 'admin', 'moderator'],
  default: 'user',  // ✅ Default = 'user'
}
```

✅ **Field `role` ĐÃ CÓ trong User schema!**
- Enum: `'user'` | `'admin'` | `'moderator'`
- Default: `'user'`

---

### 2. Authentication Middleware
**File:** [`backend/middleware/auth.middleware.js`](file:///home/nho/Documents/TodaysEats/backend/middleware/auth.middleware.js)

**Có 2 middlewares:**

#### a) `verifyToken` - Verify Firebase token ✅
```javascript
const verifyToken = async (req, res, next) => {
  // Verify Firebase ID token
  const decodedToken = await admin.auth().verifyIdToken(token);
  req.user = {
    uid: decodedToken.uid,
    email: decodedToken.email,
  };
  next();
};
```

#### b) `isAdmin` - Check admin role ✅ **ĐÃ SỬA**
```javascript
const isAdmin = async (req, res, next) => {
  // ✅ Fetch user from MongoDB to check role
  const user = await User.findOne({ uid: req.user.uid });
  
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  
  if (user.role !== 'admin') {
    return res.status(403).json({
      error: 'Forbidden',
      message: 'Admin access required',
    });
  }
  
  next();
};
```

---

### 3. Dishes Routes với Admin Protection
**File:** [`backend/routes/dishes.routes.js`](file:///home/nho/Documents/TodaysEats/backend/routes/dishes.routes.js)

```javascript
// Public routes ✅
router.get('/', dishesController.getAllDishes);
router.get('/:id', dishesController.getDishById);

// Protected admin routes ✅ (ĐÃ THÊM isAdmin middleware)
router.post('/', verifyToken, isAdmin, dishesController.createDish);
router.put('/:id', verifyToken, isAdmin, dishesController.updateDish);
router.delete('/:id', verifyToken, isAdmin, dishesController.deleteDish);

// Upload image (admin only) ✅
router.post('/upload/image', verifyToken, isAdmin, upload.single('image'), ...);
```

---

### 4. Users Controller
**File:** [`backend/controllers/users.controller.js`](file:///home/nho/Documents/TodaysEats/backend/controllers/users.controller.js)

**Có đầy đủ endpoints:**

✅ `getUserByUid()` - Get user với role field  
✅ `createOrUpdateUser()` - Tạo/update user  
✅ `updateUserProfile()` - Update profile (PUT /users/:uid)  
✅ `toggleFavorite()` - Toggle favorites  
✅ `getUserStats()` - Get statistics

---

## 🔧 Thay đổi đã thực hiện

### **FIX #1: isAdmin Middleware** ⚠️ **CRITICAL FIX**

**VẤN ĐỀ:**
- Code cũ check `req.user.role === 'admin'`
- Nhưng `req.user.role` từ Firebase token **KHÔNG TỒN TẠI**
- Firebase Auth tokens không có custom claims `role`

**GIẢI PHÁP:**
- Fetch user từ MongoDB để check `user.role`
- Trả về 403 nếu role !== 'admin'

**Code cũ (SAI):**
```javascript
const isAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {  // ❌ role undefined!
    next();
  } else {
    return res.status(403).json({ error: 'Forbidden' });
  }
};
```

**Code mới (ĐÚNG):**
```javascript
const isAdmin = async (req, res, next) => {
  // ✅ Fetch from MongoDB
  const user = await User.findOne({ uid: req.user.uid });
  
  if (user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  next();
};
```

---

### **FIX #2: Protected Routes**

**Thêm `isAdmin` middleware vào dishes routes:**

```diff
// Protected admin routes
- router.post('/', verifyToken, dishesController.createDish);
+ router.post('/', verifyToken, isAdmin, dishesController.createDish);

- router.put('/:id', verifyToken, dishesController.updateDish);
+ router.put('/:id', verifyToken, isAdmin, dishesController.updateDish);

- router.delete('/:id', verifyToken, dishesController.deleteDish);
+ router.delete('/:id', verifyToken, isAdmin, dishesController.deleteDish);
```

**Bây giờ:**
- ✅ Chỉ admin mới CREATE/UPDATE/DELETE dishes
- ✅ User thường chỉ xem được (GET)

---

## 🔐 Authentication Flow

### **Admin Operations Flow**

```
1. Flutter app call API with Firebase token
   Headers: { Authorization: Bearer <firebase_token> }
   ↓
2. Backend: verifyToken middleware
   - Verify Firebase token
   - Extract uid and email
   - Set req.user = { uid, email }
   ↓
3. Backend: isAdmin middleware
   - Query MongoDB: User.findOne({ uid })
   - Check user.role === 'admin'?
   ├─ Yes → next() ✅
   └─ No → 403 Forbidden ❌
   ↓
4. Backend: Execute controller (createDish, updateDish, deleteDish)
   ↓
5. Response to client
```

---

## 📊 Endpoint Summary

### Dishes API

| Endpoint | Method | Auth | Admin | Purpose |
|----------|--------|------|-------|---------|
| `/api/dishes` | GET | ❌ No | ❌ No | List all dishes (public) |
| `/api/dishes/:id` | GET | ❌ No | ❌ No | Get dish detail (public) |
| `/api/dishes` | POST | ✅ Yes | ✅ Yes | Create dish (admin only) |
| `/api/dishes/:id` | PUT | ✅ Yes | ✅ Yes | Update dish (admin only) |
| `/api/dishes/:id` | DELETE | ✅ Yes | ✅ Yes | Delete dish (admin only) |

### Users API

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/users/:uid` | GET | ❌ No | Get user by UID (includes role) |
| `/api/users/:uid` | PUT | ✅ Yes | Update user profile |
| `/api/users/:uid/stats` | GET | ❌ No | Get user statistics |
| `/api/users/:uid/favorites` | POST | ✅ Yes | Toggle favorite |

---

## 🧪 Testing Admin Access

### **Tạo Admin User**

**Option 1: Trực tiếp trong MongoDB**
```javascript
// MongoDB Shell hoặc MongoDB Compass
db.users.updateOne(
  { email: "admin@example.com" },
  { $set: { role: "admin" } }
);
```

**Option 2: Via API (cần update createOrUpdateUser controller)**
```javascript
// POST /api/users
{
  "uid": "firebase_uid",
  "email": "admin@example.com",
  "displayName": "Admin User",
  "role": "admin"  // ← Thêm field này
}
```

---

### **Test Admin Endpoints**

```bash
# 1. Get Firebase token (đăng nhập trong app)
TOKEN="<your_firebase_token>"

# 2. Test CREATE dish (admin only)
curl -X POST http://localhost:5000/api/dishes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Dish",
    "description": "Admin created dish",
    "category": "main",
    "mealType": "lunch",
    "status": "active"
  }'

# Expected:
# - Admin: 201 Created ✅
# - Non-admin: 403 Forbidden ❌

# 3. Test UPDATE dish (admin only)
curl -X PUT http://localhost:5000/api/dishes/DISH_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name"
  }'

# 4. Test DELETE dish (admin only)
curl -X DELETE http://localhost:5000/api/dishes/DISH_ID \
  -H "Authorization: Bearer $TOKEN"
```

---

## ✅ Verification Checklist

- [x] **User Model** có field `role` với enum `['user', 'admin', 'moderator']`
- [x] **verifyToken** middleware verify Firebase token
- [x] **isAdmin** middleware fetch user từ MongoDB và check role
- [x] **Dishes routes** protected với `verifyToken + isAdmin`
- [x] **getUserByUid** API trả về user với role field
- [x] **updateUserProfile** API để update user (cho EditProfile feature)

---

## 🚀 Next Steps

### Backend đã sẵn sàng! Cần làm:

1. **Tạo admin user trong database**
   ```javascript
   db.users.updateOne(
     { email: "your_email@example.com" },
     { $set: { role: "admin" } }
   );
   ```

2. **Test admin login trong app**
   - Đăng nhập với admin account
   - Vào Admin tab
   - Kiểm tra có quyền access không

3. **Test CRUD operations**
   - Thêm món mới
   - Sửa món
   - Xóa món

---

## 📝 Notes

**Backend changes:**
- ✅ Fixed `isAdmin` middleware (MongoDB lookup instead of Firebase token)
- ✅ Added `isAdmin` to dishes routes (CREATE/UPDATE/DELETE)
- ✅ All other necessary code was already present

**App restart:**
- Backend server đang chạy (`npm start`)
- **KHÔNG CẦN** restart vì đã hot reload (nodemon)
- Changes có hiệu lực ngay lập tức

**Admin Panel trong app:**
- ✅ Flutter code đã hoàn chỉnh
- ✅ Backend API đã sẵn sàng
- ⚠️ **CHỈ CẦN** tạo admin user trong database

---

## 🎯 Summary

| Component | Status | Notes |
|-----------|--------|-------|
| User Model (role field) | ✅ Ready | Đã có sẵn |
| verifyToken middleware | ✅ Ready | Đã có sẵn |
| isAdmin middleware | ✅ Fixed | **ĐÃ SỬA** - fetch từ MongoDB |
| Protected routes | ✅ Updated | **ĐÃ THÊM** isAdmin middleware |
| Users API | ✅ Ready | Đã có sẵn |
| Dishes API | ✅ Ready | Đã có sẵn |

**Backend hoàn toàn sẵn sàng cho Admin Panel!** 🚀
