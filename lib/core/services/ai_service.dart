import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  // Use emulator localhost for Android
  static const String _baseUrl = 'http://10.0.2.2:5000/api';

  /// Get recipe from AI based on dish name
  Future<String> getRecipeFromDish(String dishName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/recipe'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'dishName': dishName}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['recipe'] as String;
      } else {
        throw Exception('Failed to get recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get recipe from AI: $e');
    }
  }

  /// Suggest new dishes based on meal type and category
  Future<List<String>> suggestNewDishes({
    required String mealType,
    required String category,
    int count = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/suggest-dishes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mealType': mealType,
          'category': category,
          'count': count,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['dishes'] as List);
      } else {
        throw Exception('Failed to suggest dishes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to suggest new dishes: $e');
    }
  }

  /// Suggest dishes based on available ingredients
  Future<Map<String, dynamic>> suggestDishesFromIngredients(String ingredients) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai/suggest-from-ingredients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ingredients': ingredients}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to get suggestions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to suggest dishes from ingredients: $e');
    }
  }

  /// Generate meal plan for a week
  Future<Map<String, dynamic>> generateWeeklyMealPlan() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/meal-plan'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate meal plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate weekly meal plan: $e');
    }
  }
}
