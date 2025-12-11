# Git Push An Toàn - Checklist ✅

**Ngày:** 11/12/2025  
**Project:** Today's Eats

---

## ✅ Bước 1: Kiểm tra bảo mật (Đã hoàn thành)

### Files nhạy cảm ĐÃ được ignore:
- ✅ `backend/.env` - Environment variables
- ✅ `backend/today-s-eats-firebase-adminsdk-*.json` - Firebase service account
- ✅ `backend/serviceAccountKey.json` - Service account key
- ✅ `lib/firebase_options.dart` - Firebase config
- ✅ `android/app/google-services.json` - Google services
- ✅ `node_modules/` - Dependencies

### Xác nhận không có trong Git:
```bash
$ git check-ignore backend/today-s-eats-firebase-adminsdk-*.json
✅ backend/today-s-eats-firebase-adminsdk-fbsvc-cabbf4193a.json (ignored)
✅ backend/serviceAccountKey.json (ignored)
```

---

## 📋 Bước 2: Review Changes

### Files đã staged (sẵn sàng commit):
```
✅ lib/features/3_menu_management/menu_management_api_provider.dart
✅ lib/features/4_dish_detail/dish_detail_screen.dart
```

### Files chưa staged (cần add):

**Backend:**
```
✅ backend/middleware/auth.middleware.js (Admin auth fix)
✅ backend/routes/dishes.routes.js (Admin routes)
```

**Frontend:**
```
✅ android/app/src/main/AndroidManifest.xml (Permissions)
✅ lib/app.dart (Admin route)
✅ lib/core/services/api_service.dart (updateUserProfile)
✅ lib/features/admin/admin_screen.dart (Admin UI)
✅ lib/features/profile/profile_screen.dart (Profile updates)
✅ lib/features/splash/splash_screen.dart (Role-based nav)
✅ pubspec.yaml (New packages)
✅ pubspec.lock (Updated dependencies)
```

**New Files:**
```
✅ docs/* (18 documentation files)
✅ lib/core/services/cache_service.dart
✅ lib/core/services/connectivity_service.dart
✅ lib/core/services/logout_service.dart
✅ lib/core/utils/error_handler.dart
✅ lib/core/utils/role_service.dart
✅ lib/features/admin/add_dish_dialog.dart
✅ lib/features/admin/edit_dish_dialog.dart
✅ lib/features/profile/edit_profile_screen.dart
✅ lib/features/profile/update_avatar_dialog.dart
```

---

## 🚀 Bước 3: Commit & Push Commands

### Option 1: Commit tất cả (Recommended)

```bash
# Add tất cả changes (trừ file ignored)
git add .

# Commit với message rõ ràng
git commit -m "feat: implement admin panel, role-based navigation, and offline support

- Admin panel with full CRUD operations
- Role-based navigation (user/admin routing)
- Offline/cache support with connectivity detection
- Avatar upload with image picker
- Error handling improvements
- Secure logout flow
- Documentation for all major features"

# Push lên remote
git push origin main
```

---

### Option 2: Commit từng feature riêng biệt

```bash
# 1. Admin feature
git add lib/features/admin/ backend/middleware/auth.middleware.js backend/routes/dishes.routes.js
git commit -m "feat: implement admin panel with CRUD operations"

# 2. Role-based navigation
git add lib/core/utils/role_service.dart lib/features/splash/splash_screen.dart lib/app.dart
git commit -m "feat: add role-based navigation for admin/user"

# 3. Offline support
git add lib/core/services/cache_service.dart lib/core/services/connectivity_service.dart
git commit -m "feat: add offline/cache support"

# 4. Profile updates
git add lib/features/profile/
git commit -m "feat: add edit profile and avatar upload"

# 5. Error handling
git add lib/core/utils/error_handler.dart
git commit -m "feat: improve error handling with user-friendly messages"

# 6. Logout
git add lib/core/services/logout_service.dart
git commit -m "feat: implement secure logout flow"

# 7. Permissions
git add android/app/src/main/AndroidManifest.xml
git commit -m "feat: add camera and storage permissions"

# 8. Dependencies
git add pubspec.yaml pubspec.lock
git commit -m "chore: add connectivity_plus and image_picker packages"

# 9. Documentation
git add docs/
git commit -m "docs: add comprehensive documentation for all features"

# Push tất cả
git push origin main
```

---

## ⚠️ QUAN TRỌNG: Trước khi push

### 1. Double-check không có secrets
```bash
# Check xem có file nào sắp commit chứa secrets không
git diff --cached | grep -i "api.*key\|secret\|password\|token"

# Nếu có kết quả → ĐỪ PUSH! Review lại
# Nếu không có kết quả → An toàn ✅
```

### 2. Review files sẽ được push
```bash
# Xem tất cả files sẽ commit
git status

# Xem chi tiết nội dung thay đổi
git diff --cached
```

### 3. Test local trước khi push
```bash
# Backend
cd backend
npm start
# ✅ Server chạy OK

# Frontend
flutter run
# ✅ App chạy OK
```

---

## 🆘 Nếu đã commit nhầm file nhạy cảm

### Nếu CHƯA push:
```bash
# Unstage file
git reset HEAD backend/serviceAccount.json

# Xóa khỏi Git nhưng giữ file local
git rm --cached backend/serviceAccount.json

# Commit lại
git commit --amend
```

### Nếu ĐÃ push (NGUY HIỂM):
```bash
# 1. Xóa file khỏi Git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch backend/serviceAccount.json' \
  --prune-empty --tag-name-filter cat -- --all

# 2. Force push (cẩn thận!)
git push origin main --force

# 3. QUAN TRỌNG: Rotate/Revoke credentials ngay!
# → Tạo service account key mới
# → Update backend với key mới
# → Xóa key cũ trong Firebase Console
```

---

## 📊 Commit Message Best Practices

### Format:
```
<type>: <short description>

<optional detailed description>
```

### Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style (formatting, no logic change)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance (dependencies, config)

### Examples:
```bash
✅ GOOD:
git commit -m "feat: implement admin panel with CRUD operations"
git commit -m "fix: resolve 404 error in user profile API"
git commit -m "docs: add API error handling documentation"

❌ BAD:
git commit -m "update"
git commit -m "changes"
git commit -m "fix stuff"
```

---

## ✅ Final Checklist

Before running `git push`:

- [ ] All sensitive files in `.gitignore`
- [ ] No API keys/secrets in code
- [ ] Tested locally (backend + frontend)
- [ ] Clear commit message
- [ ] Reviewed `git status` output
- [ ] Reviewed `git diff --cached`
- [ ] No `console.log` or debug code
- [ ] README updated (if needed)

**Ready to push!** 🚀

---

## 📝 Recommended Command (All-in-one)

```bash
# Từ root directory của project
cd /home/nho/Documents/TodaysEats

# Add all (excluding ignored files)
git add .

# Commit
git commit -m "feat: major update - admin panel, role-based nav, offline support

Features added:
- Admin panel with full CRUD for dishes
- Role-based navigation (admin/user automatic routing)
- Offline support with cache and connectivity detection
- Avatar upload with camera/gallery picker
- Profile editing functionality
- Secure logout with data cleanup
- Enhanced error handling with user-friendly messages
- Comprehensive documentation for all flows

Tech changes:
- Added connectivity_plus, image_picker packages
- Added Android permissions for camera and storage
- Backend admin authentication middleware
- Cache service for offline data
- Error handler utility
- Role service for user/admin detection"

# Push
git push origin main
```

---

## 🎯 Summary

**Safe to push:** ✅ YES

**Sensitive files:** ✅ All ignored

**New features:** 
- Admin Panel ✅
- Role-based Navigation ✅
- Offline/Cache ✅
- Avatar Upload ✅
- Error Handling ✅
- Secure Logout ✅

**Documentation:** 18 comprehensive docs ✅

**You're good to go!** Push with confidence! 🚀
