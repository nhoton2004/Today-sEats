import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../common_widgets/dish_spin_wheel.dart';
import '../../common_widgets/meal_time_selector.dart';

import '../../common_widgets/dish_result_dialog.dart';
import '../../common_widgets/add_dish_dialog.dart';
import '../4_dish_detail/dish_detail_screen.dart';
import 'suggestion_sheet_widget.dart';

class SpinHomeScreen extends StatefulWidget {
  const SpinHomeScreen({super.key});

  @override
  State<SpinHomeScreen> createState() => _SpinHomeScreenState();
}

class _SpinHomeScreenState extends State<SpinHomeScreen> {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();
  List<Map<String, dynamic>> _allDishes = [];
  List<Map<String, dynamic>> _filteredDishes = [];
  bool _isLoading = true;
  String? _selectedMealTime = 'breakfast'; // Default to Breakfast for instant usage

  void _showSuggestionSheet() {
    final source = _filteredDishes.isEmpty ? _allDishes : _filteredDishes;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SuggestionSheet(dishes: source),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    // 0. Ensure seed data exists
    await _localStorage.seedDataIfNeeded();

    // 1. Load Local dishes IMMEDIATELY
    try {
      final localDishes = await _localStorage.getLocalDishes();
      if (mounted && localDishes.isNotEmpty) {
        setState(() {
          _allDishes = localDishes; // Show local data first
          _filterDishes();
          _isLoading = false; // Stop loading spinner immediately if we have local data
        });
      }

      // 2. Load API dishes in background
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'anonymous';
      
      List<Map<String, dynamic>> apiDishes = [];
      try {
        apiDishes = await _apiService.getAllDishesWithPersonal(
          userId: userId,
          limit: 50,
        ).timeout(const Duration(seconds: 5)); // Add timeout for API
      } catch (e) {
        print('API Error (using fallback): $e');
        try {
          apiDishes = await _apiService.getDishes(limit: 50).timeout(const Duration(seconds: 5));
        } catch (e2) {
          print('Fallback API failed: $e2');
        }
      }

      if (mounted && apiDishes.isNotEmpty) {
        // 3. Merge and update safely
        final currentLocalDishes = await _localStorage.getLocalDishes();
        setState(() {
          _allDishes = [...apiDishes, ...currentLocalDishes];
          _filterDishes();
          _isLoading = false;
        });
      } else if (mounted && _allDishes.isEmpty) {
         // If no local data and API failed, ensure loading is off
         setState(() => _isLoading = false);
      }
      
    } catch (e) {
      print('Error loading dishes: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addPersonalDish(Map<String, dynamic> dishData) async {
    try {
      // Save locally (works offline)
      await _localStorage.saveDish(dishData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã thêm món thành công (Offline)!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload dishes to reflect changes
      _loadDishes();
      
      // Optional: Sync to cloud if needed later
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete dish from wheel
  Future<void> _deleteDish(String dishId) async {
    try {
      // Check if it's a local dish (starts with 'local_') or has isLocal flag
      final isLocal = dishId.startsWith('local_') || 
                      _allDishes.any((d) => (d['_id'] == dishId || d['id'] == dishId) && d['isLocal'] == true);

      if (isLocal) {
        await _localStorage.deleteDish(dishId);
      } else {
        // API delete
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để xóa món Online')),
          );
          return;
        }
        final token = await user.getIdToken();
        await _apiService.deleteDish(dishId, token: token);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã xóa món thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload dishes
      _loadDishes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Rename dish
  Future<void> _renameDish(String dishId, String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        return;
      }

      // Get token
      final token = await user.getIdToken();
      
      // Call API to update
      await _apiService.updateDish(
        dishId,
        {'name': newName},
        token: token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã đổi tên món thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload dishes
      _loadDishes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterDishes() {
    List<Map<String, dynamic>> filtered = List.from(_allDishes);

    // Filter by meal time
    if (_selectedMealTime != null) {
      filtered = filtered.where((dish) {
        final mealType = (dish['mealType'] ?? '').toString().toLowerCase().trim();
        
        // Support multiple formats
        if (_selectedMealTime == 'breakfast') {
          return mealType == 'breakfast' || 
                 mealType == 'sáng' || 
                 mealType == 'sang' ||
                 mealType.contains('breakfast') ||
                 mealType.contains('sáng');
        } else if (_selectedMealTime == 'lunch') {
          return mealType == 'lunch' || 
                 mealType == 'trưa' || 
                 mealType == 'trua' ||
                 mealType.contains('lunch') ||
                 mealType.contains('trưa');
        } else if (_selectedMealTime == 'dinner') {
          return mealType == 'dinner' || 
                 mealType == 'tối' || 
                 mealType == 'toi' ||
                 mealType.contains('dinner') ||
                 mealType.contains('tối');
        }
        return mealType == _selectedMealTime;
      }).toList();
      
      print('🍽️ Filtered by mealType=$_selectedMealTime: ${filtered.length} dishes');
    }

    setState(() => _filteredDishes = filtered);
  }

  void _onDishResult(Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (context) => DishResultDialog(
        dish: dish,
        onViewDetails: () => _navigateToDishDetail(dish),
        onSpinAgain: () {
          // Dialog already popped by DishResultDialog
          // Just stay on this screen to spin again
        },
      ),
    );
  }

  void _navigateToDishDetail(Map<String, dynamic> dish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DishDetailScreen(dish: dish),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm Off-white / Beige
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFDFBF7), // Match background
        elevation: 0,
        scrolledUnderElevation: 0, // Tránh đổi màu khi scroll
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDishes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề chính
                    Center(
                      child: Text(
                        'Hôm nay ăn gì?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Meal time selector
                    MealTimeSelector(
                      selectedMealTime: _selectedMealTime,
                      onMealTimeChanged: (mealTime) {
                        setState(() {
                          _selectedMealTime = mealTime;
                          _filterDishes();
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Spin Wheel (centerpiece)
                    _selectedMealTime == null
                        ? Container(
                            height: 300,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chọn bữa ăn để bắt đầu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : DishSpinWheel(
                            dishes: _filteredDishes.isEmpty ? _allDishes : _filteredDishes,
                            onResult: _onDishResult,
                            onDeleteDish: _deleteDish,
                            onRenameDish: _renameDish,
                          ),

                    const SizedBox(height: 24),

                    // Suggestion Button
                    if (_selectedMealTime != null && _filteredDishes.isNotEmpty)
                      Center(
                        child: TextButton.icon(
                          onPressed: _showSuggestionSheet,
                          icon: const Icon(Icons.lightbulb_outline, size: 20),
                          label: const Text(
                            'Gợi ý 3 món ngẫu nhiên',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6B6B),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),

                    // Dishes count text (phụ, màu nhạt)
                    Center(
                      child: Text(
                        _filteredDishes.isEmpty && (_selectedMealTime != null)
                            ? 'Dùng tất cả ${_allDishes.length} món'
                            : 'Đang quay trong ${_filteredDishes.isEmpty ? _allDishes.length : _filteredDishes.length} món',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: (_selectedMealTime != null)
        ? FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddDishDialog(
                  onAdd: _addPersonalDish,
                  initialMealTime: _selectedMealTime,
                ),
              );
            },
            backgroundColor: const Color(0xFFFF6B6B),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null, // Hide if not filtered
    );
  }
}
