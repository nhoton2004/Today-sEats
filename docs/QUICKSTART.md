# Quick Start Guide - Today's Eats

## Start Everything in 2 Minutes

### Step 1: Start Backend Server
```bash
cd /home/nho/Documents/TodaysEats/backend
node server.js
```

You should see:
```
⚠️  serviceAccountKey.json not found. Running in demo mode with mock data.
🚀 Server is running on http://localhost:5000
📊 Admin dashboard: http://localhost:5000
📁 Database mode: Mock (Demo)
```

### Step 2: Open Admin Dashboard
Open browser and go to: **http://localhost:5000**

### Step 3: Test Features
- Click "Dashboard" tab → See statistics
- Click "Quản lý Món Ăn" → See dishes table
- Click "+ Thêm Món Mới" → Add a new dish
- Click "Người Dùng" → See registered users

## Backend API Endpoints

All endpoints available at `http://localhost:5000/api/`

### Dishes
```bash
# Get all dishes
curl http://localhost:5000/api/dishes

# Get one dish
curl http://localhost:5000/api/dishes/dish-1

# Add dish
curl -X POST http://localhost:5000/api/dishes \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Cơm Hến",
    "category": "Món chính",
    "status": "active"
  }'

# Update dish
curl -X PUT http://localhost:5000/api/dishes/dish-1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Cơm Hến Updated",
    "category": "Món chính",
    "status": "active"
  }'

# Delete dish
curl -X DELETE http://localhost:5000/api/dishes/dish-1
```

### Statistics
```bash
curl http://localhost:5000/api/stats
```

Response:
```json
{
  "totalDishes": 3,
  "activeDishes": 3,
  "inactiveDishes": 0,
  "totalUsers": 2,
  "timestamp": "2024-12-04T07:03:22.017Z"
}
```

### Users
```bash
curl http://localhost:5000/api/users
```

### Health Check
```bash
curl http://localhost:5000/api/health
```

## Start Flutter App

```bash
cd /home/nho/Documents/TodaysEats
flutter run
```

## Switch to Firebase (Production)

1. Download `serviceAccountKey.json` from Firebase Console
2. Save to `backend/serviceAccountKey.json`
3. Restart server:
   ```bash
   node backend/server.js
   ```

Server will auto-detect and switch to Firebase mode.

---

## Current Stack

```
Frontend:  Flutter 3.5.0 + Firebase Auth
Backend:   Express.js 5.x + Mock/Firebase Data
Dashboard: Vanilla HTML/CSS/JS
Database:  Firestore (mock in dev, real in prod)
```

## Files Created

- ✅ `backend/server.js` - Express server with API
- ✅ `backend/public/index.html` - Admin dashboard UI
- ✅ `backend/.env` - Environment configuration
- ✅ `backend/ADMIN_DASHBOARD_GUIDE.md` - Dashboard guide
- ✅ `SETUP_SUMMARY.md` - Complete setup documentation

## What Works Right Now

✅ Admin dashboard with 3 tabs
✅ Add/Edit/Delete dishes in real-time
✅ View all users
✅ See statistics
✅ Responsive on all devices
✅ Mock data (no setup needed)
✅ Ready for Firebase integration

## Next: Connect Flutter to Backend

1. Update `lib/core/services/auth_service.dart` to call backend
2. Sync user data with Firestore
3. Fetch dishes from `/api/dishes` endpoint
4. Add favorites to `/api/favorites` endpoint

---

**Questions?** Check `/SETUP_SUMMARY.md` or `backend/ADMIN_DASHBOARD_GUIDE.md`
