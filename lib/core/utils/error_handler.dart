import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';

/// Centralized error handler for the app
/// Provides user-friendly error messages and retry suggestions
class ErrorHandler {
  /// Show error SnackBar with appropriate message and action
  static void showError(
    BuildContext context, {
    required dynamic error,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final errorMessage = _getUserFriendlyMessage(error, customMessage);
    final suggestion = _getErrorSuggestion(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorMessage,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (suggestion != null) ...[
              const SizedBox(height: 4),
              Text(
                suggestion,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success SnackBar
  static void showSuccess(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show warning SnackBar
  static void showWarning(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show loading dialog
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Get user-friendly error message
  static String _getUserFriendlyMessage(dynamic error, String? customMessage) {
    if (customMessage != null) return customMessage;

    final errorString = error.toString();

    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _getFirebaseAuthMessage(error);
    }

    // HTTP Status Code errors (API errors)
    if (errorString.contains('400') || errorString.contains('Bad Request')) {
      return 'Dữ liệu không hợp lệ, vui lòng kiểm tra lại';
    }

    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Phiên đăng nhập đã hết hạn';
    }

    if (errorString.contains('403') || errorString.contains('Forbidden')) {
      return 'Bạn không có quyền thực hiện chức năng này';
    }

    if (errorString.contains('404') || errorString.contains('Not Found')) {
      return 'Không tìm thấy dữ liệu';
    }

    if (errorString.contains('500') || errorString.contains('Internal Server')) {
      return 'Lỗi hệ thống, vui lòng thử lại sau';
    }

    // Network errors
    if (errorString.contains('SocketException') ||
        errorString.contains('Network') ||
        errorString.contains('Failed host lookup')) {
      return 'Không có kết nối mạng';
    }

    // Timeout errors
    if (errorString.contains('TimeoutException') ||
        errorString.contains('timeout')) {
      return 'Kết nối quá lâu, vui lòng thử lại';
    }

    // API errors
    if (errorString.contains('Failed to load') ||
        errorString.contains('Failed to')) {
      return 'Không thể kết nối đến máy chủ';
    }

    // Default message
    return 'Đã xảy ra lỗi: $errorString';
  }

  /// Get Firebase Auth specific messages
  static String _getFirebaseAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Kiểm tra kết nối của bạn';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này';
      default:
        return 'Lỗi đăng nhập: ${error.message ?? error.code}';
    }
  }

  /// Get error suggestion based on error type
  static String? _getErrorSuggestion(dynamic error) {
    final errorString = error.toString();

    // HTTP Status Code specific suggestions
    if (errorString.contains('400') || errorString.contains('Bad Request')) {
      return '💡 Kiểm tra lại thông tin đã nhập';
    }

    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return '💡 Vui lòng đăng nhập lại';
    }

    if (errorString.contains('403') || errorString.contains('Forbidden')) {
      return '💡 Liên hệ quản trị viên để được cấp quyền';
    }

    if (errorString.contains('404') || errorString.contains('Not Found')) {
      return '💡 Dữ liệu có thể đã bị xóa hoặc không tồn tại';
    }

    if (errorString.contains('500') || errorString.contains('Internal Server')) {
      return '💡 Máy chủ đang gặp sự cố, vui lòng thử lại sau';
    }

    // Network errors
    if (errorString.contains('SocketException') ||
        errorString.contains('Network') ||
        errorString.contains('Failed host lookup')) {
      return '💡 Kiểm tra kết nối mạng của bạn';
    }

    // Timeout errors
    if (errorString.contains('TimeoutException') ||
        errorString.contains('timeout')) {
      return '💡 Kiểm tra kết nối mạng hoặc thử lại';
    }

    // Auth errors
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
          return '💡 Kiểm tra lại email và mật khẩu';
        case 'too-many-requests':
          return '💡 Đợi vài phút rồi thử lại';
        case 'network-request-failed':
          return '💡 Bật Wi-Fi hoặc dữ liệu di động';
        case 'email-already-in-use':
          return '💡 Thử đăng nhập thay vì đăng ký';
        default:
          return null;
      }
    }

    return null;
  }

  /// Log error (for debugging)
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('❌ Error in $context: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
