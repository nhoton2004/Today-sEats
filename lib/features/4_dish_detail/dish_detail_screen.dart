import 'package:flutter/material.dart';

class DishDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dish;

  const DishDetailScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dish['name'] ?? 'Chi tiết món ăn'),
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
              child: dish['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        dish['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
                    )
                  : _buildPlaceholder(),
            ),

            const SizedBox(height: 24),

            // Dish name
            Text(
              dish['name'] ?? 'Món ngon',
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
                if (dish['category'] != null)
                  Chip(
                    label: Text(dish['category']),
                    backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.2),
                  ),
                if (dish['mealTime'] != null)
                  Chip(
                    label: Text(dish['mealTime']),
                    backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.2),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            if (dish['description'] != null) ...[
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dish['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],

            // Cooking info
            if (dish['cookingTime'] != null || dish['servings'] != null) ...{
              const SizedBox(height: 16),
              Row(
                children: [
                  if (dish['cookingTime'] != null) ...[
                    const Icon(Icons.timer, size: 20, color: Color(0xFF4ECDC4)),
                    const SizedBox(width: 4),
                    Text(
                      '${dish['cookingTime']} phút',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (dish['servings'] != null) ...[
                    const Icon(Icons.people, size: 20, color: Color(0xFF4ECDC4)),
                    const SizedBox(width: 4),
                    Text(
                      '${dish['servings']} người',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            },

            // Ingredients
            if (dish['ingredients'] != null && (dish['ingredients'] as List).isNotEmpty) ...{
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
                (dish['ingredients'] as List).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          (dish['ingredients'] as List)[index],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            },

            // Cooking Instructions
            if (dish['cookingInstructions'] != null && (dish['cookingInstructions'] as List).isNotEmpty) ...{
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
                (dish['cookingInstructions'] as List).length,
                (index) {
                  final instruction = (dish['cookingInstructions'] as List)[index];
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
                    onPressed: () {
                      // TODO: Add to favorites
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm vào yêu thích')),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Yêu thích'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
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
