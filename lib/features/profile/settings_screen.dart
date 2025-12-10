import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/theme_provider.dart';
import '../../common_widgets/custom_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  String _language = 'vi';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Thông báo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Thông báo đẩy'),
                  subtitle: const Text('Nhận thông báo về món ăn mới'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Thông báo Email'),
                  subtitle: const Text('Nhận email về cập nhật'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Giao diện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Chế độ tối'),
                  subtitle: Text(isDarkMode ? 'Đang bật' : 'Đang tắt'),
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primary,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Ngôn ngữ'),
                  subtitle: const Text('Tiếng Việt'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bảo mật',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fingerprint, color: AppColors.primary),
                  title: const Text('Sinh trắc học'),
                  subtitle: const Text('Vân tay / Face ID'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Configure biometric authentication
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Dữ liệu & Bộ nhớ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined, color: AppColors.primary),
                  title: const Text('Tải về tự động'),
                  subtitle: const Text('Khi dùng Wi-Fi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Configure auto download
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.primary),
                  title: const Text('Xóa bộ nhớ cache'),
                  subtitle: const Text('Giải phóng dung lượng'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showClearCacheDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ nhớ cache'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả dữ liệu cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa bộ nhớ cache')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
