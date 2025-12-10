# Hướng dẫn tích hợp MongoDB và AWS S3

## 📦 Kiến trúc hệ thống

```
┌─────────────────┐
│  Flutter App    │
└────────┬────────┘
         │
         ├──── Firebase Auth (Authentication)
         │
         ├──── Backend API (Express.js)
         │     ├── MongoDB (Database)
         │     └── AWS S3 (File Storage)
         │
         └──── Firebase (Optional fallback)
```

---

## 🗄️ PHẦN 1: Tích hợp MongoDB

### 1.1. Cài đặt dependencies

```bash
cd backend
npm install mongodb mongoose dotenv
```

### 1.2. Tạo MongoDB Connection Service

File: `backend/services/mongodb.service.js`

### 1.3. Tạo Models

- `backend/models/Dish.model.js`
- `backend/models/User.model.js`
- `backend/models/Order.model.js`

### 1.4. Cập nhật .env

```env
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/todays_eats
# hoặc MongoDB Atlas
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/todays_eats

# Firebase (giữ lại cho Auth)
FIREBASE_PROJECT_ID=your-project-id

# AWS S3
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=ap-southeast-1
AWS_S3_BUCKET=todays-eats-images
```

---

## ☁️ PHẦN 2: Tích hợp AWS S3

### 2.1. Cài đặt AWS SDK

```bash
cd backend
npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner multer multer-s3
```

### 2.2. Tạo S3 Service

File: `backend/services/s3.service.js`

### 2.3. API Endpoints mới

- `POST /api/upload/image` - Upload ảnh lên S3
- `DELETE /api/upload/image/:key` - Xóa ảnh từ S3
- `GET /api/upload/presigned-url` - Lấy URL tạm thời

---

## 🚀 PHẦN 3: Cấu trúc Backend mới

### 3.1. Folder Structure

```
backend/
├── config/
│   ├── mongodb.config.js
│   └── aws.config.js
├── models/
│   ├── Dish.model.js
│   ├── User.model.js
│   └── Order.model.js
├── services/
│   ├── mongodb.service.js
│   ├── s3.service.js
│   └── firebase.service.js (auth only)
├── routes/
│   ├── dishes.routes.js
│   ├── users.routes.js
│   ├── upload.routes.js
│   └── orders.routes.js
├── controllers/
│   ├── dishes.controller.js
│   ├── users.controller.js
│   └── upload.controller.js
├── middleware/
│   ├── auth.middleware.js
│   └── upload.middleware.js
├── .env
├── server.js
└── package.json
```

---

## 📱 PHẦN 4: Cập nhật Flutter App

### 4.1. Cài đặt packages

```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  dio: ^5.4.0  # Better for file uploads
  image_picker: ^1.0.4
```

### 4.2. Tạo API Service mới

File: `lib/core/services/api_service.dart`

### 4.3. Tạo Upload Service

File: `lib/core/services/upload_service.dart`

---

## 🔐 PHẦN 5: Authentication Strategy

### Hybrid Approach (Recommended)

1. **Firebase Auth** - Authentication (login, register, Google Sign In)
2. **MongoDB** - User profiles, preferences, data
3. **Backend API** - Validate Firebase tokens

```dart
// Flutter: Login flow
1. Firebase Auth login → Get ID Token
2. Send token to backend → Backend validates with Firebase Admin
3. Backend checks/creates user in MongoDB
4. Return JWT + user data to Flutter
5. Flutter stores JWT for API calls
```

---

## 💾 PHẦN 6: Migration Strategy

### Option 1: Dual Database (Transition Period)

- Keep Firebase for existing users
- New features use MongoDB
- Gradually migrate data

### Option 2: Full Migration

1. Export data from Firestore
2. Transform and import to MongoDB
3. Update all APIs
4. Deploy new backend
5. Release app update

### Option 3: Hybrid (Best)

- **Firebase**: Authentication only
- **MongoDB**: All application data
- **AWS S3**: All media files

---

## 📊 So sánh Chi phí

### Firebase (Current)

| Service | Free Tier | After Free |
|---------|-----------|------------|
| Auth | Unlimited | Free |
| Firestore | 1GB, 50K reads/day | $0.18/GB |
| Storage | 5GB | $0.026/GB |

### MongoDB + AWS S3

| Service | Free Tier | After Free |
|---------|-----------|------------|
| MongoDB Atlas | 512MB | $9/month (2GB) |
| AWS S3 | 5GB, 12 months | $0.023/GB |
| AWS Data Transfer | 100GB/month | $0.09/GB |

**Ưu điểm MongoDB + S3:**
- Chi phí thấp hơn khi scale
- Flexible queries
- Better for complex data
- Industry standard

---

## 🛠️ Implementation Order

### Phase 1: Setup Infrastructure (1-2 days)
1. ✅ Setup MongoDB (local or Atlas)
2. ✅ Setup AWS S3 bucket
3. ✅ Configure backend services
4. ✅ Create models and schemas

### Phase 2: Backend Migration (2-3 days)
1. ✅ Create new API routes
2. ✅ Implement MongoDB operations
3. ✅ Implement S3 upload/download
4. ✅ Add authentication middleware
5. ✅ Test all endpoints

### Phase 3: Flutter Integration (2-3 days)
1. ✅ Create API service layer
2. ✅ Update providers to use new APIs
3. ✅ Implement image upload
4. ✅ Test all features

### Phase 4: Testing & Deployment (2 days)
1. ✅ Integration testing
2. ✅ Performance testing
3. ✅ Deploy backend
4. ✅ Deploy Flutter app

**Total: 7-10 days**

---

## 🎯 Quick Start

Bạn muốn tôi:

### Option A: Setup toàn bộ (Full implementation)
- Tạo tất cả files backend mới
- MongoDB models, services, routes
- AWS S3 integration
- Update Flutter app

### Option B: Setup từng phần
1. **MongoDB first** - Database migration
2. **AWS S3 second** - File storage
3. **Flutter last** - Connect to new backend

### Option C: Hybrid approach (Khuyến nghị)
- Keep Firebase Auth
- Add MongoDB for data
- Add AWS S3 for images
- Parallel run with current system

Bạn muốn bắt đầu với option nào? Tôi sẽ tạo code cụ thể cho phần đó! 🚀

---

## 📚 Resources

- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- [AWS S3 Console](https://console.aws.amazon.com/s3)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Express.js Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)
