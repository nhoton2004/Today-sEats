import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../common_widgets/dish_spin_wheel.dart';
import '../../common_widgets/meal_time_selector.dart';
import '../../common_widgets/cuisine_chips.dart';
import '../../common_widgets/dish_result_dialog.dart';
import '../../common_widgets/add_dish_dialog.dart';
import '../4_dish_detail/dish_detail_screen.dart';

class SpinHomeScreen extends StatefulWidget {
  const SpinHomeScreen({super.key});

  @override
  State<SpinHomeScreen> createState() => _SpinHomeScreenState();
}

class _SpinHomeScreenState extends State<SpinHomeScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _allDishes = [];
  List<Map<String, dynamic>> _filteredDishes = [];
  bool _isLoading = true;
  String? _selectedMealTime;
  String? _selectedCuisine;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);
    try {
      // Get current user ID
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'anonymous';
      
      // Get global dishes + user's personal dishes
      final dishes = await _apiService.getAllDishesWithPersonal(
        userId: userId,
        limit: 50,
      );
      
      setState(() {
        _allDishes = dishes;
        _filterDishes();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dishes: $e');
      // Fallback to regular dishes if user dishes API fails
      try {
        final dishes = await _apiService.getDishes(limit: 50);
        setState(() {
          _allDishes = dishes;
          _filterDishes();
          _isLoading = false;
        });
      } catch (e2) {
        print('Fallback also failed: $e2');
        setState(() => _isLoading = false);
      }
    }
  }

  void _addPersonalDish(Map<String, dynamic> dishData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thêm món')),
        );
        return;
      }

      await _apiService.createPersonalDish(
        userId: user.uid,
        name: dishData['name'],
        description: dishData['description'],
        category: dishData['category'],
        mealType: dishData['mealType'],
        tags: dishData['tags'],
        ingredients: dishData['ingredients'],
        servings: dishData['servings'],
        cookingTime: dishData['cookingTime'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã thêm món thành công!'),
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
      if (filtered.isEmpty) {
        print('⚠️ No dishes match mealType filter. Available mealTypes:');
        _allDishes.take(5).forEach((dish) {
          print('   - ${dish['name']}: mealType="${dish['mealType']}"');
        });
      }
    }

    // Filter by cuisine (using tags)
    if (_selectedCuisine != null) {
      filtered = filtered.where((dish) {
        final tags = dish['tags'] as List?;
        if (tags != null) {
          // Map English cuisine values to Vietnamese tags
          String cuisineTag;
          if (_selectedCuisine == 'vietnamese') {
            cuisineTag = 'việt nam';
          } else if (_selectedCuisine == 'asian') {
            cuisineTag = 'châu á';
          } else if (_selectedCuisine == 'western') {
            cuisineTag = 'âu mỹ';
          } else {
            cuisineTag = _selectedCuisine!;
          }
          
          return tags.any((tag) => 
            tag.toString().toLowerCase().contains(cuisineTag.toLowerCase())
          );
        }
        return false;
      }).toList();
      
      print('🌍 Filtered by cuisine=$_selectedCuisine: ${filtered.length} dishes');
      if (filtered.isEmpty) {
        print('⚠️ No dishes match cuisine filter. Available tags:');
        _allDishes.take(5).forEach((dish) {
          print('   - ${dish['name']}: tags=${dish['tags']}');
        });
      }
    }

    setState(() => _filteredDishes = filtered);
  }

  String _getCuisineKeyword(String cuisine) {
    switch (cuisine) {
      case 'vietnamese':
        return 'việt';
      case 'asian':
        return 'châu á';
      case 'western':
        return 'âu';
      default:
        return cuisine;
    }
  }

  void _onDishResult(Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (context) => DishResultDialog(
        dish: dish,
        onViewDetails: () => _navigateToDishDetail(dish),
        onSpinAgain: () {
          // Dialog already closed, just need to spin again
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

  // Delete dish from wheel
  Future<void> _deleteDish(String dishId) async {
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
      
      // Call API to delete
      await _apiService.deleteDish(dishId, token: token);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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

                    // Cuisine filter chips
                    CuisineChips(
                      selectedCuisine: _selectedCuisine,
                      onCuisineChanged: (cuisine) {
                        setState(() {
                          _selectedCuisine = cuisine;
                          _filterDishes();
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Dishes count text (phụ, màu nhạt)
                    Center(
                      child: Text(
                        _filteredDishes.isEmpty && (_selectedMealTime != null || _selectedCuisine != null)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddDishDialog(
              onAdd: _addPersonalDish,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
    );
  }
}
