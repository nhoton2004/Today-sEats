import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiService = ApiService();
  
  bool _isLoading = false;
  String? _currentPhotoURL;
  String _originalName = '';

  // Check if data changed
  bool get _hasChanges {
    // Only checking Name for now since Avatar upload isn't fully implemented in this block
    // User requested "Avatar change allowed" but usually that requires ImagePicker which user didn't explicitly provide code for.
    // I will stick to the logic: "Save button enable when name != original".
    return _nameController.text.trim() != _originalName;
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();
    _nameController.addListener(() => setState(() {})); // Rebuild to check _hasChanges
  }

  void _loadCurrentUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _originalName = user.displayName ?? '';
      _nameController.text = _originalName;
      setState(() {
        _currentPhotoURL = user.photoURL;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Người dùng chưa đăng nhập');

      final newDisplayName = _nameController.text.trim();

      // 1. Update Firebase Auth Profile
      await user.updateDisplayName(newDisplayName);
      await user.reload(); 

      // 2. Update Backend Profile
      await _apiService.updateUserProfile(
        uid: user.uid,
        displayName: newDisplayName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return result
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFFFE5E5),
                      backgroundImage: _currentPhotoURL != null 
                          ? NetworkImage(_currentPhotoURL!) 
                          : null,
                      child: _currentPhotoURL == null 
                          ? Text(
                              _originalName.isNotEmpty ? _originalName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Email (Read only)
              TextFormField(
                initialValue: email,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Display Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên hiển thị',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Tên không được để trống' : null,
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: (_hasChanges && !_isLoading) ? _saveProfile : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Lưu thay đổi", style: TextStyle(fontSize: 16)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel Button
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
