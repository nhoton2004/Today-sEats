import 'package:flutter/material.dart';

class MealTimeSelector extends StatelessWidget {
  final String? selectedMealTime;
  final Function(String?) onMealTimeChanged;

  const MealTimeSelector({
    super.key,
    required this.selectedMealTime,
    required this.onMealTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMealTimeButton(
          icon: Icons.wb_sunny,
          label: 'Sáng',
          value: 'breakfast',
          isSelected: selectedMealTime == 'breakfast',
        ),
        const SizedBox(width: 12),
        _buildMealTimeButton(
          icon: Icons.wb_sunny_outlined,
          label: 'Trưa',
          value: 'lunch',
          isSelected: selectedMealTime == 'lunch',
        ),
        const SizedBox(width: 12),
        _buildMealTimeButton(
          icon: Icons.nightlight,
          label: 'Tối',
          value: 'dinner',
          isSelected: selectedMealTime == 'dinner',
        ),
      ],
    );
  }

  Widget _buildMealTimeButton({
    required IconData icon,
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onMealTimeChanged(isSelected ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4ECDC4).withOpacity(0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
