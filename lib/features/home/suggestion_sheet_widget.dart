import 'package:flutter/material.dart';
import 'dart:math';

class SuggestionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> dishes;

  const SuggestionSheet({super.key, required this.dishes});

  @override
  State<SuggestionSheet> createState() => _SuggestionSheetState();
}

class _SuggestionSheetState extends State<SuggestionSheet> {
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _randomize();
  }

  void _randomize() {
    if (widget.dishes.isEmpty) return;
    final random = Random();
    final List<Map<String, dynamic>> temp = List.from(widget.dishes);
    temp.shuffle(random);
    setState(() {
      _suggestions = temp.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dishes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Không có món nào để gợi ý!')),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💡 Gợi ý cho bạn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _randomize,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Đổi món khác'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._suggestions.map((dish) => ConfigurableDishCard(dish: dish)),
        ],
      ),
    );
  }
}

class ConfigurableDishCard extends StatelessWidget {
  final Map<String, dynamic> dish;

  const ConfigurableDishCard({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.pop(context); // Close sheet
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Gợi ý hay!'),
              content: Text('Bạn hãy thử món "${dish['name']}" xem sao nhé! 😋'),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                  child: const Text('Đồng ý'),
                )
              ],
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
          child: const Icon(Icons.restaurant, color: Color(0xFFFF6B6B), size: 20),
        ),
        title: Text(
          dish['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}
