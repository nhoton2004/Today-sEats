import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage local cache for offline support
class CacheService {
  static const String _dishesKey = 'cached_dishes';
  static const String _favoritesKey = 'cached_favorites';
  static const String _userStatsKey = 'cached_user_stats';
  static const String _lastUpdateKey = 'cache_last_update';

  /// Save dishes to cache
  Future<void> saveDishesCache(List<Map<String, dynamic>> dishes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishesJson = json.encode(dishes);
      await prefs.setString(_dishesKey, dishesJson);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      print('✅ Cached ${dishes.length} dishes');
    } catch (e) {
      print('❌ Error saving dishes cache: $e');
    }
  }

  /// Get cached dishes
  Future<List<Map<String, dynamic>>?> getCachedDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishesJson = prefs.getString(_dishesKey);
      
      if (dishesJson == null) {
        print('📭 No cached dishes found');
        return null;
      }

      final List<dynamic> decoded = json.decode(dishesJson);
      final dishes = decoded.cast<Map<String, dynamic>>();
      print('📦 Loaded ${dishes.length} dishes from cache');
      return dishes;
    } catch (e) {
      print('❌ Error loading dishes cache: $e');
      return null;
    }
  }

  /// Save favorites to cache
  Future<void> saveFavoritesCache(List<Map<String, dynamic>> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(favorites);
      await prefs.setString(_favoritesKey, favoritesJson);
      print('✅ Cached ${favorites.length} favorites');
    } catch (e) {
      print('❌ Error saving favorites cache: $e');
    }
  }

  /// Get cached favorites
  Future<List<Map<String, dynamic>>?> getCachedFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson == null) {
        print('📭 No cached favorites found');
        return null;
      }

      final List<dynamic> decoded = json.decode(favoritesJson);
      final favorites = decoded.cast<Map<String, dynamic>>();
      print('📦 Loaded ${favorites.length} favorites from cache');
      return favorites;
    } catch (e) {
      print('❌ Error loading favorites cache: $e');
      return null;
    }
  }

  /// Save user stats to cache
  Future<void> saveUserStatsCache(Map<String, dynamic> stats, String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats);
      await prefs.setString('${_userStatsKey}_$uid', statsJson);
      print('✅ Cached user stats for $uid');
    } catch (e) {
      print('❌ Error saving user stats cache: $e');
    }
  }

  /// Get cached user stats
  Future<Map<String, dynamic>?> getCachedUserStats(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('${_userStatsKey}_$uid');
      
      if (statsJson == null) {
        print('📭 No cached stats found for $uid');
        return null;
      }

      final stats = json.decode(statsJson) as Map<String, dynamic>;
      print('📦 Loaded user stats from cache');
      return stats;
    } catch (e) {
      print('❌ Error loading user stats cache: $e');
      return null;
    }
  }

  /// Get last cache update time
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateStr = prefs.getString(_lastUpdateKey);
      
      if (lastUpdateStr == null) return null;
      
      return DateTime.parse(lastUpdateStr);
    } catch (e) {
      print('❌ Error getting last update time: $e');
      return null;
    }
  }

  /// Check if cache is stale (older than specified duration)
  Future<bool> isCacheStale({Duration maxAge = const Duration(hours: 24)}) async {
    final lastUpdate = await getLastUpdateTime();
    if (lastUpdate == null) return true;
    
    final age = DateTime.now().difference(lastUpdate);
    return age > maxAge;
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dishesKey);
      await prefs.remove(_favoritesKey);
      await prefs.remove(_lastUpdateKey);
      
      // Clear all user stats (keys starting with prefix)
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_userStatsKey)) {
          await prefs.remove(key);
        }
      }
      
      print('🗑️ All cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Clear specific cache
  Future<void> clearDishesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dishesKey);
      print('🗑️ Dishes cache cleared');
    } catch (e) {
      print('❌ Error clearing dishes cache: $e');
    }
  }

  /// Get cache size info
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final dishesJson = prefs.getString(_dishesKey);
      final favoritesJson = prefs.getString(_favoritesKey);
      final lastUpdate = await getLastUpdateTime();
      
      return {
        'hasDishes': dishesJson != null,
        'hasFavorites': favoritesJson != null,
        'lastUpdate': lastUpdate?.toIso8601String(),
        'isStale': await isCacheStale(),
      };
    } catch (e) {
      print('❌ Error getting cache info: $e');
      return {};
    }
  }
}
