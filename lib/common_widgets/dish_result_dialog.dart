import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class DishResultDialog extends StatefulWidget {
  final Map<String, dynamic> dish;
  final VoidCallback onViewDetails;
  final VoidCallback onSpinAgain;

  const DishResultDialog({
    super.key,
    required this.dish,
    required this.onViewDetails,
    required this.onSpinAgain,
  });

  @override
  State<DishResultDialog> createState() => _DishResultDialogState();
}

class _DishResultDialogState extends State<DishResultDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    // Start confetti immediately
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Dialog content
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: Color(0xFF4ECDC4),
                  ),
                ),

                const SizedBox(height: 16),

                // "Bạn nên ăn" text
                const Text(
                  '🎉 Hôm nay ăn gì? 🎉',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4ECDC4),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Dish image placeholder
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: widget.dish['imageUrl'] != null
                      ? ClipRoundedRectangle(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.dish['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        )
                      : _buildPlaceholder(),
                ),

                const SizedBox(height: 16),

                // Dish name
                Text(
                  widget.dish['name'] ?? 'Món ngon',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Dish description
                if (widget.dish['description'] != null)
                  Text(
                    widget.dish['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onSpinAgain();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6B6B),
                          side: const BorderSide(
                            color: Color(0xFFFF6B6B),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Quay lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onViewDetails();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Confetti
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: 3.14 / 2, // Down
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.1,
          colors: const [
            Color(0xFF4ECDC4),
            Color(0xFFFF6B6B),
            Color(0xFFFFA07A),
            Color(0xFF98D8C8),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: 64,
        color: Colors.grey[400],
      ),
    );
  }
}

class ClipRoundedRectangle extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRoundedRectangle({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}
