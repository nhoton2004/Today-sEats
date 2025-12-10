import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddDishDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddDishDialog({super.key, required this.onAdd});

  @override
  State<AddDishDialog> createState() => _AddDishDialogState();
}

class _AddDishDialogState extends State<AddDishDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
  String _mealType = 'lunch';
  String _category = 'Món chính';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dish = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'mealType': _mealType,
        'category': _category,
        'tags': <String>[], // Explicitly type as List<String>
        'ingredients': <String>[], // Explicitly type as List<String>
        'servings': 2,
        'cookingTime': 30,
      };
      
      widget.onAdd(dish);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Thêm món mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên món *',
                  hintText: 'VD: Phở bò',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên món';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả ngắn về món ăn',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Meal Type dropdown
              DropdownButtonFormField<String>(
                value: _mealType,
                decoration: const InputDecoration(
                  labelText: 'Bữa ăn',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'breakfast', child: Text('🌅 Sáng')),
                  DropdownMenuItem(value: 'lunch', child: Text('☀️ Trưa')),
                  DropdownMenuItem(value: 'dinner', child: Text('🌙 Tối')),
                  DropdownMenuItem(value: 'snack', child: Text('🍪 Ăn vặt')),
                ],
                onChanged: (value) {
                  setState(() => _mealType = value!);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Món chính', child: Text('Món chính')),
                  DropdownMenuItem(value: 'Món phụ', child: Text('Món phụ')),
                  DropdownMenuItem(value: 'Đồ uống', child: Text('Đồ uống')),
                  DropdownMenuItem(value: 'Tráng miệng', child: Text('Tráng miệng')),
                  DropdownMenuItem(value: 'Bánh/Bánh mì', child: Text('Bánh/Bánh mì')),
                  DropdownMenuItem(value: 'Món ăn vặt', child: Text('Món ăn vặt')),
                ],
                onChanged: (value) {
                  setState(() => _category = value!);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
