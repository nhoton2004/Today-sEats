import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/auth_service.dart';
import '../../common_widgets/simple_form.dart';
import '../../common_widgets/touch_target.dart';

// Áp dụng các nguyên tắc thiết kế:
// - Nguyên tắc 6: Form đơn giản (chỉ 2 trường bắt buộc)
// - Nguyên tắc 9: Một nhiệm vụ - Đăng nhập
// - Nguyên tắc 3: Giao diện sạch sẽ, ngăn nắp
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.largePadding * 2),
              // Logo và tiêu đề - Nguyên tắc 3: Giao diện sạch sẽ
              Image.asset(
                'assets/images/logo.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppConstants.largePadding),
              const Text(
                'Đăng Nhập',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              const Text(
                'Chào mừng trở lại!',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largePadding * 2),

              // Form đơn giản - Nguyên tắc 6
              SimpleForm(
                formKey: _formKey,
                isLoading: _isLoading,
                submitButtonText: 'Đăng nhập',
                onSubmit: _handleLogin,
                children: [
                  SimpleTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'example@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  SimpleTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    suffixIcon: TouchIconButton(
                      icon: _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      tooltip:
                          _isPasswordVisible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/forgot-password'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                          AppConstants.minTouchTargetSize,
                          AppConstants.minTouchTargetSize,
                        ),
                      ),
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.largePadding),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: Text(
                      'Hoặc',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Nút Google Sign In - Nguyên tắc 2: Touch target đủ lớn
              SizedBox(
                height: AppConstants.buttonHeight,
                child: OutlinedButton(
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(
                          width: AppConstants.defaultIconSize,
                          height: AppConstants.defaultIconSize,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                AppConstants.smallPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.g_translate,
                                color: Color(0xFF4285F4),
                                size: AppConstants.smallIconSize,
                              ),
                            ),
                            const SizedBox(width: AppConstants.defaultPadding),
                            Text(
                              'Đăng nhập với Google',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Link đăng ký - Nguyên tắc 2: Touch target đủ lớn
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/register'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        AppConstants.minTouchTargetSize,
                        AppConstants.minTouchTargetSize,
                      ),
                    ),
                    child: Text(
                      'Đăng ký',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
