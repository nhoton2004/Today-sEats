import 'package:flutter/material.dart';
import 'dart:math';

class DishSpinWheel extends StatefulWidget {
  final List<Map<String, dynamic>> dishes;
  final Function(Map<String, dynamic>) onResult;
  final Function(String dishId, String newName)? onRenameDish;
  final Function(String dishId)? onDeleteDish;

  const DishSpinWheel({
    super.key,
    required this.dishes,
    required this.onResult,
    this.onRenameDish,
    this.onDeleteDish,
  });

  @override
  State<DishSpinWheel> createState() => _DishSpinWheelState();
}

class _DishSpinWheelState extends State<DishSpinWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0.0;
  bool _isSpinning = false;
  int? _displayIndexCount; // Limit to 8 items

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
    
    _controller.addListener(() {
      setState(() {
         // Update rotation based on animation value
         // We'll calculate total rotation in spin() and animate to 1.0
      });
    });
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        // Correct rotation mod 2pi
        _currentRotation = _animation.value % (2 * pi); // Use the final value of the animation
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {
    if (_isSpinning || widget.dishes.length < 2) return;

    setState(() => _isSpinning = true);

    // 1. Setup data
    final displayDishes = widget.dishes.take(8).toList();
    _displayIndexCount = displayDishes.length;
    
    // 2. Select random target
    final random = Random();
    final targetIndex = random.nextInt(displayDishes.length);

    // 3. Calculate Rotation
    // Angle per item
    final sweepAngle = 2 * pi / displayDishes.length;
    
    // We want the target slice CENTER to align with -pi/2 (Top) at the end.
    // In Painter: Angle = (Rotation - pi/2) + R_slice
    // R_slice_center = (index + 0.5) * sweep
    // Final Angle of Center = Rotation_end - pi/2 + (index + 0.5)*sweep
    // We want Final Angle to be -pi/2 (Top)
    
    // => Rotation_end - pi/2 + (index+0.5)*sweep = -pi/2 + K*2pi
    // => Rotation_end = -(index + 0.5)*sweep + K*2pi
    
    double start = _currentRotation;
    double minSpin = 10 * pi;
    double baseTarget = -((targetIndex + 0.5) * sweepAngle);
    
    // Find next K such that baseTarget > start + minSpin
    while (baseTarget <= start + minSpin) {
      baseTarget += 2 * pi;
    }
    
    // Animate
    _animation = Tween<double>(begin: start, end: baseTarget).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
    );
    
    _controller.reset();
    _controller.forward().then((_) {
      // Animation done
      _currentRotation = baseTarget;
       widget.onResult(displayDishes[targetIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dishes.length < 2) {
      return _buildEmptyState();
    }

    final displayDishes = widget.dishes.take(8).toList();

    return Column(
      children: [
        GestureDetector(
          onLongPress: () => _showDishManagementSheet(context, displayDishes),
          child: Center(
            child: SizedBox.square(
              dimension: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Custom Wheel Painter
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(320, 320),
                        painter: DishWheelPainter(
                          items: displayDishes,
                          rotation: _animation.value,
                        ),
                      );
                    },
                  ),
                  
                  // 2. Pointer (Triangle at Top)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.rotate(
                      angle: pi, // Point down
                      child: const Icon(
                        Icons.arrow_drop_up, 
                        size: 50,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                  
                  // 3. Center Button/Decor
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF6B6B), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(Icons.star, color: Color(0xFFFF6B6B), size: 30),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Spin Button
        GestureDetector(
          onTap: _isSpinning ? null : spin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 220,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSpinning
                    ? [Colors.grey[400]!, Colors.grey[500]!]
                    : [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: _isSpinning
                  ? []
                  : [
                      BoxShadow(
                         color: const Color(0xFFFF6B6B).withOpacity(0.4),
                         blurRadius: 12,
                         offset: const Offset(0, 6),
                      )
                    ],
            ),
            child: Center(
              child: _isSpinning
                  ? const SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      'QUAY NGAY!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
     return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.dishes.isEmpty ? Icons.restaurant : Icons.warning_amber_rounded,
              size: 64, 
              color: Colors.grey[400]
            ),
            const SizedBox(height: 16),
            Text(
              widget.dishes.isEmpty 
                ? 'Không có món ăn'
                : 'Cần ít nhất 2 món để quay\nVui lòng thêm món hoặc bỏ bộ lọc',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
     );
  }
  
  // Helper giữ lại để dùng cho List (nếu cần), nhưng ko dùng trong Wheel nữa
  // Có thể xóa nếu không dùng ở _showDishManagementSheet
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

  // Show bottom sheet for dish management
  void _showDishManagementSheet(BuildContext context, List<Map<String, dynamic>> dishes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Quản lý món ăn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            // Dish list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (index % 2 == 0) ? const Color(0xFFFF6B6B) : const Color(0xFFFDFBF7),
                      child: Text(
                        _getDishEmoji(dish['category'] ?? ''),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      dish['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(dish['category'] ?? ''),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text('Sửa tên'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _showRenameDialog(context, dish);
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _showDeleteConfirmDialog(context, dish);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show rename dialog
  void _showRenameDialog(BuildContext context, Map<String, dynamic> dish) {
    final controller = TextEditingController(text: dish['name'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tên món ăn'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tên mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                widget.onRenameDish?.call(
                  dish['_id'] ?? dish['id'],
                  controller.text.trim(),
                );
                Navigator.pop(context);
                Navigator.pop(context); // Close bottom sheet
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmDialog(BuildContext context, Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa món ăn'),
        content: Text('Bạn có chắc muốn xóa "${dish['name']}" khỏi vòng quay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              widget.onDeleteDish?.call(dish['_id'] ?? dish['id']);
              Navigator.pop(context);
              Navigator.pop(context); // Close bottom sheet
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class DishWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  final double rotation;

  DishWheelPainter({required this.items, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final count = items.length;
    final sweepAngle = 2 * pi / count;

    // Paints
    final paintFill = Paint()..style = PaintingStyle.fill;
    final paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0;

    for (int i = 0; i < count; i++) {
      // Start from -pi/2 (Top/12 o'clock)
      final startAngle = (rotation - pi / 2) + (i * sweepAngle);
      
      // 1. Draw Slice
      paintFill.color = _getSliceColor(i);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true, // useCenter
        paintFill,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paintBorder,
      );

      // 2. Draw Text
      // Calculate mid angle for text
      final midAngle = startAngle + (sweepAngle / 2);
      
      canvas.save();
      // Translate to center
      canvas.translate(center.dx, center.dy);
      // Rotate to align with slice
      canvas.rotate(midAngle);
      
      // Prepare Text
      final String text = items[i]['name'] ?? '';
      final textStyle = TextStyle(
        color: _getTextColor(i), 
        fontSize: 14, 
        fontWeight: FontWeight.w900,
        height: 1.2,
      );
      
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 2, // Allow 2 lines for longer names
        textAlign: TextAlign.right,
        ellipsis: '...',
      );
      
      // Layout text
      // Max width is radius - some padding (e.g. 60 units from center + 20 margin)
      final maxTextWidth = radius * 0.55; // Reduced to leave margin at edge
      textPainter.layout(maxWidth: maxTextWidth);
      
      // Draw at offset
      // X: Start at some distance from center (e.g. 40)
      // Y: Center vertically
      final distance = radius * 0.35; // Position text 
      
      textPainter.paint(
        canvas, 
        Offset(distance + (maxTextWidth - textPainter.width), -textPainter.height / 2) // Align right
      );
      
      canvas.restore();
    }
  }

  Color _getSliceColor(int index) {
    switch (index % 3) {
      case 0:
        return const Color(0xFFFF6B6B); // Primary (Đỏ cam)
      case 1:
        return Colors.white; // Trắng
      default:
        return const Color(0xFFFFE5E5); // Hồng cực nhạt
    }
  }
  
  Color _getTextColor(int index) {
    if (index % 3 == 0) return Colors.white; // Trên nền đỏ
    return Colors.grey[900]!; // Trên nền trắng/hồng nhạt
  }

  @override
  bool shouldRepaint(covariant DishWheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.items != items;
  }
}
