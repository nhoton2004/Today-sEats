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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildCuisineChip(
          emoji: '🇻🇳',
          label: 'Việt Nam',
          value: 'vietnamese',
          isSelected: selectedCuisine == 'vietnamese',
        ),
        _buildCuisineChip(
          emoji: '🌏',
          label: 'Châu Á',
          value: 'asian',
          isSelected: selectedCuisine == 'asian',
        ),
        _buildCuisineChip(
          emoji: '🌍',
          label: 'Âu Mỹ',
          value: 'western',
          isSelected: selectedCuisine == 'western',
        ),
      ],
    );
  }

  Widget _buildCuisineChip({
    required String emoji,
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onCuisineChanged(isSelected ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B6B).withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
