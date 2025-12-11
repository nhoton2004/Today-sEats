import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class RoleService {
  final ApiService _apiService = ApiService();

  /// Check if current user is admin
  /// Returns true if admin, false otherwise
  Future<bool> isAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Fetch user data from MongoDB
      final userData = await _apiService.getUserByUid(user.uid);
      
      // Check role field
      final role = userData['role'] as String?;
      return role == 'admin';
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }

  /// Get user role
  /// Returns 'admin', 'user', 'moderator', or null if error
  Future<String?> getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Fetch user data from MongoDB
      final userData = await _apiService.getUserByUid(user.uid);
      
      return userData['role'] as String?;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  /// Navigate to appropriate screen based on role
  /// Returns route name: '/main' for users, '/admin' for admins
  Future<String> getHomeRouteForUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '/login';

      final role = await getUserRole();

      switch (role) {
        case 'admin':
          return '/admin';
        case 'moderator':
          return '/admin'; // Moderators also go to admin panel
        case 'user':
        default:
          return '/main';
      }
    } catch (e) {
      print('Error determining home route: $e');
      return '/main'; // Default to main screen on error
    }
  }
}
