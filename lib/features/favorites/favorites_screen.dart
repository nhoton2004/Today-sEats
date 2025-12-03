import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../common_widgets/custom_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Map<String, dynamic>> _favoriteDishes = [
    {
      'name': 'Phở Bò',
      'category': 'Món chính',
      'image': 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
      'rating': 4.8,
    },
    {
      'name': 'Bún Chả',
      'category': 'Món chính',
      'image': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
      'rating': 4.6,
    },
    {
      'name': 'Bánh Mì',
      'category': 'Món ăn sáng',
      'image': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400',
      'rating': 4.7,
    },
  ];

  void _removeFavorite(int index) {
    setState(() {
      _favoriteDishes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa khỏi danh sách yêu thích'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Món Yêu Thích',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_favoriteDishes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Implement filter/sort functionality
              },
            ),
        ],
      ),
      body: _favoriteDishes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có món yêu thích',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Thêm món ăn vào danh sách yêu thích để xem tại đây',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteDishes.length,
              itemBuilder: (context, index) {
                final dish = _favoriteDishes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFavoriteCard(dish, index),
                );
              },
            ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> dish, int index) {
    return CustomCard(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to dish detail
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  dish['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish['category'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dish['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () => _removeFavorite(index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
