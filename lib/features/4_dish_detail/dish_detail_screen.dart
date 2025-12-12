import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../3_menu_management/menu_management_api_provider.dart';

class DishDetailScreen extends StatefulWidget {
  final Map<String, dynamic> dish;

  const DishDetailScreen({super.key, required this.dish});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  bool _isTogglingFavorite = false;

  Future<void> _toggleFavorite() async {
    print('🔴 _toggleFavorite called');
    if (_isTogglingFavorite) {
      print('🔴 Already toggling, returning');
      return;
    }

    setState(() => _isTogglingFavorite = true);
    print('🔴 Set isToggling = true');

    try {
      final provider = Provider.of<MenuManagementApiProvider>(context, listen: false);
      final dishId = widget.dish['_id'] ?? widget.dish['id'];
      print('🔴 DishId: $dishId');
      
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Call API directly to toggle favorite
      print('🔴 Calling API toggleFavorite directly...');
      await provider.apiService.toggleFavorite(user.uid, dishId);
      print('🔴 API call successful');

      // Update local dish data
      final wasFavorite = widget.dish['isFavorite'] ?? false;
      widget.dish['isFavorite'] = !wasFavorite;

      // Reload provider's dish list to sync
      print('🔴 Reloading provider dishes...');
      await provider.loadDishes();
      print('🔴 Dishes reloaded');

      if (mounted) {
        final isFavorite = widget.dish['isFavorite'] ?? false;
        print('🔴 isFavorite after toggle: $isFavorite');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🔴 ERROR in toggleFavorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingFavorite = false);
        print('🔴 Set isToggling = false');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish['name'] ?? 'Chi tiết món ăn'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: widget.dish['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.dish['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
                    )
                  : _buildPlaceholder(),
            ),

            const SizedBox(height: 24),

            // Dish name
            Text(
              widget.dish['name'] ?? 'Món ngon',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Category & meal time
            Wrap(
              spacing: 8,
              children: [
                if (widget.dish['category'] != null)
                  Chip(
                    label: Text(widget.dish['category']),
                    backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.2),
                  ),
                if (widget.dish['mealTime'] != null)
                  Chip(
                    label: Text(widget.dish['mealTime']),
                    backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.2),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            if (widget.dish['description'] != null) ...[
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.dish['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],

            // Cooking info
            if (widget.dish['cookingTime'] != null || widget.dish['servings'] != null) ...{
              const SizedBox(height: 16),
              Row(
                children: [
                  if (widget.dish['cookingTime'] != null) ...[
                    const Icon(Icons.timer, size: 20, color: Color(0xFF4ECDC4)),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.dish['cookingTime']} phút',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (widget.dish['servings'] != null) ...[
                    const Icon(Icons.people, size: 20, color: Color(0xFF4ECDC4)),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.dish['servings']} người',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            },

            // Ingredients
            if (widget.dish['ingredients'] != null && (widget.dish['ingredients'] as List).isNotEmpty) ...{
              const SizedBox(height: 24),
              const Text(
                '🥗 Nguyên liệu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                (widget.dish['ingredients'] as List).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          (widget.dish['ingredients'] as List)[index],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            },

            // Cooking Instructions
            if (widget.dish['cookingInstructions'] != null && (widget.dish['cookingInstructions'] as List).isNotEmpty) ...{
              const SizedBox(height: 24),
              const Text(
                '👨‍🍳 Cách làm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                (widget.dish['cookingInstructions'] as List).length,
                (index) {
                  final instruction = (widget.dish['cookingInstructions'] as List)[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ECDC4),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${instruction['step']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (instruction['duration'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '⏱️ ${instruction['duration']} phút',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          instruction['instruction'],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        if (instruction['tips'] != null) ...{
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡 ', style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    instruction['tips'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber[900],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        },
                      ],
                    ),
                  );
                },
              ),
            },

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTogglingFavorite ? null : _toggleFavorite,
                    icon: _isTogglingFavorite
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            (widget.dish['isFavorite'] ?? false)
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                    label: Text(
                      (widget.dish['isFavorite'] ?? false)
                          ? 'Đã yêu thích'
                          : 'Yêu thích',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Share dish
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chức năng đang phát triển')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Chia sẻ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4ECDC4),
                      side: const BorderSide(
                        color: Color(0xFF4ECDC4),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: 80,
        color: Colors.grey[400],
      ),
    );
  }
}
