import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cache_service.dart';

/// Secure logout utility
class LogoutService {
  final CacheService _cacheService = CacheService();

  /// Perform secure logout with cleanup
  Future<void> secureLogout() async {
    try {
      // 1. Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // 2. Clear all local cache
      await _cacheService.clearAllCache();

      // 3. Clear SharedPreferences (if any auth tokens stored)
      // Note: Firebase Auth handles its own token storage
      
      print('✅ Secure logout completed');
      
    } catch (e) {
      print('❌ Error during logout: $e');
      rethrow;
    }
  }

  /// Show logout confirmation dialog
  Future<bool> showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Complete logout flow: confirm → logout → navigate
  Future<void> handleLogout(BuildContext context) async {
    // 1. Show confirmation dialog
    final confirmed = await showLogoutConfirmation(context);

    if (!confirmed) {
      return; // User canceled
    }

    // 2. Perform secure logout
    try {
      await secureLogout();

      // 3. Navigate to login screen
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false, // Remove all routes
        );
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
