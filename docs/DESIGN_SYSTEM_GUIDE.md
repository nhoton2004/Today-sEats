# Design System Guide - Today's Eats

## 10 Nguyên tắc thiết kế App Mobile chuyên nghiệp

### 1. Cấu trúc nội bộ rõ ràng (Clear Internal Structure)
- **Mục đích**: Người dùng dễ sử dụng, biết mình đang ở đâu trong app
- **Áp dụng**:
  - Sử dụng `FocusedScreen` hoặc `FocusedScreenWithAction` cho các màn hình
  - Navigation hierarchy rõ ràng với back button
  - Tab bar cho các chức năng chính (Home view)
  - Breadcrumb hoặc title bar hiển thị vị trí hiện tại

### 2. Vùng cảm ứng phù hợp (Appropriate Touch Target Size)
- **Kích thước**: Tối thiểu 48x48dp, khuyến nghị 56x56dp
- **Constants**: 
  - `AppConstants.minTouchTargetSize` (48dp)
  - `AppConstants.recommendedTouchTargetSize` (56dp)
  - `AppConstants.largeTouchTargetSize` (64dp)
- **Widgets hỗ trợ**:
  - `TouchTarget` - wrapper đảm bảo kích thước tối thiểu
  - `TouchIconButton` - icon button với touch target đủ lớn
  - `TouchChip` - chip với kích thước phù hợp
  - `CustomButton` - button với height tối thiểu 56dp

### 3. Giao diện sạch sẽ, ngăn nắp (Clean & Organized Interface)
- **Spacing constants**:
  - `AppConstants.smallPadding` (8dp)
  - `AppConstants.defaultPadding` (16dp)
  - `AppConstants.largePadding` (24dp)
  - `AppConstants.extraLargePadding` (32dp)
- **Widgets**:
  - Sử dụng `ConsistentCard` cho layout nhất quán
  - `EmptyFocusedScreen` cho empty states
  - Tránh quá nhiều element trên một màn hình

### 4. Font chữ phù hợp (Suitable Fonts)
- **Kích thước**:
  - Headings: H1 (32px), H2 (28px), H3 (24px), H4 (20px), H5 (18px)
  - Body text: Large (16px), Medium (14px), Small (12px)
  - Minimum: 12px cho text trên mobile
- **Line height**: 1.5 cho body text, 1.2-1.4 cho headings
- **Font weights**: 
  - Regular (400) - body text
  - Medium (500) - subtitles
  - SemiBold (600) - buttons, emphasis
  - Bold (700) - headings
- **Sử dụng**: `AppTextStyles.h1`, `AppTextStyles.bodyLarge`, etc.

### 5. Thao tác cảm ứng hợp lý (Reasonable Touch Controls)
- **Gestures hỗ trợ**:
  - Swipe: `SwipeableCard` widget
  - Tap: Standard buttons và cards
  - Long press: Context menus
- **Constants**:
  - `AppConstants.swipeThreshold` (50dp)
  - `AppConstants.swipeVelocityThreshold` (300 pixels/second)
- **Best practices**:
  - Swipe để delete, favorite
  - Pull to refresh
  - Pinch to zoom khi cần

### 6. Form đơn giản (Simplified Forms)
- **Nguyên tắc**: Chỉ hỏi thông tin thực sự cần thiết
- **Widgets**:
  - `SimpleTextField` - text input với label, validation
  - `SimpleForm` - form wrapper với auto-validation
- **Features**:
  - Inline validation
  - Clear error messages
  - Auto-focus next field
  - Submit on enter
  - Loading state tích hợp
- **Example**: Login chỉ cần email + password

### 7. Thiết kế thân thiện với ngón cái (Thumb-Friendly Design)
- **Thumb Zone**:
  - Bottom 1/3 của màn hình: Easy to reach
  - Middle: Moderate reach
  - Top: Difficult to reach
- **Best practices**:
  - Primary actions ở bottom: `FocusedScreenWithAction`
  - Navigation ở bottom: Bottom navigation bar
  - Secondary actions ở top: AppBar actions
  - Kích thước button tối thiểu 56dp height
- **Widgets**: `FocusedScreenWithAction` có action button cố định ở bottom

### 8. Thiết kế nhất quán (Consistent Design)
- **Card components**:
  - `ConsistentCard` - base card cho mọi thứ
  - `ImageHeaderCard` - cho dish cards
  - `InfoCard` - cho statistics, info
  - `ListTileCard` - cho list items
- **Colors**: Sử dụng `AppColors` palette
- **Spacing**: Sử dụng `AppConstants` cho spacing
- **Typography**: Sử dụng `AppTextStyles` cho text
- **Icons**: Sử dụng `AppConstants.defaultIconSize`, etc.

### 9. Một nhiệm vụ mỗi màn hình (One Task Per Screen)
- **Mục đích**: Người dùng tập trung, không bị phân tâm
- **Widgets**:
  - `FocusedScreen` - màn hình cơ bản với title
  - `FocusedScreenWithAction` - màn hình với một primary action
  - `EmptyFocusedScreen` - màn hình trống với hướng dẫn
- **Examples**:
  - Login screen: Chỉ đăng nhập
  - Add dish screen: Chỉ thêm món ăn
  - Profile screen: Chỉ xem/edit profile

### 10. Bảng màu hài hòa (Harmonious Color Palette)
- **Color Theory**: 60-30-10 rule
  - 60% Primary: `AppColors.primary` (#FF6B6B - coral red)
  - 30% Secondary: `AppColors.secondary` (#4ECDC4 - turquoise)
  - 10% Accent: `AppColors.accent` (#FFA07A - light salmon)
- **Psychology**:
  - Red/Coral: Kích thích cảm giác thèm ăn
  - Turquoise: Sự tươi mới và sạch sẽ
  - Salmon: Nhấn mạnh nhẹ nhàng
- **Contrast**: WCAG AA compliant cho accessibility
- **Usage**:
  - Primary cho main actions, branding
  - Secondary cho highlights, chips
  - Accent cho subtle emphasis

---

## Widget Library

### Layout Widgets
- `FocusedScreen` - Màn hình chuẩn với title
- `FocusedScreenWithAction` - Màn hình với action button ở bottom
- `EmptyFocusedScreen` - Empty state với icon và message

### Card Widgets
- `ConsistentCard` - Base card component
- `ImageHeaderCard` - Card với image header (cho dish)
- `InfoCard` - Card hiển thị thông tin số
- `ListTileCard` - List item card

### Form Widgets
- `SimpleTextField` - Text input với label và validation
- `SimpleForm` - Form wrapper với auto-submit

### Touch Target Widgets
- `TouchTarget` - Wrapper đảm bảo 48x48dp minimum
- `TouchIconButton` - Icon button với proper touch area
- `TouchChip` - Filter chip với proper sizing

### Gesture Widgets
- `SwipeableCard` - Card hỗ trợ swipe left/right
- `CustomButton` - Button với kích thước tối ưu

### Common Widgets
- `CustomButton` - Primary button component
- `CustomCard` - (deprecated, use ConsistentCard)
- `EmptyState` - Empty state component
- `FilterChip` - (use TouchChip instead)
- `LoadingIndicator` - Loading state

---

## Best Practices

### When to use what

**Forms:**
```dart
SimpleForm(
  children: [
    SimpleTextField(
      label: 'Email',
      validator: (value) => value?.isEmpty ? 'Required' : null,
    ),
  ],
  onSubmit: _handleSubmit,
)
```

**Screens:**
```dart
// Simple screen
FocusedScreen(
  title: 'Settings',
  child: ListView(...),
)

// Screen with primary action
FocusedScreenWithAction(
  title: 'Add Dish',
  actionText: 'Save',
  onActionPressed: _handleSave,
  child: Form(...),
)
```

**Cards:**
```dart
// Dish card
ImageHeaderCard(
  imageUrl: dish.imageUrl,
  title: dish.name,
  subtitle: dish.category,
  onTap: () => _viewDetails(dish),
)

// Info card
InfoCard(
  icon: Icons.restaurant,
  title: 'Total Dishes',
  value: '24',
)
```

**Touch targets:**
```dart
// Icon button
TouchIconButton(
  icon: Icons.favorite,
  onPressed: _toggleFavorite,
  tooltip: 'Toggle favorite',
)

// Any widget
TouchTarget(
  onTap: _handleTap,
  child: Text('Tap me'),
)
```

**Gestures:**
```dart
SwipeableCard(
  child: DishCard(...),
  onSwipeLeft: _handleDelete,
  onSwipeRight: _handleFavorite,
  leftBackgroundColor: Colors.red,
  rightBackgroundColor: Colors.green,
)
```

---

## Migration Guide

### Updating existing screens

1. **Replace Scaffold with FocusedScreen:**
```dart
// Before
Scaffold(
  appBar: AppBar(title: Text('Title')),
  body: content,
)

// After
FocusedScreen(
  title: 'Title',
  child: content,
)
```

2. **Replace TextFormField with SimpleTextField:**
```dart
// Before
TextFormField(
  decoration: InputDecoration(labelText: 'Email'),
  validator: (v) => v?.isEmpty ? 'Required' : null,
)

// After
SimpleTextField(
  label: 'Email',
  validator: (v) => v?.isEmpty ? 'Required' : null,
)
```

3. **Replace IconButton with TouchIconButton:**
```dart
// Before
IconButton(
  icon: Icon(Icons.favorite),
  onPressed: _toggle,
)

// After
TouchIconButton(
  icon: Icons.favorite,
  onPressed: _toggle,
)
```

4. **Use ConsistentCard instead of custom containers:**
```dart
// Before
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
  child: content,
)

// After
ConsistentCard(
  child: content,
)
```

---

## Constants Reference

### Spacing
- `smallPadding`: 8dp
- `defaultPadding`: 16dp
- `largePadding`: 24dp
- `extraLargePadding`: 32dp

### Touch Targets
- `minTouchTargetSize`: 48dp
- `recommendedTouchTargetSize`: 56dp
- `largeTouchTargetSize`: 64dp

### Button Heights
- `smallButtonHeight`: 44dp
- `buttonHeight`: 56dp
- `largeButtonHeight`: 64dp

### Icon Sizes
- `smallIconSize`: 20dp
- `defaultIconSize`: 24dp
- `mediumIconSize`: 32dp
- `largeIconSize`: 48dp

### Border Radius
- `smallBorderRadius`: 8dp
- `defaultBorderRadius`: 12dp
- `largeBorderRadius`: 16dp

### Animation
- `fastAnimationDuration`: 200ms
- `defaultAnimationDuration`: 300ms
- `slowAnimationDuration`: 500ms

---

## Testing Checklist

- [ ] All interactive elements have minimum 48x48dp touch targets
- [ ] Forms are simplified (only necessary fields)
- [ ] Each screen has one clear primary task
- [ ] Consistent spacing using AppConstants
- [ ] Consistent typography using AppTextStyles
- [ ] Consistent colors using AppColors
- [ ] Primary actions positioned in thumb-friendly zone
- [ ] Swipe gestures work smoothly
- [ ] Empty states provide clear guidance
- [ ] Loading states are shown for async operations
- [ ] Error messages are clear and helpful
