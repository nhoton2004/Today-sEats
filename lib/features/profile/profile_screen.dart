import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../common_widgets/consistent_card.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final stats = await _apiService.getUserStats(user.uid);
      if (mounted) {
        setState(() {
          _userStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
      print('Error loading user stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (user == null) {
              return const Center(child: Text('Chưa đăng nhập'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 16),
                  _buildStatsSection(),
                  const SizedBox(height: 16),
                  _buildMenuSection(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    final displayName = user.displayName ?? 'Người dùng';
    final email = user.email ?? '';
    final photoURL = user.photoURL;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: photoURL != null && photoURL.isNotEmpty
                      ? NetworkImage(photoURL)
                      : NetworkImage(
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&size=200&background=FF6B35&color=fff',
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final dishesCreated = _userStats?['dishesCreated'] ?? 0;
    final favoritesCount = _userStats?['favoritesCount'] ?? 0;
    final cookedCount = _userStats?['cookedCount'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              dishesCreated.toString(),
              'Món ăn',
              Icons.restaurant_menu,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              favoritesCount.toString(),
              'Yêu thích',
              Icons.favorite,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              cookedCount.toString(),
              'Đã nấu',
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return ConsistentCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () async {
              // Navigate to edit profile screen
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              
              // Reload user stats if profile was updated
              if (result == true) {
                _loadUserStats();
              }
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            onTap: () {
              // TODO: Show about dialog
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Đăng xuất',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ConsistentCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
