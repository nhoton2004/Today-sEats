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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label nhóm
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'BỮA ĂN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.grey[700],
            ),
          ),
        ),
        
        // Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMealChip(
              icon: Icons.wb_sunny,
              label: 'Sáng',
              value: 'breakfast',
            ),
            _buildMealChip(
              icon: Icons.wb_sunny_outlined,
              label: 'Trưa',
              value: 'lunch',
            ),
            _buildMealChip(
              icon: Icons.nightlight,
              label: 'Tối',
              value: 'dinner',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = selectedMealTime == value;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onMealTimeChanged(selected ? value : null);
      },
      selectedColor: const Color(0xFFFF6B6B).withOpacity(0.15),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[700],
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 0,
      pressElevation: 0,
    );
  }
}
