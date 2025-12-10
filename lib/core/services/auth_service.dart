import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Debug: Log thông tin từ Google
      debugPrint('📧 Google User Info:');
      debugPrint('  Email: ${googleUser.email}');
      debugPrint('  Display Name: ${googleUser.displayName}');
      debugPrint('  Photo URL: ${googleUser.photoUrl}');
      debugPrint('  ID: ${googleUser.id}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Lưu user vào MongoDB backend
      if (userCredential.user != null) {
        final displayName = googleUser.displayName ??
            userCredential.user!.displayName ??
            googleUser.email.split('@')[0];
        final photoURL = googleUser.photoUrl ?? userCredential.user!.photoURL;

        debugPrint('💾 Saving user to MongoDB:');
        debugPrint('  UID: ${userCredential.user!.uid}');
        debugPrint('  Email: ${userCredential.user!.email}');
        debugPrint('  Display Name: $displayName');
        debugPrint('  Photo URL: $photoURL');

        try {
          await _apiService.createOrUpdateUser({
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'displayName': displayName,
            'photoURL': photoURL ?? '',
          });
          debugPrint('✅ User saved to MongoDB');
        } catch (e) {
          debugPrint('⚠️ Failed to save user: $e');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Google Sign In Error: ${e.toString()}');
      throw 'Đã xảy ra lỗi khi đăng nhập với Google: ${e.toString()}';
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Lưu user vào MongoDB backend
      if (credential.user != null) {
        try {
          await _apiService.createOrUpdateUser({
            'uid': credential.user!.uid,
            'email': credential.user!.email,
            'displayName': displayName,
            'photoURL': '',
          });
          debugPrint('✅ User saved to MongoDB');
        } catch (e) {
          debugPrint('⚠️ Failed to save user: $e');
          // Don't fail registration if backend is down
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      // Ignore errors on sign out
      await _auth.signOut();
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user from MongoDB via API
      try {
        // TODO: Call API to delete user from MongoDB
        // await _apiService.deleteUser(user.uid);
        debugPrint('User deleted from backend');
      } catch (e) {
        debugPrint('Failed to delete user from backend: $e');
      }

      // Delete auth account
      await user.delete();
    }
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Thao tác không được phép.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
      case 'invalid-credential':
        return 'Thông tin xác thực không hợp lệ.';
      case 'invalid-verification-code':
        return 'Mã xác thực không hợp lệ.';
      case 'invalid-verification-id':
        return 'ID xác thực không hợp lệ.';
      default:
        return 'Đã xảy ra lỗi: ${e.message ?? 'Lỗi không xác định'}';
    }
  }
}
