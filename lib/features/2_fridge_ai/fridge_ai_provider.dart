import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../core/services/ai_service.dart';

class FridgeAIProvider with ChangeNotifier {
  final AIService _aiService;

  FridgeAIProvider(this._aiService);

  static const String _storageKey = 'fridge_ingredients';
  
  List<String> _savedIngredients = [];
  List<Map<String, dynamic>> _suggestedDishes = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  List<String> get savedIngredients => _savedIngredients;
  List<Map<String, dynamic>> get suggestedDishes => _suggestedDishes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get cooldownSeconds => _cooldownSeconds;

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

  void startCooldown(int seconds) {
    _cooldownSeconds = seconds;
    notifyListeners();
    
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        _cooldownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> submit() async {
    if (_cooldownSeconds > 0) return; // Prevent spam

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
      final ingredientsText = _savedIngredients.join(', ');
      
      // Call API
      final response = await _aiService.suggestDishesFromIngredients(ingredientsText);
      
      // Schema v4: response has 'dishes' list
      if (response['dishes'] != null) {
        final List<dynamic> rawDishes = response['dishes'];
        
        _suggestedDishes = rawDishes.map((d) {
          final dishMap = d as Map<String, dynamic>;
          
          // Parse timeMinutes
          int cookingTime = dishMap['timeMinutes'] ?? 0;
          
          // Parse matchPercent
          double score = 0.0;
          if (dishMap['matchPercent'] != null) {
             score = (dishMap['matchPercent'] as num).toDouble() / 100.0;
          }

          final missingList = dishMap['missingIngredients'] ?? [];
          final quickSteps = dishMap['quickSteps'] ?? [];
          
          return {
            'name': dishMap['name'],
            'cookingTime': cookingTime,
            'servings': 2, // Default
            'difficulty': dishMap['difficulty'],
            'note': dishMap['shortDescription'], // Map shortDescription -> note
            'quick_steps': quickSteps, 
            'score': score,
            'missing': missingList,
            'used': [], 
            'additionalIngredients': [], 
            'cookingInstructions': [], 
          };
        }).toList();
      }

      if (_suggestedDishes.isEmpty) {
        if (response['message'] != null) {
          _errorMessage = response['message'];
        } else {
          _errorMessage = "AI chưa tìm thấy món phù hợp. Hãy thử lại!";
        }
      }

    } catch (e) {
      print('❌ AI Provider Error: $e');
      String msg = e.toString();
      
      // Handle 429 specific message
      if (msg.contains('429')) {
         startCooldown(30);
         _errorMessage = "Server đang bận (429). Vui lòng đợi 30s.";
      } else {
         _errorMessage = 'Lỗi kết nối AI: $e\nHãy đảm bảo bạn đã khởi chạy backend.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Connection States


  void clearSuggestion() {
    _suggestedDishes = [];
    notifyListeners();
  }
}
