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
        final mealType = (dish['mealType'] ?? '').toString().toLowerCase();
        return mealType == _selectedMealTime; // Exact match
      }).toList();
      
      print('🍽️ Filtered by mealType=$_selectedMealTime: ${filtered.length} dishes');
    }

    // Filter by cuisine (using tags)
    if (_selectedCuisine != null) {
      filtered = filtered.where((dish) {
        final tags = dish['tags'] as List?;
        if (tags != null) {
          return tags.any((tag) => 
            tag.toString().toLowerCase().contains(_selectedCuisine!)
          );
        }
        return false;
      }).toList();
      
      print('🌍 Filtered by cuisine=$_selectedCuisine: ${filtered.length} dishes');
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Greeting text
                    const Text(
                      '🎯 Hôm nay ăn gì? 🎯',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4ECDC4),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                    DishSpinWheel(
                      dishes: _filteredDishes.isEmpty ? _allDishes : _filteredDishes,
                      onResult: _onDishResult,
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

                    const SizedBox(height: 16),

                    // Dishes count text
                    Text(
                      _filteredDishes.isEmpty && (_selectedMealTime != null || _selectedCuisine != null)
                          ? 'Dùng tất cả ${_allDishes.length} món'
                          : 'Đang quay trong ${_filteredDishes.isEmpty ? _allDishes.length : _filteredDishes.length} món',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
