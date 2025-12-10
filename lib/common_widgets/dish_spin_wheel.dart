import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async';
import 'dart:math';

class DishSpinWheel extends StatefulWidget {
  final List<Map<String, dynamic>> dishes;
  final Function(Map<String, dynamic>) onResult;

  const DishSpinWheel({
    super.key,
    required this.dishes,
    required this.onResult,
  });

  @override
  State<DishSpinWheel> createState() => _DishSpinWheelState();
}

class _DishSpinWheelState extends State<DishSpinWheel> {
  final StreamController<int> _fortuneController = StreamController<int>();
  bool _isSpinning = false;

  @override
  void dispose() {
    _fortuneController.close();
    super.dispose();
  }

  void spin() {
    if (_isSpinning || widget.dishes.isEmpty) return;

    setState(() => _isSpinning = true);

    // IMPORTANT: Get display dishes first (max 8)
    final displayDishes = widget.dishes.take(8).toList();

    // Random from DISPLAY dishes only (not all dishes!)
    final randomIndex = Random().nextInt(displayDishes.length);

    // Spin to random dish
    _fortuneController.add(randomIndex);

    // After spin completes (3 seconds), show CORRECT result from displayDishes
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _isSpinning = false);
      // Return the dish from displayDishes, not widget.dishes!
      widget.onResult(displayDishes[randomIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có món ăn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Limit to max 8 dishes for better wheel display
    final displayDishes = widget.dishes.take(8).toList();

    return Column(
      children: [
        // Spin Wheel
        SizedBox(
          height: 300,
          child: FortuneWheel(
            selected: _fortuneController.stream,
            animateFirst: false,
            duration: const Duration(seconds: 3),
            indicators: const [
              FortuneIndicator(
                alignment: Alignment.topCenter,
                child: TriangleIndicator(
                  color: Colors.red,
                  width: 20.0,
                  height: 20.0,
                ),
              ),
            ],
            items: [
              for (var dish in displayDishes)
                FortuneItem(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji or icon for dish
                        Text(
                          _getDishEmoji(dish['category'] ?? ''),
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        // Dish name (truncated)
                        Text(
                          dish['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  style: FortuneItemStyle(
                    color: _getWheelColor(displayDishes.indexOf(dish)),
                    borderColor: Colors.white,
                    borderWidth: 2,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Spin Button
        GestureDetector(
          onTap: _isSpinning ? null : spin,
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSpinning
                    ? [Colors.grey[400]!, Colors.grey[500]!]
                    : [
                        const Color(0xFFFF6B6B),
                        const Color(0xFFFF8E8E),
                      ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isSpinning
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'QUAY',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  String _getDishEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'việt nam':
      case 'vietnamese':
        return '🍜';
      case 'châu á':
      case 'asian':
        return '🍱';
      case 'âu mỹ':
      case 'western':
        return '🍕';
      case 'khác':
      case 'other':
        return '🍽️';
      default:
        return '🍴';
    }
  }

  Color _getWheelColor(int index) {
    final colors = [
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFFF6B6B), // Coral
      const Color(0xFFFFA07A), // Light salmon
      const Color(0xFF98D8C8), // Mint
      const Color(0xFFFFBE76), // Orange
      const Color(0xFF9D84B7), // Purple
      const Color(0xFFFF9AA2), // Pink
      const Color(0xFFB5EAD7), // Light green
    ];
    return colors[index % colors.length];
  }
}
