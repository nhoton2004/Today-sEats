import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dish.dart';

class StorageService {
  static const String _dishesKey = 'dishes';

  /// Save dishes to local storage
  Future<void> saveDishes(List<Dish> dishes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> dishesJson =
          dishes.map((dish) => dish.toJson()).toList();
      final String jsonString = json.encode(dishesJson);
      await prefs.setString(_dishesKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save dishes: $e');
    }
  }

  /// Load dishes from local storage
  Future<List<Dish>> loadDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_dishesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> dishesJson = json.decode(jsonString);
      return dishesJson
          .map((json) => Dish.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load dishes: $e');
    }
  }

  /// Clear all dishes from storage
  Future<void> clearDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dishesKey);
    } catch (e) {
      throw Exception('Failed to clear dishes: $e');
    }
  }

  /// Check if dishes exist in storage
  Future<bool> hasDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_dishesKey);
    } catch (e) {
      return false;
    }
  }
}
