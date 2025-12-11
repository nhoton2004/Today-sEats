import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../common_widgets/custom_card.dart';
import '../../core/services/api_service.dart';
import 'add_dish_dialog.dart';
import 'edit_dish_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _dishes = [];
  bool _isLoading = false;
  bool _isAdmin = false;
  String? _errorMessage;
  
  // Stats
  int _totalDishes = 0;
  int _activeDishes = 0;
  int _inactiveDishes = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAdminAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAndLoadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Vui lòng đăng nhập';
        _isAdmin = false;
      });
      return;
    }

    try {
      // Check if user is admin
      final userData = await _apiService.getUserByUid(user.uid);
      final userRole = userData['role'] as String?;
      
      setState(() {
        _isAdmin = userRole == 'admin';
      });

      if (_isAdmin) {
        await _loadDishes();
      } else {
        setState(() {
          _errorMessage = 'Bạn không có quyền truy cập trang này';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi kiểm tra quyền: $e';
        _isAdmin = false;
      });
    }
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dishes = await _apiService.getDishes(limit: 1000);
      
      setState(() {
        _dishes = dishes;
        _totalDishes = dishes.length;
        _activeDishes = dishes.where((d) => d['status'] == 'active').length;
        _inactiveDishes = dishes.where((d) => d['status'] == 'inactive').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách món: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddDish() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddDishDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        final token = await user?.getIdToken();

        await _apiService.createDish(result, token: token);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã thêm món ăn thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadDishes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleEditDish(Map<String, dynamic> dish) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditDishDialog(dish: dish),
    );

    if (result != null) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        final token = await user?.getIdToken();
        final dishId = dish['_id'] ?? dish['id'];

        await _apiService.updateDish(dishId, result, token: token);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã cập nhật món ăn thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadDishes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleDeleteDish(Map<String, dynamic> dish) async {
    final dishName = dish['name'] ?? 'món ăn này';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa món ăn'),
        content: Text('Bạn có chắc chắn muốn xóa "$dishName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        final token = await user?.getIdToken();
        final dishId = dish['_id'] ?? dish['id'];

        await _apiService.deleteDish(dishId, token: token);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã xóa "$dishName" thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadDishes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin && _errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Quản Lý Món Ăn'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _checkAdminAndLoadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản Lý Món Ăn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDishes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả món'),
            Tab(text: 'Thống kê'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDishesTab(),
                _buildStatisticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _handleAddDish,
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDishesTab() {
    if (_dishes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có món ăn nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhấn nút "Thêm món" để tạo món ăn mới',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDishes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dishes.length,
        itemBuilder: (context, index) {
          final dish = _dishes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDishCard(dish),
          );
        },
      ),
    );
  }

  Widget _buildDishCard(Map<String, dynamic> dish) {
    final isActive = dish['status'] == 'active';
    final imageUrl = dish['imageUrl'] as String?;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish['name'] ?? 'Món ăn',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Hoạt động' : 'Ngưng',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish['category'] ?? 'Không có danh mục',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (dish['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      dish['description'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _handleEditDish(dish),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Colors.red),
                        onPressed: () => _handleDeleteDish(dish),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.cardBackground,
      child: const Icon(
        Icons.restaurant,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  _totalDishes.toString(),
                  'Tổng số món',
                  Icons.restaurant_menu,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  _activeDishes.toString(),
                  'Đang hoạt động',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  _inactiveDishes.toString(),
                  'Ngưng hoạt động',
                  Icons.pause_circle,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(), // Placeholder
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
