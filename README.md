# 🍽️ Today's Eats

> Ứng dụng gợi ý món ăn hàng ngày với AI - Giải pháp hoàn hảo cho bữa ăn của bạn!

[![Flutter](https://img.shields.io/badge/Flutter-3.5.0-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![Node.js](https://img.shields.io/badge/Node.js-20+-339933?logo=node.js)](https://nodejs.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Giới Thiệu

**Today's Eats** là ứng dụng di động giúp người dùng khám phá và quản lý món ăn hàng ngày một cách dễ dàng. Với giao diện thân thiện và tính năng đa dạng, ứng dụng mang đến trải nghiệm tuyệt vời cho những ai đam mê ẩm thực.

### ✨ Tính Năng Chính

#### 👤 Xác Thực & Quản Lý Người Dùng
- ✅ Đăng ký/Đăng nhập bằng email & mật khẩu
- ✅ Đăng nhập nhanh với Google Sign In
- ✅ Quên mật khẩu (gửi email reset)
- ✅ Quản lý hồ sơ người dùng
- ✅ Đăng xuất an toàn

#### 🍽️ Khám Phá Món Ăn
- ✅ Lưới hiển thị món ăn đẹp mắt
- ✅ Thông tin chi tiết món ăn
- ✅ Đánh giá và xếp hạng
- ✅ Danh mục món ăn phong phú

#### ⭐ Yêu Thích & Lưu Trữ
- ✅ Đánh dấu món ăn yêu thích
- ✅ Danh sách favorites cá nhân
- ✅ Đồng bộ trên nhiều thiết bị

#### 👨‍💼 Admin Dashboard (Web)
- ✅ Quản lý món ăn (CRUD đầy đủ)
- ✅ Xem thống kê người dùng
- ✅ Dashboard phân tích real-time
- ✅ Giao diện responsive Material Design 3

#### 🎨 Giao Diện
- ✅ Material Design 3
- ✅ Splash screen với animation
- ✅ Onboarding 3 trang
- ✅ Dark mode support (coming soon)
- ✅ Responsive trên mọi kích thước màn hình

## 🏗️ Kiến Trúc Dự Án

```
TodaysEats/
├── lib/                          # Flutter Frontend
│   ├── main.dart                # Entry point
│   ├── app.dart                 # App config & routes
│   ├── firebase_options.dart    # Firebase configuration
│   ├── core/
│   │   ├── constants/           # App constants
│   │   ├── models/              # Data models
│   │   └── services/
│   │       └── auth_service.dart # Firebase Auth service
│   └── features/
│       ├── splash/              # Splash screen
│       ├── onboarding/          # Onboarding flow
│       ├── auth/                # Login/Register/Forgot Password
│       ├── main/                # Main navigation
│       ├── home/                # Home with dishes
│       ├── favorites/           # Favorite dishes
│       ├── profile/             # User profile
│       └── admin/               # Admin features
│
├── backend/                     # Express.js Backend
│   ├── server.js               # API server
│   ├── public/
│   │   └── index.html          # Admin dashboard
│   ├── .env                    # Environment config
│   └── package.json            # Node dependencies
│
├── android/                    # Android native
├── ios/                        # iOS native
└── docs/                       # Documentation
```

## 🚀 Bắt Đầu Nhanh

### Yêu Cầu Hệ Thống

- **Flutter SDK**: 3.5.0 trở lên
- **Node.js**: 20+ (cho backend)
- **Android Studio** hoặc **Xcode** (tùy platform)
- **Firebase Project** đã setup

### 1️⃣ Cài Đặt Frontend (Flutter)

```bash
# Clone repository
git clone https://github.com/nhoton2004/Today-sEats.git
cd TodaysEats

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

### 2️⃣ Cài Đặt Backend (Express.js)

```bash
# Di chuyển vào thư mục backend
cd backend

# Cài đặt packages
npm install

# Khởi động server
npm start
```

Server sẽ chạy tại: `http://localhost:5000`

### 3️⃣ Truy Cập Admin Dashboard

Mở trình duyệt và truy cập:
```
http://localhost:5000
```

## 📚 Tài Liệu Chi Tiết

| Tài Liệu | Mô Tả | Thời Gian Đọc |
|----------|-------|---------------|
| [QUICKSTART.md](QUICKSTART.md) | Hướng dẫn khởi động nhanh | 2 phút |
| [SETUP_SUMMARY.md](SETUP_SUMMARY.md) | Hướng dẫn setup đầy đủ | 10 phút |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | Trạng thái dự án | 8 phút |
| [DEPLOYMENT_COMPLETE.md](DEPLOYMENT_COMPLETE.md) | Hướng dẫn deployment | 5 phút |
| [backend/README.md](backend/README.md) | API documentation | 8 phút |
| [backend/ADMIN_DASHBOARD_GUIDE.md](backend/ADMIN_DASHBOARD_GUIDE.md) | Hướng dẫn admin dashboard | 10 phút |

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.5.0
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **UI**: Material Design 3

### Backend
- **Runtime**: Node.js 20+
- **Framework**: Express.js 5.x
- **Database**: Firestore (Firebase Admin SDK)
- **Authentication**: Firebase Admin
- **CORS**: Enabled

### DevOps & Tools
- **Version Control**: Git
- **CI/CD**: GitHub Actions (coming soon)
- **Hosting**: Firebase Hosting (planned)

## 📊 Trạng Thái Dự Án

### ✅ Đã Hoàn Thành
- Frontend Flutter app với đầy đủ UI/UX
- Backend API với Express.js
- Admin dashboard responsive
- Firebase Authentication integration
- CRUD operations cho dishes
- User management
- Real-time statistics

### 🔄 Đang Phát Triển
- Google Sign In (cần cấu hình SHA-1)
- Advanced search & filtering
- Image upload functionality

### 📋 Kế Hoạch
- Push notifications
- User reviews & ratings
- Advanced analytics
- Restaurant partnerships
- Payment integration

**Xem chi tiết tại**: [PROJECT_STATUS.md](PROJECT_STATUS.md)

## 🔧 Cấu Hình

### Firebase Setup

1. Tạo Firebase project tại [Firebase Console](https://console.firebase.google.com)
2. Thêm Android/iOS app
3. Download `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)
4. Enable Authentication (Email/Password & Google)
5. Tạo Cloud Firestore database

### Environment Variables

Tạo file `backend/.env`:
```env
PORT=5000
NODE_ENV=development
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
```

## 📱 Screenshots

### Mobile App
- **Splash & Onboarding**: Chào mừng người dùng mới
- **Authentication**: Đăng nhập/Đăng ký dễ dàng
- **Home**: Grid hiển thị món ăn
- **Favorites**: Danh sách yêu thích
- **Profile**: Thông tin người dùng

### Admin Dashboard
- **Dashboard Tab**: Thống kê tổng quan
- **Dishes Management**: Quản lý món ăn
- **Users Tab**: Danh sách người dùng

## 🔐 Bảo Mật

- ✅ Firebase Authentication
- ✅ Secure password hashing
- ✅ HTTPS for production
- ✅ Input validation
- ✅ CORS configuration
- ⏳ API rate limiting (planned)
- ⏳ JWT tokens (planned)

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Build & Deploy

### Android
```bash
flutter build apk --release
# Hoặc
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Backend
```bash
# Deploy to production server
npm start
```

## 🤝 Đóng Góp

Mọi đóng góp đều được chào đón! Vui lòng:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Dự án này được phát hành dưới giấy phép MIT. Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 👨‍💻 Tác Giả

**Nhóm Today's Eats**
- GitHub: [@nhoton2004](https://github.com/nhoton2004)

## 🙏 Lời Cảm Ơn

- Flutter team cho framework tuyệt vời
- Firebase team cho backend infrastructure
- Material Design team cho design system
- Cộng đồng open source

## 📞 Liên Hệ & Hỗ Trợ

- **Email**: support@todayseats.com
- **Issues**: [GitHub Issues](https://github.com/nhoton2004/Today-sEats/issues)
- **Documentation**: [Docs Index](DOCUMENTATION_INDEX.md)

---

<div align="center">

**Được phát triển với ❤️ bởi Today's Eats Team**

⭐ Nếu bạn thích dự án này, hãy cho chúng tôi một star!

[Website](https://todayseats.com) • [Documentation](DOCUMENTATION_INDEX.md) • [API Docs](backend/README.md)

</div>
