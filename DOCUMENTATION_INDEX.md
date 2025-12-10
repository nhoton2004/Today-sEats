# 📚 Today's Eats - Documentation Index

> **Last Updated:** December 10, 2025  
> **Project:** Today's Eats - Complete Food Delivery Platform

---

## 📖 Essential Documentation

### Quick Start
- **[README.md](./README.md)** - Project overview and getting started
- **[Quickstart Guide](./docs/QUICKSTART.md)** - Fast setup for developers
- **[Project Status](./PROJECT_STATUS.md)** - Current development status
- **[Next Steps](./NEXT_STEPS.md)** - Upcoming features and improvements

---

## 🚀 Setup & Deployment

### Backend Setup
- **[MongoDB & S3 Setup](./docs/SETUP_MONGODB_S3.md)** - Complete backend configuration guide
- **[Integration Guide](./docs/INTEGRATION_GUIDE.md)** - Connect all services together
- **[Deployment Guide](./docs/DEPLOYMENT_GUIDE.md)** - Deploy to production environments

### Backend Structure
- **Location:** `backend/`
- **Server:** `server.js` (MongoDB + Firebase Auth)
- **Config:** MongoDB connection, Firebase Admin SDK
- **API Routes:** `/api/dishes`, `/api/users`, `/api/stats`

---

## 🎨 Design & Architecture

### Design System
- **[Design System Guide](./docs/DESIGN_SYSTEM_GUIDE.md)** - Colors, typography, components
- **[Design Principles](./docs/DESIGN_PRINCIPLES_IMPLEMENTATION.md)** - Implementation patterns

### Frontend Features
- Dark Mode support with theme provider
- Shimmer loading effects
- Hero animations for images
- Custom Google Fonts (Nunito/Quicksand)
- Multi-language support (EN/VI)

---

## 🔧 Technical Stack

### Frontend (Flutter)
```
lib/
├── core/               # Core utilities & constants
│   ├── constants/      # App colors, strings
│   ├── providers/      # Theme, locale providers
│   └── services/       # Auth, API services
├── features/           # Feature modules
│   ├── auth/          # Login, signup screens
│   ├── home/          # Home & dishes screens
│   └── profile/       # Profile, settings screens
└── common_widgets/    # Reusable widgets
    └── shimmer/       # Loading animations
```

### Backend (Node.js + Express)
```
backend/
├── config/            # Database configs
├── controllers/       # Business logic
├── models/           # Data models
├── routes/           # API routes
├── middleware/       # Auth & validation
├── services/         # External services
└── server.js         # Main server file
```

---

## 🔐 Environment Setup

### Required Environment Variables

**Backend (`backend/.env`):**
```env
# MongoDB
MONGODB_URI=mongodb+srv://...

# Firebase
FIREBASE_PROJECT_ID=today-s-eats
FIREBASE_DATABASE_ID=todayseats

# AWS S3 (Optional)
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_S3_BUCKET=...
AWS_REGION=...

# Server
PORT=5000
NODE_ENV=development
```

---

## 🚦 Getting Started

### 1. Clone & Install
```bash
git clone https://github.com/nhoton2004/Today-sEats.git
cd Today-sEats

# Install backend dependencies
cd backend
npm install

# Install Flutter dependencies
cd ..
flutter pub get
```

### 2. Configure Environment
```bash
# Backend: Create .env file with your credentials
# Add Firebase service account key as: backend/serviceAccountKey.json
```

### 3. Start Development
```bash
# Terminal 1: Start backend
cd backend && npm start

# Terminal 2: Start Flutter app
flutter run
```

---

## 📱 Features Overview

### User Features
- ✅ Google Authentication
- ✅ Browse dishes with pagination
- ✅ Add/remove favorites
- ✅ Profile management
- ✅ Dark/Light theme
- ✅ Multi-language (EN/VI)

### Admin Features (Web Dashboard)
- ✅ Manage dishes (CRUD)
- ✅ View statistics
- ✅ User management

---

## 🐛 Troubleshooting

### Common Issues

**Backend won't start:**
- Check MongoDB connection string in `.env`
- Verify `serviceAccountKey.json` exists and is valid
- Ensure port 5000 is not in use

**Flutter can't connect to backend:**
- Check `baseUrl` in `api_constants.dart`
- For emulator: use `http://10.0.2.2:5000`
- For physical device: use your computer's IP address

**Firebase Auth errors:**
- Regenerate service account key if exposed
- Check Firebase project configuration

---

**Happy Coding! 🚀**
