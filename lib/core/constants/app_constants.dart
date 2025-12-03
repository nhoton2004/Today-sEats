class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://your-api-endpoint.com/api';
  static const int apiTimeout = 30; // seconds
  
  // Storage Keys
  static const String dishesStorageKey = 'dishes';
  static const String userPreferencesKey = 'user_preferences';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  static const double cardElevation = 2.0;
  static const double buttonElevation = 4.0;
  
  // Animation durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  static const int spinnerAnimationDuration = 2000;
  
  // Spinner Configuration
  static const int spinnerCycleCount = 20; // Number of dishes to cycle through
  static const int spinnerDelayMs = 100; // Delay between each dish change
  
  // Image Configuration
  static const String defaultHeaderImage = 'https://picsum.photos/seed/1/1200/800';
  static const String placeholderImage = 'https://picsum.photos/seed/placeholder/400/400';
  
  // Default dishes (for initialization)
  static const List<Map<String, String>> defaultDishes = [
    {'name': 'Phở Bò', 'type': 'breakfast', 'category': 'vietnamese'},
    {'name': 'Bánh Mì Thịt', 'type': 'breakfast', 'category': 'vietnamese'},
    {'name': 'Cơm Tấm', 'type': 'lunch', 'category': 'vietnamese'},
    {'name': 'Bún Chả', 'type': 'lunch', 'category': 'vietnamese'},
    {'name': 'Mì Xào Bò', 'type': 'dinner', 'category': 'asian'},
    {'name': 'Pizza', 'type': 'dinner', 'category': 'western'},
    {'name': 'Gỏi Cuốn', 'type': 'snack', 'category': 'vietnamese'},
    {'name': 'Bánh Bao', 'type': 'snack', 'category': 'asian'},
  ];
  
  // Validation
  static const int minDishNameLength = 2;
  static const int maxDishNameLength = 100;
  static const int maxIngredientsLength = 500;
  
  // Error messages
  static const String networkErrorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
  static const String unknownErrorMessage = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
  static const String emptyDishListMessage = 'Chưa có món ăn nào. Hãy thêm món ăn đầu tiên!';
  static const String aiErrorMessage = 'AI đang bận. Vui lòng thử lại sau.';
}
