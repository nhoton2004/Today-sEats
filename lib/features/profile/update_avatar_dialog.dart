import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/upload_service.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/error_handler.dart';
import '../../core/constants/app_colors.dart';

class UpdateAvatarDialog extends StatefulWidget {
  final String? currentAvatarUrl;

  const UpdateAvatarDialog({super.key, this.currentAvatarUrl});

  @override
  State<UpdateAvatarDialog> createState() => _UpdateAvatarDialogState();
}

class _UpdateAvatarDialogState extends State<UpdateAvatarDialog> {
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();
  final ApiService _apiService = ApiService();

  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, error: e);
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, error: e);
      }
    }
  }

  Future<void> _uploadAndUpdateAvatar() async {
    if (_selectedImage == null) {
      ErrorHandler.showWarning(
        context,
        message: 'Vui lòng chọn ảnh trước',
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload image to storage (S3/Cloudinary/Backend)
      final uploadResult = await _uploadService.uploadImage(_selectedImage!);
      final avatarUrl = uploadResult['url'] as String;

      // 2. Update user profile in MongoDB
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      await _apiService.updateUserProfile(user.uid, {
        'photoURL': avatarUrl,
      });

      // 3. Update Firebase Auth profile (optional, for consistency)
      await user.updatePhotoURL(avatarUrl);

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          message: 'Cập nhật avatar thành công!',
        );

        // Return success with new URL
        Navigator.pop(context, avatarUrl);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          error: e,
          onRetry: () => _uploadAndUpdateAvatar(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
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
                  const Icon(Icons.camera_alt, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Đổi ảnh đại diện',
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Preview
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBackground,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : (widget.currentAvatarUrl != null &&
                                    widget.currentAvatarUrl!.isNotEmpty)
                                ? Image.network(
                                    widget.currentAvatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 100,
                                        color: AppColors.textSecondary,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 100,
                                    color: AppColors.textSecondary,
                                  ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Pick from gallery
                    OutlinedButton.icon(
                      onPressed: _isUploading ? null : _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Chọn từ thư viện'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Take photo
                    OutlinedButton.icon(
                      onPressed: _isUploading ? null : _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Chụp ảnh mới'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Ảnh mới đã chọn ✓',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
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
                      onPressed: _isUploading ? null : () => Navigator.pop(context),
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
                      onPressed: _isUploading ? null : _uploadAndUpdateAvatar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Lưu avatar'),
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
