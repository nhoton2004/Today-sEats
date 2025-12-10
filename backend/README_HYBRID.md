# Backend Hybrid Architecture - Today's Eats

## 🏗️ Kiến trúc

Backend sử dụng kiến trúc **Hybrid Database**:

- **Firebase Firestore**: Lưu trữ thông tin người dùng (users)
  - Đăng ký/Đăng nhập
  - Hồ sơ người dùng
  - Món ăn yêu thích
  
- **MongoDB Atlas**: Lưu trữ dữ liệu món ăn (dishes)
  - Danh sách món ăn
  - Thông tin chi tiết món ăn
  - Đánh giá và bình luận

- **AWS S3**: Lưu trữ hình ảnh món ăn

## 🚀 Khởi động Server

### Cách 1: Sử dụng npm
```bash
cd backend
npm start          # Khởi động hybrid server (khuyến nghị)
npm run dev        # Development mode với nodemon
npm run firebase   # Chỉ Firebase (không MongoDB)
npm run mongo      # Chỉ MongoDB (không Firebase)
```

### Cách 2: Sử dụng node trực tiếp
```bash
cd backend
node server-hybrid.js      # Hybrid server
node server.js             # Firebase only
node server-mongodb.js     # MongoDB only
```

## 📋 Cấu hình

### 1. MongoDB Atlas Setup
1. Truy cập https://cloud.mongodb.com
2. Vào **Network Access** → **Add IP Address**
3. Thêm IP: `171.250.163.37` hoặc `0.0.0.0/0` (allow all)
4. Confirm

### 2. Firebase Firestore Setup
1. Truy cập https://console.firebase.google.com
2. Chọn project "today-s-eats"
3. Vào **Firestore Database** → **Create database**
4. Chọn **Start in test mode**
5. Location: **asia-southeast1 (Singapore)**
6. Click **Enable**

### 3. Environment Variables (.env)
```env
# Server
PORT=5000
NODE_ENV=development

# MongoDB Atlas
MONGODB_URI=mongodb+srv://admin_backend_todayseats:7powIkXvbBVl7fNJ@cluster0.t4exz8c.mongodb.net/todays_eats?retryWrites=true&w=majority&appName=Cluster0

# Firebase
FIREBASE_PROJECT_ID=today-s-eats

# AWS S3
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=ap-southeast-1
AWS_S3_BUCKET=todays-eats-images

# JWT
JWT_SECRET=your-jwt-secret

# CORS
CORS_ORIGIN=http://localhost:3000
```

## 📡 API Endpoints

### Users (Firebase Firestore)
- `GET    /api/users`           - Lấy danh sách users
- `GET    /api/users/:uid`      - Lấy thông tin user
- `POST   /api/users`           - Tạo/cập nhật user
- `PUT    /api/users/:uid`      - Cập nhật hồ sơ user
- `POST   /api/users/:uid/favorites` - Toggle món ăn yêu thích
- `DELETE /api/users/:uid`      - Xóa user

### Dishes (MongoDB)
- `GET    /api/dishes`          - Lấy danh sách món ăn
- `GET    /api/dishes/:id`      - Lấy chi tiết món ăn
- `POST   /api/dishes`          - Tạo món ăn mới
- `PUT    /api/dishes/:id`      - Cập nhật món ăn
- `DELETE /api/dishes/:id`      - Xóa món ăn

### Other
- `GET    /api/stats`           - Thống kê tổng quan
- `GET    /api/health`          - Health check
- `GET    /`                    - Admin Dashboard

## 🔧 Troubleshooting

### MongoDB không kết nối được
```bash
# Kiểm tra IP đã được whitelist chưa
curl ifconfig.me
# Kết quả: 171.250.163.37

# Thêm IP này vào MongoDB Atlas Network Access
```

### Firebase Firestore lỗi NOT_FOUND
- Đảm bảo đã tạo Firestore Database trong Firebase Console
- Kiểm tra file service account JSON có đúng không
- File cần: `today-s-eats-firebase-adminsdk-fbsvc-0195542b40.json`

### Port 5000 đã được sử dụng
```bash
# Tìm process đang dùng port 5000
lsof -ti:5000

# Kill process
kill $(lsof -ti:5000)
```

## 📊 Admin Dashboard

Truy cập: **http://localhost:5000**

Dashboard cho phép:
- Quản lý món ăn (từ MongoDB)
- Quản lý người dùng (từ Firebase Firestore)
- Xem thống kê

## 🔐 Security Notes

⚠️ **Quan trọng:**
- File `.env` đã được thêm vào `.gitignore`
- Không commit các file service account JSON
- Sử dụng test mode cho Firestore trong development
- Chuyển sang production mode khi deploy

## 📝 Seed Data

Khởi tạo dữ liệu mẫu cho MongoDB:
```bash
npm run seed
```

Dữ liệu mẫu bao gồm:
- 12 món ăn Việt Nam phổ biến
- 2 users mẫu (admin và user)

## 🎯 Flutter App Integration

App Flutter đã được cấu hình để:
1. Đăng ký/Đăng nhập → Tự động lưu vào Firebase Firestore
2. Lấy danh sách món ăn → API từ MongoDB
3. Upload ảnh → AWS S3

Không cần thay đổi gì thêm ở app Flutter!
