import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EditDishDialog extends StatefulWidget {
  final Map<String, dynamic> dish;

  const EditDishDialog({super.key, required this.dish});

  @override
  State<EditDishDialog> createState() => _EditDishDialogState();
}

class _EditDishDialogState extends State<EditDishDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _priceController;

  late String _selectedCategory;
  late String _selectedMealType;
  late String _selectedStatus;

  final List<String> _categories = [
    'main',
    'appetizer',
    'dessert',
    'drink',
    'soup',
  ];

  final Map<String, String> _categoryLabels = {
    'main': 'Món chính',
    'appetizer': 'Món khai vị',
    'dessert': 'Tráng miệng',
    'drink': 'Đồ uống',
    'soup': 'Món súp',
  };

  final List<String> _mealTypes = [
    'breakfast',
    'lunch',
    'dinner',
  ];

  final Map<String, String> _mealTypeLabels = {
    'breakfast': 'Sáng',
    'lunch': 'Trưa',
    'dinner': 'Tối',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dish['name'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.dish['description'] ?? '');
    _imageUrlController =
        TextEditingController(text: widget.dish['imageUrl'] ?? '');
    _priceController = TextEditingController(
        text: widget.dish['price']?.toString() ?? '0');

    _selectedCategory = widget.dish['category'] ?? 'main';
    _selectedMealType = widget.dish['mealType'] ?? 'breakfast';
    _selectedStatus = widget.dish['status'] ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final result = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
      'category': _selectedCategory,
      'mealType': _selectedMealType,
      'status': _selectedStatus,
      'price': _priceController.text.isNotEmpty
          ? double.tryParse(_priceController.text) ?? 0
          : 0,
    };

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chỉnh sửa món ăn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên món
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên món *',
                          hintText: 'Nhập tên món ăn',
                          prefixIcon: const Icon(Icons.restaurant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên món';
                          }
                          if (value.trim().length < 2) {
                            return 'Tên món phải có ít nhất 2 ký tự';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 16),

                      // Mô tả
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          hintText: 'Mô tả món ăn',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // URL hình ảnh
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL hình ảnh',
                          hintText: 'https://example.com/image.jpg',
                          prefixIcon: const Icon(Icons.image),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),

                      const SizedBox(height: 16),

                      // Giá
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Giá (VNĐ)',
                          hintText: '0',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_categoryLabels[category] ?? category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Meal Type
                      DropdownButtonFormField<String>(
                        value: _selectedMealType,
                        decoration: InputDecoration(
                          labelText: 'Bữa ăn',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _mealTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_mealTypeLabels[type] ?? type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedMealType = value);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Trạng thái',
                          prefixIcon: const Icon(Icons.toggle_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Hoạt động'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Ngưng hoạt động'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
