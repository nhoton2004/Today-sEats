# 🎯 BƯỚC TIẾP THEO - Today's Eats

## ✅ Đã Hoàn Thành

1. ✅ MongoDB + AWS S3 integration
2. ✅ API service trong Flutter
3. ✅ Seed 20 món ăn mẫu
4. ✅ Test screen để kiểm tra API
5. ✅ Hướng dẫn deploy chi tiết

---

## 🚀 Option A: Test Local Ngay (5 phút)

### Cách 1: Dùng Script Auto (Khuyến nghị)
```bash
./start-dev.sh
```

### Cách 2: Manual
```bash
# Terminal 1: Start backend
cd backend
npm run mongo

# Terminal 2: Start Flutter
flutter run
```

### Test API trong app:
1. App mở → Tab **"Quản lý"** (icon admin)
2. Click nút **"Test API"** (màu cam)
3. Xem 20 món ăn từ MongoDB! 🎉

**Screenshot:** Bạn sẽ thấy:
- ✅ API Connected
- 20 Món ăn
- Phở Bò, Bún Chả, Cơm Tấm...

---

## 🌐 Option B: Deploy Backend (10-30 phút)

### B1. Railway (Khuyến nghị - 10 phút)

**1. Push code lên GitHub:**
```bash
git add .
git commit -m "Add MongoDB API integration with test screen"
git push origin main
```

**2. Deploy trên Railway:**
- Vào [railway.app](https://railway.app)
- Sign up với GitHub
- **New Project** → **Deploy from GitHub repo**
- Chọn `Today-sEats`
- Railway tự động detect và build

**3. Thêm Environment Variables:**

Vào **Variables** tab, paste:
```env
PORT=5000
NODE_ENV=production
MONGODB_URI=mongodb+srv://admin_backend_todayseats:7powIkXvbBVl7fNJ@cluster0.t4exz8c.mongodb.net/todays_eats?retryWrites=true&w=majority&appName=Cluster0
AWS_ACCESS_KEY_ID=todays-eats-s3-user-at-106189426512
AWS_SECRET_ACCESS_KEY=ABSKdG9kYXlzLWVhdHMtczMtdXNlci1hdC0xMDYxODk0MjY1MTI6MUNuK2V0NE15YU9EN1ZmTkE5Si9hZktOaEF5RjFuNjdEM2E0MUJlZktpSkpiNHdoL0xmZCtuS28xYW89
AWS_REGION=ap-southeast-1
AWS_S3_BUCKET=todays-eats-images
JWT_SECRET=todays_eats_secret_key_production_2024
CORS_ORIGIN=*
```

**4. Configure Start Command:**
- **Settings** → **Deploy** → **Start Command**
- Nhập: `cd backend && node server-mongodb.js`

**5. Test API:**
```bash
# Thay YOUR_RAILWAY_URL bằng URL từ Railway
curl https://your-app.up.railway.app/api/health
curl https://your-app.up.railway.app/api/dishes
```

**6. Update Flutter:**
```dart
// lib/core/services/api_service.dart
static const String baseUrl = 'https://your-app.up.railway.app/api';
```

Rebuild app: `flutter run`

---

### B2. Render.com (Alternative)

1. [render.com](https://render.com) → Sign up
2. **New** → **Web Service**
3. Connect GitHub → Chọn `Today-sEats`
4. Settings:
   - **Name**: todays-eats
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && node server-mongodb.js`
   - **Instance**: Free
5. Add Environment Variables (giống Railway)
6. Deploy!

---

### B3. AWS EC2 (Production-grade)

Xem `DEPLOYMENT_GUIDE.md` để biết chi tiết. Tóm tắt:
```bash
# 1. Create EC2 instance (Ubuntu 22.04, t2.micro)
# 2. SSH vào EC2
ssh -i "key.pem" ubuntu@your-ip

# 3. Install Node.js + PM2
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2

# 4. Clone repo
git clone https://github.com/nhoton2004/Today-sEats.git
cd Today-sEats/backend
npm install

# 5. Create .env (copy từ local)
nano .env

# 6. Start với PM2
pm2 start server-mongodb.js --name todays-eats
pm2 save
pm2 startup

# 7. Setup Nginx (optional)
# Xem DEPLOYMENT_GUIDE.md
```

---

## 📱 Option C: Tích Hợp Sâu Hơn (1-2 giờ)

### C1. Thay Local Storage bằng API trong Home Screen

**Hiện tại:** `MenuManagementProvider` dùng local storage

**Upgrade:** Dùng `MenuManagementApiProvider`

```dart
// lib/features/home/home_view.dart
// Thay:
Consumer<MenuManagementProvider>(...)
// Bằng:
Consumer<MenuManagementApiProvider>(...)
```

### C2. Thêm Image Upload UI

```dart
// lib/features/admin/add_dish_dialog.dart
import 'package:image_picker/image_picker.dart';
import '../../core/services/upload_service.dart';

Future<void> _pickAndUploadImage() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image != null) {
    final uploadService = UploadService();
    final imageUrl = await uploadService.uploadImage(File(image.path));
    setState(() => _imageUrl = imageUrl);
  }
}
```

### C3. Real-time Sync (WebSocket)

Backend đã sẵn sàng cho Socket.io. Cần:
1. Add `socket_io_client` vào pubspec.yaml
2. Connect to server
3. Listen for dish updates

---

## 🎨 Option D: UI/UX Improvements (30 phút - 1 giờ)

### D1. Áp dụng Design Principles cho tất cả screens

**Widgets đã có:**
- ✅ `SimpleForm` - Forms đơn giản
- ✅ `FocusedScreen` - One task per screen
- ✅ `ConsistentCard` - Consistent cards
- ✅ `TouchTarget` - 48-64dp touch areas
- ✅ `SwipeableCard` - Gesture support

**Screens cần update:**
- `FavoritesScreen` → Dùng SwipeableCard
- `ProfileScreen` → Dùng FocusedScreen
- `SettingsScreen` → Dùng SimpleForm

### D2. Add Loading States

```dart
// Ví dụ: Loading skeleton cho dishes
if (provider.isLoading) {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (_, __) => ShimmerCard(),
  );
}
```

### D3. Add Empty States

```dart
if (dishes.isEmpty) {
  return EmptyState(
    icon: Icons.restaurant_menu,
    title: 'Chưa có món ăn',
    description: 'Thêm món ăn mới để bắt đầu',
    action: ElevatedButton(...),
  );
}
```

---

## 🔥 Option E: Advanced Features (2+ giờ)

### E1. User Authentication Flow
- Login/Register với MongoDB users
- Store JWT token
- Protected routes

### E2. Favorites Sync
```dart
// Sync favorites between devices
await apiService.toggleFavorite(userId, dishId);
```

### E3. Push Notifications
- Firebase Cloud Messaging
- Notify when new dish added
- Daily meal suggestions

### E4. Offline Support
```dart
// Hybrid approach: Local + API
class HybridProvider {
  Future<void> syncDishes() async {
    try {
      final apiDishes = await apiService.getDishes();
      await storage.saveDishes(apiDishes);
    } catch (e) {
      // Use local data if API fails
      return await storage.loadDishes();
    }
  }
}
```

---

## 📊 Comparison

| Option | Time | Difficulty | Value |
|--------|------|-----------|-------|
| **A: Test Local** | 5 min | Easy | ⭐⭐⭐ See it work! |
| **B: Deploy** | 10-30 min | Medium | ⭐⭐⭐⭐⭐ Production ready |
| **C: Integration** | 1-2 hrs | Medium | ⭐⭐⭐⭐ Full API usage |
| **D: UI Improvements** | 30-60 min | Easy | ⭐⭐⭐ Better UX |
| **E: Advanced** | 2+ hrs | Hard | ⭐⭐⭐⭐ Complete app |

---

## 💡 Khuyến Nghị

**Nếu bạn muốn:**

1. **Xem kết quả ngay** → Option A (5 phút)
2. **Deploy production** → Option B1 (Railway - 10 phút)
3. **Develop thêm** → Option C hoặc D
4. **Build complete app** → A → B → C → D → E

**Thứ tự lý tưởng:**
```
Test Local (A) 
  ↓
Deploy Railway (B1)
  ↓
UI Improvements (D)
  ↓  
Deep Integration (C)
  ↓
Advanced Features (E)
```

---

## 🚀 Quick Commands

```bash
# Test local
./start-dev.sh

# Deploy prep
git add . && git commit -m "Ready for production" && git push

# Seed more data
cd backend && npm run seed

# Check API
curl http://localhost:5000/api/dishes

# Flutter commands
flutter clean
flutter pub get
flutter run

# Stop backend
pkill -f "npm run mongo"
```

---

## 📞 Need Help?

**Docs:** 
- `DEPLOYMENT_GUIDE.md` - Deploy options
- `INTEGRATION_COMPLETE.md` - What we did
- `DESIGN_SYSTEM_GUIDE.md` - UI widgets
- `MONGODB_S3_COMPLETE.md` - Backend setup

**Quick Debug:**
```bash
# Backend not starting?
cd backend && cat .env  # Check credentials

# API not connecting?
curl http://localhost:5000/api/health

# Flutter errors?
flutter doctor
flutter clean && flutter pub get
```

---

**Bạn muốn làm gì tiếp theo?** 🎯
