# Today's Eats - Backend Server

Express.js backend server with Firebase Admin SDK and admin dashboard for managing dishes, users, and app statistics.

## Features

- ✅ RESTful API for dish management (CRUD)
- ✅ User management and statistics
- ✅ Admin dashboard UI with real-time data
- ✅ Mock data support for development (no Firebase required)
- ✅ CORS enabled for frontend communication
- ✅ Responsive Material Design interface

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Start Server
```bash
npm start
```

Server runs on `http://localhost:5000` with admin dashboard at same URL.

### 3. Access Admin Dashboard
Open browser to `http://localhost:5000` and manage dishes, users, and stats.

## Development vs Production

### Development Mode (Current)
- Uses mock data (no Firebase required)
- Perfect for testing dashboard UI/UX
- All API endpoints fully functional
- Data stored in memory (resets on restart)

### Production Mode
1. Download `serviceAccountKey.json` from Firebase Console
2. Save to `backend/serviceAccountKey.json`
3. Server auto-detects and uses Firebase instead of mock data

## API Endpoints

### Dishes
- `GET /api/dishes` - Get all dishes
- `GET /api/dishes/:id` - Get single dish
- `POST /api/dishes` - Create new dish
- `PUT /api/dishes/:id` - Update dish
- `DELETE /api/dishes/:id` - Delete dish

### Users
- `GET /api/users` - Get all users with roles

### Statistics
- `GET /api/stats` - Get app statistics (totalDishes, activeDishes, totalUsers, etc.)

### Health
- `GET /api/health` - Server health check

## Admin Dashboard

The dashboard (`public/index.html`) includes:

### Dashboard Tab
- Total dishes count
- Active dishes count
- Total users count
- Server timestamp

### Dish Management Tab
- View all dishes in table
- Add new dish (modal form)
- Edit existing dish
- Delete dishes
- Status badges (active/inactive)
- Real-time success/error messages

### Users Tab
- View all registered users
- User roles (admin/user)
- Registration dates
- Email addresses

## Firebase Setup (Production)

### Get Service Account Key
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save as `backend/serviceAccountKey.json`

### Update .env
```env
PORT=5000
NODE_ENV=production
FIREBASE_PROJECT_ID=today-s-eats
FIREBASE_API_KEY=YOUR_API_KEY
FIREBASE_AUTH_DOMAIN=today-s-eats.firebaseapp.com
FIREBASE_STORAGE_BUCKET=today-s-eats.appspot.com
```

## Project Structure

```
backend/
├── server.js              # Express server with API routes
├── package.json           # Node dependencies
├── .env                  # Environment configuration
├── public/
│   └── index.html        # Admin dashboard UI
├── node_modules/         # Installed packages
└── README.md            # This file
```

## Technology Stack

- **Runtime**: Node.js 20+
- **Framework**: Express.js 5.x
- **Database**: Firestore (Firebase)
- **Frontend**: Vanilla HTML/CSS/JavaScript
- **Package Manager**: npm
- **Middleware**: CORS, express.json()

## Notes

- Dashboard is responsive and works on desktop, tablet, and mobile
- All form submissions include validation and error handling
- Mock data includes 3 sample dishes and 2 sample users
- Success/error messages auto-dismiss after 3 seconds
- Modal forms prevent outside clicks from closing
   - Scroll down to "SHA certificate fingerprints"
   - Click "Add fingerprint" and paste SHA-1

3. Download new `google-services.json`:
   - After adding SHA-1, download updated `google-services.json`
   - Replace `android/app/google-services.json`

### iOS Configuration (if needed)
1. Add GoogleService-Info.plist to `ios/Runner/`
2. Update Info.plist with URL scheme
3. Enable Google Sign In in Xcode capabilities

## Firestore Structure
- `users/{uid}`
  - `displayName`, `email`, `photoURL`, `role` ('user'|'admin')
  - `favorites`: array of dish ids
  - `createdAt`, `lastLoginAt`: timestamps
- `dishes/{dishId}`
  - `name`, `category`, `status` ('active'|'inactive'), `imageUrl`, `rating`
- `app_stats/{statId}`
  - counters and aggregates

## Security Rules (baseline)
Create `firestore.rules` and deploy with `firebase deploy --only firestore`:
```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow write: if request.auth != null && request.auth.uid == uid;
    }
    match /dishes/{dishId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true; // custom claims
    }
    match /app_stats/{doc} {
      allow read: if request.auth != null && request.auth.token.admin == true;
      allow write: if false;
    }
  }
}
```

## Cloud Functions Scaffold
Initialize in `backend/functions` after `firebase init`:
```bash
cd backend
firebase init functions
# Choose TypeScript, Node 20, ESLint
npm run build
firebase deploy --only functions
```

## Environment
- Android/iOS API keys are stored in `lib/firebase_options.dart` generated by FlutterFire.
- Do not commit service account keys.

## Frontend Integration
- Auth: email/password + Google Sign In via `firebase_auth` + `google_sign_in`
- Data: Firestore reads/writes for favorites and dishes
- Storage: upload images for dishes
- AuthService handles all authentication flows

Refer to this README while setting up and deploying the backend. 