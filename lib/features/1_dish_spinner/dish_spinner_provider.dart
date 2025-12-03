import 'package:flutter/foundation.dart';
import '../../core/models/dish.dart';
import '../../core/models/meal_type.dart';
import '../../core/models/category_filter_type.dart';

class DishSpinnerProvider with ChangeNotifier {
  List<Dish> _allDishes = [];
  MealType? _selectedMealType;
  CategoryFilterType _selectedCategory = CategoryFilterType.all;
  Dish? _currentResult;
  bool _isSpinning = false;

  List<Dish> get allDishes => _allDishes;
  MealType? get selectedMealType => _selectedMealType;
  CategoryFilterType get selectedCategory => _selectedCategory;
  Dish? get currentResult => _currentResult;
  bool get isSpinning => _isSpinning;

  void setDishes(List<Dish> dishes) {
    if (listEquals(_allDishes, dishes)) {
      return;
    }
    _allDishes = List<Dish>.from(dishes);

    if (_currentResult != null) {
      final match = _allDishes.where((dish) => dish.id == _currentResult!.id);
      _currentResult = match.isNotEmpty ? match.first : null;
    }
    notifyListeners();
  }

  void setMealType(MealType? type) {
    _selectedMealType = type;
    notifyListeners();
  }

  void setCategory(CategoryFilterType category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCurrentResult(Dish? dish) {
    _currentResult = dish;
    notifyListeners();
  }

  void setSpinning(bool spinning) {
    _isSpinning = spinning;
    notifyListeners();
  }

  List<Dish> getFilteredDishes() {
    var filtered = _allDishes;

    // Filter by meal type
    if (_selectedMealType != null) {
      filtered = filtered
          .where((dish) => dish.type == _selectedMealType)
          .toList();
    }

    // Filter by category
    if (_selectedCategory != CategoryFilterType.all) {
      filtered = filtered
          .where((dish) => dish.category == _selectedCategory)
          .toList();
    }

    return filtered;
  }

}
