import 'package:flutter/material.dart';
import '../../core/services/ai_service.dart';
import '../../core/constants/app_constants.dart';

class FridgeAIProvider with ChangeNotifier {
  final AIService _aiService;

  FridgeAIProvider(this._aiService);

  String _ingredients = '';
  String? _suggestion;
  bool _isLoading = false;
  String? _errorMessage;

  String get ingredients => _ingredients;
  String? get suggestion => _suggestion;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateIngredients(String value) {
    _ingredients = value;
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  Future<void> submit() async {
    if (_ingredients.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập nguyên liệu có trong tủ lạnh.';
      notifyListeners();
      return;
    }

    if (_ingredients.length > AppConstants.maxIngredientsLength) {
      _errorMessage =
          'Danh sách nguyên liệu quá dài (>${AppConstants.maxIngredientsLength} ký tự).';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _suggestion = null;
    notifyListeners();

    try {
      final response =
          await _aiService.suggestDishesFromIngredients(_ingredients);
      _suggestion = response;
    } catch (e) {
      _errorMessage = AppConstants.aiErrorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSuggestion() {
    _suggestion = null;
    notifyListeners();
  }
}
