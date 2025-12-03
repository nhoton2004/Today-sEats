import 'package:flutter/material.dart';
import '../../core/models/dish.dart';
import '../../core/models/meal_type.dart';
import '../../core/models/category_filter_type.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class MenuManagementProvider with ChangeNotifier {
  MenuManagementProvider(this._storageService);

  final StorageService _storageService;

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

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final saved = await _storageService.loadDishes();
      if (saved.isEmpty) {
        _dishes
          ..clear()
          ..addAll(_defaultDishes);
        await _storageService.saveDishes(_dishes);
      } else {
        _dishes
          ..clear()
          ..addAll(saved);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách món ăn.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addDish({
    required String name,
    required MealType mealType,
    required CategoryFilterType category,
  }) async {
    if (name.trim().length < AppConstants.minDishNameLength) {
      throw Exception('Tên món phải dài hơn ${AppConstants.minDishNameLength} ký tự.');
    }

    final dish = Dish(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      type: mealType,
      category: category,
    );

    _dishes.add(dish);
    await _storageService.saveDishes(_dishes);
    notifyListeners();
  }

  Future<void> removeDish(String dishId) async {
    _dishes.removeWhere((dish) => dish.id == dishId);
    await _storageService.saveDishes(_dishes);
    notifyListeners();
  }

  Future<void> toggleFavorite(String dishId) async {
    final index = _dishes.indexWhere((dish) => dish.id == dishId);
    if (index == -1) return;

    _dishes[index] = _dishes[index].copyWith(
      isFavorite: !_dishes[index].isFavorite,
    );

    await _storageService.saveDishes(_dishes);
    notifyListeners();
  }

  void setMealFilter(MealType? mealType) {
    _selectedMealFilter = mealType;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

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

  List<Dish> get _defaultDishes {
    return AppConstants.defaultDishes.map((map) {
      final mealType = MealType.fromString(map['type']!);
      final category = CategoryFilterType.fromString(map['category']!);
      return Dish(
        id: '${map['name']}_${map['type']}_${map['category']}',
        name: map['name']!,
        type: mealType,
        category: category,
      );
    }).toList();
  }
}
