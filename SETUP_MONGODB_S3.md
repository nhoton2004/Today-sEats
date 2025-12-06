# MongoDB + AWS S3 Setup Guide

## ✅ Đã tạo thành công:

### Backend Files:
- ✅ `config/mongodb.config.js` - MongoDB connection
- ✅ `config/aws.config.js` - AWS S3 configuration
- ✅ `models/Dish.model.js` - Dish schema
- ✅ `models/User.model.js` - User schema
- ✅ `services/s3.service.js` - S3 upload/download service
- ✅ `middleware/upload.middleware.js` - Multer configuration
- ✅ `middleware/auth.middleware.js` - Firebase token verification
- ✅ `controllers/dishes.controller.js` - Dish operations
- ✅ `controllers/users.controller.js` - User operations
- ✅ `routes/dishes.routes.js` - Dish API routes
- ✅ `routes/users.routes.js` - User API routes
- ✅ `server-mongodb.js` - New server with MongoDB
- ✅ `.env.example` - Environment variables template

### Flutter Files:
- ✅ `lib/core/services/api_service.dart` - HTTP API client
- ✅ `lib/core/services/upload_service.dart` - Image upload service

---

## 🚀 SETUP INSTRUCTIONS

### Bước 1: Cấu hình MongoDB

#### Option A: MongoDB Local (Development)
```bash
# Install MongoDB Community Edition
# Ubuntu/Debian:
sudo apt-get install mongodb

# Start MongoDB
sudo systemctl start mongodb
sudo systemctl enable mongodb
```

#### Option B: MongoDB Atlas (Cloud - Recommended)
1. Đăng ký tại: https://www.mongodb.com/cloud/atlas/register
2. Tạo FREE cluster
3. Tạo database user
4. Whitelist IP: `0.0.0.0/0` (allow all)
5. Copy connection string

### Bước 2: Cấu hình AWS S3

1. **Đăng nhập AWS Console**: https://console.aws.amazon.com
2. **Tạo S3 Bucket**:
   - Services → S3 → Create bucket
   - Bucket name: `todays-eats-images`
   - Region: `ap-southeast-1` (Singapore)
   - Uncheck "Block all public access"
   - Enable "Bucket Versioning"

3. **Tạo IAM User**:
   - Services → IAM → Users → Add user
   - Username: `todays-eats-s3-user`
   - Access type: Programmatic access
   - Permissions: Attach `AmazonS3FullAccess` policy
   - Save Access Key ID và Secret Access Key

4. **Configure Bucket Policy**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::todays-eats-images/*"
    }
  ]
}
```

### Bước 3: Setup Backend

```bash
cd backend

# Copy .env.example to .env
cp .env.example .env

# Edit .env với thông tin thực:
nano .env
```

**Điền vào .env:**
```env
PORT=5000
NODE_ENV=development

# MongoDB (chọn 1 trong 2)
# Local:
MONGODB_URI=mongodb://localhost:27017/todays_eats
# Atlas:
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/todays_eats

# AWS S3
AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
AWS_REGION=ap-southeast-1
AWS_S3_BUCKET=todays-eats-images

# JWT
JWT_SECRET=your-random-secret-key-here
```

### Bước 4: Start New Server

```bash
# Start với MongoDB
node server-mongodb.js

# Hoặc thêm vào package.json:
npm run dev:mongo
```

**Thêm vào package.json:**
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "dev:mongo": "nodemon server-mongodb.js"
  }
}
```

### Bước 5: Test API

```bash
# Health check
curl http://localhost:5000/api/health

# Get dishes
curl http://localhost:5000/api/dishes

# Get users
curl http://localhost:5000/api/users

# Get stats
curl http://localhost:5000/api/stats
```

### Bước 6: Update Flutter App

**pubspec.yaml:**
```yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.4
```

```bash
cd ..
flutter pub get
```

### Bước 7: Test Upload

**Test từ Flutter:**
```dart
final apiService = ApiService();

// Get dishes
final dishes = await apiService.getDishes();

// Upload image
final uploadService = UploadService();
final result = await uploadService.uploadImage(imageFile);

// Create dish with uploaded image
await apiService.createDish({
  'name': 'Phở Bò',
  'category': 'Món chính',
  'imageUrl': result['url'],
  'imageKey': result['key'],
});
```

---

## 🔄 Migration từ Firebase

### Script migrate data:

```bash
# Tạo file migrate.js
node migrate.js
```

**migrate.js:**
```javascript
const admin = require('firebase-admin');
const mongoose = require('mongoose');
const Dish = require('./models/Dish.model');
const User = require('./models/User.model');

// Connect
await mongoose.connect(process.env.MONGODB_URI);

// Migrate Dishes
const dishesSnapshot = await admin.firestore().collection('dishes').get();
for (const doc of dishesSnapshot.docs) {
  const data = doc.data();
  await Dish.create({
    ...data,
    _id: doc.id,
  });
}

// Migrate Users  
const usersSnapshot = await admin.firestore().collection('users').get();
for (const doc of usersSnapshot.docs) {
  const data = doc.data();
  await User.create({
    ...data,
    uid: doc.id,
  });
}

console.log('Migration complete!');
```

---

## 📊 API Endpoints

### Dishes
- `GET /api/dishes` - Get all dishes (với pagination, filter)
- `GET /api/dishes/:id` - Get single dish
- `POST /api/dishes` - Create dish
- `PUT /api/dishes/:id` - Update dish
- `DELETE /api/dishes/:id` - Delete dish
- `POST /api/dishes/upload/image` - Upload image

### Users
- `GET /api/users` - Get all users
- `GET /api/users/:uid` - Get user by UID
- `POST /api/users` - Create/update user
- `PUT /api/users/:uid` - Update user profile
- `POST /api/users/:uid/favorites` - Toggle favorite
- `DELETE /api/users/:uid` - Delete user

### Stats
- `GET /api/stats` - Get app statistics

### Health
- `GET /api/health` - Health check

---

## 🔒 Security Checklist

- [ ] Change JWT_SECRET in production
- [ ] Restrict S3 bucket access
- [ ] Enable Firebase Auth middleware
- [ ] Add rate limiting
- [ ] Enable HTTPS
- [ ] Validate all inputs
- [ ] Add request logging
- [ ] Set up monitoring

---

## 🎯 Next Steps

1. **Start MongoDB** (local hoặc Atlas)
2. **Configure AWS S3**
3. **Update .env**
4. **Run server**: `node server-mongodb.js`
5. **Test API** với Postman/curl
6. **Update Flutter app** để dùng API mới
7. **Migrate data** từ Firebase (optional)

---

## ❓ Troubleshooting

### MongoDB connection failed
```bash
# Check MongoDB status
sudo systemctl status mongodb

# View logs
sudo journalctl -u mongodb
```

### S3 upload failed
- Check AWS credentials
- Check bucket permissions
- Check bucket policy
- Verify region

### API errors
```bash
# View server logs
tail -f server.log

# Test endpoints
curl -v http://localhost:5000/api/health
```

---

Đã setup xong! Bây giờ chạy thử nhé:

```bash
cd backend
node server-mongodb.js
```
