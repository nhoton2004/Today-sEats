import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/local_recipes.dart';

class FridgeAIProvider with ChangeNotifier {
  // Not used anymore, but keeping constructor structure if needed for DI mainly
  // or we can remove it. For now, we don't need AIService.
  
  FridgeAIProvider();

  static const String _storageKey = 'fridge_ingredients';
  
  List<String> _savedIngredients = [];
  List<Map<String, dynamic>> _suggestedDishes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<String> get savedIngredients => _savedIngredients;
  List<Map<String, dynamic>> get suggestedDishes => _suggestedDishes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Init - load from local storage
  Future<void> loadSavedIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIngredients = prefs.getStringList(_storageKey) ?? [];
    notifyListeners();
  }

  Future<void> _saveIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _savedIngredients);
  }

  void addIngredient(String input) {
    if (input.trim().isEmpty) return;
    
    // Split by common delimiters
    final parts = input.split(RegExp(r'[,;\n]'));
    bool changed = false;
    
    for (var part in parts) {
      final clean = part.trim();
      if (clean.isNotEmpty && !_savedIngredients.contains(clean)) {
        _savedIngredients.add(clean);
        changed = true;
      }
    }
    
    if (changed) {
      _saveIngredients();
      _errorMessage = null;
      notifyListeners();
    }
  }

  void removeIngredient(int index) {
    if (index >= 0 && index < _savedIngredients.length) {
      _savedIngredients.removeAt(index);
      _saveIngredients();
      notifyListeners();
    }
  }

  void clearIngredients() {
    _savedIngredients.clear();
    _saveIngredients();
    notifyListeners();
  }

  // --- Logic Layer ---

  // Normalize ingredient text: "2 quả trứng gà" -> "trứng gà"
  String _normalize(String input) {
    String text = input.toLowerCase();
    
    // Remove quantities (digits)
    text = text.replaceAll(RegExp(r'\d+'), '');
    
    // Remove units (naive list)
    final units = [
      'g', 'kg', 'gam', 'gram', 'lít', 'ml', 'thìa', 'muỗng', 
      'quả', 'trái', 'bó', 'mớ', 'lạng', 'cân', 'chén', 'bát', 'cây', 'củ', 'miếng', 'lát'
    ];
    
    // Remove delimiters around units if necessary or just remove the unit word
    for (var unit in units) {
      // remove unit if it stands alone or surrounded by spaces
      text = text.replaceAll(RegExp(r'\b' + unit + r'\b'), '');
    }
    
    // Remove extra spaces
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Check if target contains any of the source keywords
  bool _isMatch(String targetInfo, String userIngredient) {
    final t = _normalize(targetInfo);
    final u = _normalize(userIngredient);
    if (u.isEmpty) return false;
    return t.contains(u) || u.contains(t);
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

    // Fake delay to feel like AI processing
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final List<Map<String, dynamic>> results = [];

      for (var recipe in kLocalRecipes) {
        int matchedCount = 0;
        int totalRequired = recipe.requiredIngredients.length;
        List<String> missing = [];
        
        // Check Required
        for (var req in recipe.requiredIngredients) {
          bool found = false;
          for (var userItem in _savedIngredients) {
            if (_isMatch(req, userItem)) {
              found = true;
              break;
            }
          }
          if (found) {
            matchedCount++;
          } else {
            missing.add(req);
          }
        }
        
        // BONUS: Check Optional
        int bonusCount = 0;
         for (var opt in recipe.optionalIngredients) {
          for (var userItem in _savedIngredients) {
            if (_isMatch(opt, userItem)) {
              bonusCount++;
              break;
            }
          }
        }

        // Calculate Score
        // Base score = matched / total
        double score = (totalRequired > 0) 
            ? (matchedCount / totalRequired) 
            : 0.0;
        
        // Bonus add max 0.2
        if (score > 0) {
           score += (bonusCount * 0.05);
        }
        
        // Cap at 1.0 (100%)
        if (score > 1.0) score = 1.0;

        // Threshold: Show if at least 1 ingredient matches or score > 0.3
        if (matchedCount > 0) {
           results.add({
             'name': recipe.name,
             'cookingTime': recipe.cookingTime,
             'servings': recipe.servings,
             'additionalIngredients': missing.isNotEmpty ? missing : recipe.additionalIngredients,
             'cookingInstructions': recipe.cookingInstructions,
             'score': score,
             'matchRaw': matchedCount,
             'missing': missing, // pass missing logic
           });
        }
      }

      // Sort by score descending
      results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

      // Take top 10
      _suggestedDishes = results.take(10).toList();

      if (_suggestedDishes.isEmpty) {
        _errorMessage = "Chưa tìm thấy món phù hợp. Thử thêm nguyên liệu khác xem!";
      }

    } catch (e) {
      _errorMessage = 'Lỗi xử lý: $e';
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
