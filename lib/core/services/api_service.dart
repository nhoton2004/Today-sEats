import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Helper method để get headers với auth token
  Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ========== DISHES API ==========

  // Get all dishes
  Future<List<Map<String, dynamic>>> getDishes({
    String? category,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri =
          Uri.parse('$baseUrl/dishes').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['dishes']);
      } else {
        throw Exception('Failed to load dishes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dishes: $e');
    }
  }

  // Get single dish
  Future<Map<String, dynamic>> getDishById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dishes/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dish: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dish: $e');
    }
  }

  // Create dish
  Future<Map<String, dynamic>> createDish(Map<String, dynamic> dishData,
      {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.post(
        Uri.parse('$baseUrl/dishes'),
        headers: headers,
        body: json.encode(dishData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create dish: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating dish: $e');
    }
  }

  // Update dish
  Future<Map<String, dynamic>> updateDish(
      String id, Map<String, dynamic> dishData,
      {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.put(
        Uri.parse('$baseUrl/dishes/$id'),
        headers: headers,
        body: json.encode(dishData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update dish: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating dish: $e');
    }
  }

  // Delete dish
  Future<void> deleteDish(String id, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.delete(
        Uri.parse('$baseUrl/dishes/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete dish: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting dish: $e');
    }
  }

  // ========== USERS API ==========

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri =
          Uri.parse('$baseUrl/users').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['users']);
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Get user by UID
  Future<Map<String, dynamic>> getUserByUid(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$uid'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Create or update user
  Future<Map<String, dynamic>> createOrUpdateUser(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create/update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating/updating user: $e');
    }
  }

  // Toggle favorite
  Future<Map<String, dynamic>> toggleFavorite(String uid, String dishId,
      {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.post(
        Uri.parse('$baseUrl/users/$uid/favorites'),
        headers: headers,
        body: json.encode({'dishId': dishId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to toggle favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }

  // ========== STATS API ==========

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  // ========== HEALTH CHECK ==========

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }
}
