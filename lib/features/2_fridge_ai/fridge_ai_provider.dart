import 'package:flutter/material.dart';
import '../../core/services/ai_service.dart';
import '../../core/constants/app_constants.dart';

class FridgeAIProvider with ChangeNotifier {
  final AIService _aiService;

  FridgeAIProvider(this._aiService);

  List<String> _savedIngredients = [];
  List<Map<String, dynamic>> _suggestedDishes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<String> get savedIngredients => _savedIngredients;
  List<Map<String, dynamic>> get suggestedDishes => _suggestedDishes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void addIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    
    _savedIngredients.add(ingredient.trim());
    _errorMessage = null;
    notifyListeners();
  }

  void removeIngredient(int index) {
    if (index >= 0 && index < _savedIngredients.length) {
      _savedIngredients.removeAt(index);
      notifyListeners();
    }
  }

  void clearIngredients() {
    _savedIngredients.clear();
    notifyListeners();
  }

  Future<void> submit() async {
    if (_savedIngredients.isEmpty) {
      _errorMessage = 'Vui lòng thêm ít nhất 1 nguyên liệu.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _suggestedDishes = [];
    notifyListeners();

    try {
      // Build ingredients string from list
      final ingredientsText = _savedIngredients.join(', ');
      
      final response =
          await _aiService.suggestDishesFromIngredients(ingredientsText);
      
      // Extract dishes array from response
      if (response['suggestions'] != null && response['suggestions']['dishes'] != null) {
        _suggestedDishes = List<Map<String, dynamic>>.from(
          response['suggestions']['dishes']
        );
      }
    } catch (e) {
      _errorMessage = 'Không thể kết nối AI. Vui lòng thử lại: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSuggestion() {
    _suggestedDishes = [];
    notifyListeners();
  }
}
