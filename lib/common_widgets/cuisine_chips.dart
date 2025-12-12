import 'package:flutter/material.dart';

class CuisineChips extends StatelessWidget {
  final String? selectedCuisine;
  final Function(String?) onCuisineChanged;

  const CuisineChips({
    super.key,
    required this.selectedCuisine,
    required this.onCuisineChanged,
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
            'ẨM THỰC',
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
            _buildCuisineChip(
              emoji: '🇻🇳',
              label: 'Việt Nam',
              value: 'vietnamese',
            ),
            _buildCuisineChip(
              emoji: '🌏',
              label: 'Châu Á',
              value: 'asian',
            ),
            _buildCuisineChip(
              emoji: '🌍',
              label: 'Âu Mỹ',
              value: 'western',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCuisineChip({
    required String emoji,
    required String label,
    required String value,
  }) {
    final isSelected = selectedCuisine == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onCuisineChanged(selected ? value : null);
      },
      selectedColor: const Color(0xFFFF6B6B).withOpacity(0.15),
      backgroundColor: Colors.grey[50],
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
