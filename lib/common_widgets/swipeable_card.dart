import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

// Nguyên tắc 5: Sử dụng điều khiển cảm ứng hợp lý
// Hỗ trợ vuốt trái/phải với feedback rõ ràng
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final Color? leftSwipeColor;
  final Color? rightSwipeColor;
  final IconData? leftSwipeIcon;
  final IconData? rightSwipeIcon;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftSwipeColor = Colors.red,
    this.rightSwipeColor = Colors.green,
    this.leftSwipeIcon = Icons.delete,
    this.rightSwipeIcon = Icons.favorite,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _dragExtent = 0;
  bool _dragUnderway = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: AppConstants.mediumAnimationDuration,
      ),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    setState(() {});
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;

    final delta = details.primaryDelta ?? 0;
    _dragExtent += delta;

    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;

    _dragUnderway = false;

    // Kiểm tra ngưỡng vuốt (AppConstants.swipeThreshold = 50dp)
    if (_dragExtent.abs() > AppConstants.swipeThreshold) {
      final velocity = details.primaryVelocity ?? 0;

      if (_dragExtent < 0 && widget.onSwipeLeft != null) {
        // Vuốt trái
        _controller.forward().then((_) {
          widget.onSwipeLeft!();
          _reset();
        });
      } else if (_dragExtent > 0 && widget.onSwipeRight != null) {
        // Vuốt phải
        _controller.forward().then((_) {
          widget.onSwipeRight!();
          _reset();
        });
      } else {
        _reset();
      }
    } else {
      _reset();
    }
  }

  void _reset() {
    setState(() {
      _dragExtent = 0;
      _controller.reset();
    });
  }

  Color _getBackgroundColor() {
    if (_dragExtent > 0) {
      return widget.rightSwipeColor!;
    } else if (_dragExtent < 0) {
      return widget.leftSwipeColor!;
    }
    return Colors.transparent;
  }

  IconData? _getIcon() {
    if (_dragExtent > AppConstants.swipeThreshold) {
      return widget.rightSwipeIcon;
    } else if (_dragExtent < -AppConstants.swipeThreshold) {
      return widget.leftSwipeIcon;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background với icon
          AnimatedContainer(
            duration: const Duration(
              milliseconds: AppConstants.shortAnimationDuration,
            ),
            color: _getBackgroundColor(),
            child: _getIcon() != null
                ? Align(
                    alignment: _dragExtent > 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.largePadding,
                      ),
                      child: Icon(
                        _getIcon(),
                        color: Colors.white,
                        size: AppConstants.largeIconSize,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Card chính
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
