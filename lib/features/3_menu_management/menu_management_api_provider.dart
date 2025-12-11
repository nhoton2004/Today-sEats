import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/dish.dart';
import '../../core/models/meal_type.dart';
import '../../core/models/category_filter_type.dart';
import '../../core/services/api_service.dart';

/// Provider mới sử dụng MongoDB API thay vì local storage
class MenuManagementApiProvider with ChangeNotifier {
  MenuManagementApiProvider(this._apiService);

  final ApiService _apiService;

  final List<Dish> _dishes = [];
  List<Dish> get dishes => List.unmodifiable(_dishes);

  MealType? _selectedMealFilter;
  bool _showFavoritesOnly = false;
  bool _isLoading = false;
  String? _errorMessage;

  MealType? get selectedMealFilter => _selectedMealFilter;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tải danh sách món ăn từ MongoDB
  Future<void> initialize() async {
    await loadDishes();
  }

  /// Tải lại dishes từ server
  Future<void> loadDishes() async {
    _setLoading(true);
    try {
      final dishesData = await _apiService.getDishes();
      _dishes.clear();

      for (var dishData in dishesData) {
        try {
          // Convert API data sang Dish model
          final dish = _convertApiDishToModel(dishData);
          _dishes.add(dish);
        } catch (e) {
          debugPrint('Error converting dish: $e');
        }
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách món ăn: $e';
      debugPrint('Error loading dishes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm món ăn mới
  Future<void> addDish({
    required String name,
    required MealType mealType,
    required CategoryFilterType category,
    String? description,
    double? price,
    String? imageUrl,
  }) async {
    if (name.trim().length < 2) {
      throw Exception('Tên món phải dài hơn 2 ký tự.');
    }

    _setLoading(true);
    try {
      // Get Firebase auth token and user
      final token = await _getAuthToken();
      final user = FirebaseAuth.instance.currentUser;
      
      // Gọi API để tạo dish mới
      final dishData = {
        'name': name.trim(),
        'category': category.value,
        'description': description ?? '',
        'price': price ?? 0,
        'status': 'active',
        'mealType': mealType.value,
        'createdBy': user?.uid, // Add creator's UID
      };

      final createdDish = await _apiService.createDish(dishData, token: token);
      final dish = _convertApiDishToModel(createdDish);

      _dishes.add(dish);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể thêm món ăn: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  /// Xóa món ăn
  Future<void> removeDish(String dishId) async {
    _setLoading(true);
    try {
      // Get Firebase auth token
      final token = await _getAuthToken();
      
      await _apiService.deleteDish(dishId, token: token);
      _dishes.removeWhere((dish) => dish.id == dishId);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể xóa món ăn: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  /// Toggle favorite (local only for now)
  Future<void> toggleFavorite(String dishId) async {
    final index = _dishes.indexWhere((dish) => dish.id == dishId);
    if (index == -1) return;

    _dishes[index] = _dishes[index].copyWith(
      isFavorite: !_dishes[index].isFavorite,
    );

    notifyListeners();

    // TODO: Gọi API để lưu favorite lên server nếu cần
    // await _apiService.toggleFavorite(userId, dishId);
  }

  /// Lọc theo meal type
  void setMealFilter(MealType? mealType) {
    _selectedMealFilter = mealType;
    notifyListeners();
  }

  /// Toggle hiển thị chỉ favorites
  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  /// Lấy danh sách đã lọc
  List<Dish> get filteredDishes {
    Iterable<Dish> results = _dishes;

    if (_selectedMealFilter != null) {
      results = results.where((dish) => dish.type == _selectedMealFilter);
    }

    if (_showFavoritesOnly) {
      results = results.where((dish) => dish.isFavorite);
    }

    return results.toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Convert API response sang Dish model
  Dish _convertApiDishToModel(Map<String, dynamic> apiDish) {
    // API trả về: { _id, name, category, description, imageUrl, price, status, mealType }
    // Model cần: { id, name, type (MealType), category (CategoryFilterType), isFavorite }

    String mealTypeValue = 'breakfast'; // default
    if (apiDish.containsKey('mealType')) {
      mealTypeValue = apiDish['mealType'] as String;
    } else if (apiDish.containsKey('type')) {
      mealTypeValue = apiDish['type'] as String;
    }

    String categoryValue = 'main';
    if (apiDish.containsKey('category')) {
      categoryValue = apiDish['category'] as String;
    }

    return Dish(
      id: apiDish['_id'] as String? ?? apiDish['id'] as String,
      name: apiDish['name'] as String,
      type: MealType.fromString(mealTypeValue),
      category: CategoryFilterType.fromString(categoryValue),
      isFavorite: apiDish['isFavorite'] as bool? ?? false,
    );
  }

  /// Get Firebase auth token
  Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }
}
