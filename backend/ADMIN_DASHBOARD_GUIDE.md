# Admin Dashboard - Quick Reference

## How to Use the Admin Dashboard

### Access the Dashboard
```
http://localhost:5000
```

### Dashboard Tab
Shows real-time statistics:
- Total Dishes: Number of all dishes in system
- Active Dishes: Dishes currently available
- Total Users: Registered app users
- Last Update: Server timestamp

### Manage Dishes Tab
Complete CRUD operations:

#### View Dishes
- Displays all dishes in a table
- Shows: Name, Category, Status (Active/Inactive), Rating
- Empty state message if no dishes exist

#### Add New Dish
1. Click "+ Thêm Món Mới" button
2. Fill in form:
   - **Tên Món Ăn** (required): Dish name
   - **Danh Mục** (required): Category (e.g., "Món chính", "Tráng miệng")
   - **URL Hình Ảnh**: Image URL (optional)
   - **Trạng Thái**: Active or Inactive
3. Click "Lưu Món Ăn"
4. Success message appears and table updates

#### Edit Dish
1. Click "Sửa" button on any dish row
2. Modal opens with current values
3. Modify fields as needed
4. Click "Lưu Món Ăn" to save
5. Table updates automatically

#### Delete Dish
1. Click "Xóa" button on any dish row
2. Confirm deletion in popup
3. Dish removed from table immediately

### Users Tab
View all registered users:
- **Tên**: User display name
- **Email**: Email address
- **Vai Trò**: User role (admin/user)
- **Ngày Tạo**: Registration date

## API Integration

### Base URL
```
http://localhost:5000/api
```

### Endpoints Used by Dashboard

#### Fetch Dashboard Stats
```javascript
GET /api/stats
Response: {
  totalDishes: number,
  activeDishes: number,
  inactiveDishes: number,
  totalUsers: number,
  timestamp: ISO string
}
```

#### Fetch All Dishes
```javascript
GET /api/dishes
Response: Array of dishes {
  id: string,
  name: string,
  category: string,
  imageUrl: string,
  status: 'active' | 'inactive',
  rating: number
}
```

#### Create Dish
```javascript
POST /api/dishes
Body: {
  name: string (required),
  category: string (required),
  imageUrl: string (optional),
  status: 'active' | 'inactive' (optional)
}
Response: { id, name, category, imageUrl, status }
```

#### Update Dish
```javascript
PUT /api/dishes/:id
Body: {
  name: string,
  category: string,
  imageUrl: string,
  status: 'active' | 'inactive'
}
Response: { id, ...updatedFields }
```

#### Delete Dish
```javascript
DELETE /api/dishes/:id
Response: { success: true, id }
```

#### Fetch All Users
```javascript
GET /api/users
Response: Array of users {
  id: string,
  displayName: string,
  email: string,
  role: 'admin' | 'user',
  createdAt: { seconds: number }
}
```

## Features & UX Details

### Notifications
- **Success Messages**: Green background, auto-dismiss after 3 seconds
- **Error Messages**: Red background, auto-dismiss after 3 seconds
- Messages appear at top of content area

### Loading States
- Spinner animation appears while data loads
- User interactions disabled during loading

### Modal Behaviors
- Click outside modal to close
- Close button (×) in top right
- Form resets when modal opens
- Submit button shows current action (Save/Update)

### Responsive Design
- Works on desktop (1200px+), tablet (768px+), mobile (320px+)
- Stat cards stack vertically on small screens
- Table becomes scrollable on mobile
- Modal scales to 90% of viewport width on mobile

### Data Persistence
- **Development Mode**: Data stored in server memory (resets on restart)
- **Production Mode**: Data persists in Firestore

### Status Badges
- **Active** (green): Dish is available
- **Inactive** (red): Dish is not available

## Keyboard Shortcuts
- `Escape`: Close modal (when open)
- `Enter`: Submit form (when focused on form)

## Tips & Best Practices

1. **Image URLs**: Use full URLs starting with `https://`
2. **Categories**: Keep category names consistent for better organization
3. **Ratings**: Auto-calculated from user ratings (read-only from dashboard)
4. **Mobile Testing**: Use browser DevTools to test responsive design
5. **Data Backup**: For important changes, consider exporting user data first

## Troubleshooting

### Dashboard Won't Load
- Verify server is running: `npm start` in backend folder
- Check if port 5000 is available
- Try `http://localhost:5000` in browser

### Can't Add/Edit Dishes
- Verify both "Tên Món Ăn" and "Danh Mục" are filled
- Check browser console for errors (F12)
- Try refreshing the page

### Images Not Showing
- Verify image URL is valid and starts with `https://`
- Check CORS settings if using external image service
- Placeholder images work fine for testing

### Data Not Persisting
- If development mode: Expected behavior (mock data)
- For persistence, set up Firebase with serviceAccountKey.json
- Server logs will show "Mock (Demo)" vs "Firebase"

## Browser Compatibility
- Chrome/Edge: Full support
- Firefox: Full support
- Safari: Full support
- Mobile browsers: Fully responsive

## Colors & Design
- Primary color: #667eea (Purple)
- Success: #d4edda (Light green)
- Error: #f8d7da (Light red)
- Border radius: 8-12px (rounded corners)
- Shadows: Subtle depth effect

---

**Need Help?** Check server logs: `npm start` shows connection status and errors.
