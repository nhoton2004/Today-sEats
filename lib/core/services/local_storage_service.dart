import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _localDishesKey = 'local_dishes';
  static const String _seedFlagKey = 'is_seeded_v2'; // New flag for full menu seed

  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // --- RAW DATA ---
  static const List<String> _morningNames = [
    'Bánh mì', 'Xôi mặn', 'Phở bò', 'Phở gà', 'Bún bò', 'Bún riêu', 'Hủ tiếu',
    'Miến gà', 'Bánh cuốn', 'Cháo lòng', 'Cháo gà', 'Bánh bao', 'Bánh bèo',
    'Bánh căn', 'Nui xào', 'Cơm tấm', 'Trứng ốp la', 'Bún cá', 'Mì quảng', 'Xôi gà',
  ];

  static const List<String> _noonNames = [
    'Cơm gà', 'Cơm sườn', 'Cơm tấm', 'Bún thịt nướng', 'Bún chả', 'Bún bò',
    'Phở', 'Hủ tiếu', 'Mì xào', 'Cơm chiên', 'Bún riêu', 'Bánh canh',
    'Gỏi cuốn', 'Bánh mì', 'Lẩu mini', 'Cơm cá kho', 'Canh chua', 'Bún mắm',
    'Bún thái', 'Cơm trộn',
  ];

  static const List<String> _nightNames = [
    'Lẩu', 'Bún đậu', 'Bánh xèo', 'Cháo', 'Mì cay', 'Bánh tráng trộn',
    'Ốc', 'Cơm', 'Phở', 'Bún bò', 'Bún riêu', 'Hủ tiếu', 'Mì ý',
    'Gà rán', 'Pizza', 'Hamburger', 'Bún thịt nướng', 'Cơm chiên', 'Bánh canh', 'Miến',
  ];

  // Helper to generate dish objects
  List<Map<String, dynamic>> _generateDishes(List<String> names, String mealType) {
    return names.asMap().entries.map((entry) {
      return {
        'id': 'seed_${mealType}_${entry.key}',
        'name': entry.value,
        'mealType': mealType,
        'isLocal': true,
      };
    }).toList();
  }

  // Seed data logic
  Future<void> seedDataIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isSeeded = prefs.getBool(_seedFlagKey) ?? false;

      if (!isSeeded) {
        print('🌱 Seeding FULL menu (Morning, Noon, Night)...');
        
        final List<Map<String, dynamic>> allDefaultDishes = [
          ..._generateDishes(_morningNames, 'breakfast'),
          ..._generateDishes(_noonNames, 'lunch'),
          ..._generateDishes(_nightNames, 'dinner'),
        ];

        // Overwrite existing local data to ensure clean state for this request
        await prefs.setString(_localDishesKey, json.encode(allDefaultDishes));
        
        // Mark as seeded
        await prefs.setBool(_seedFlagKey, true);
        print('✅ Seed completed: ${allDefaultDishes.length} dishes.');
      }
    } catch (e) {
      print('Error seeding data: $e');
    }
  }

  // Get all local dishes
  Future<List<Map<String, dynamic>>> getLocalDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? dishesJson = prefs.getString(_localDishesKey);
      
      if (dishesJson == null) return [];
      
      final List<dynamic> decoded = json.decode(dishesJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error loading local dishes: $e');
      return [];
    }
  }

  // Save a new dish locally
  Future<void> saveDish(Map<String, dynamic> dish) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishes = await getLocalDishes();
      
      // Generate a local ID if not present
      if (!dish.containsKey('id') && !dish.containsKey('_id')) {
        dish['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }
      // Mark as isLocal for UI handling
      dish['isLocal'] = true;
      
      dishes.add(dish);
      
      await prefs.setString(_localDishesKey, json.encode(dishes));
    } catch (e) {
      print('Error saving local dish: $e');
      rethrow;
    }
  }

  // Delete a local dish
  Future<void> deleteDish(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishes = await getLocalDishes();
      
      dishes.removeWhere((dish) => 
        (dish['id'] == id) || (dish['_id'] == id)
      );
      
      await prefs.setString(_localDishesKey, json.encode(dishes));
    } catch (e) {
      print('Error deleting local dish: $e');
      rethrow;
    }
  }
}
