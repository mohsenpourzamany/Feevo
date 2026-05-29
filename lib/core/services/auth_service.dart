import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Result wrapper for auth operations
class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
  });

  factory AuthResult.ok(User user) => AuthResult(success: true, user: user);
  factory AuthResult.fail(String error) =>
      AuthResult(success: false, error: error);
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── Current User ────────────────────────────────────────────────────────────

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // ─── Email Auth ───────────────────────────────────────────────────────────────

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'username': username?.trim() ?? _generateUsername(fullName),
        },
      );

      if (response.user == null) {
        return AuthResult.fail('ثبت‌نام ناموفق بود. لطفاً دوباره امتحان کنید.');
      }

      // Create user profile in public.users table
      await _createUserProfile(
        userId: response.user!.id,
        email: email.trim(),
        fullName: fullName.trim(),
        username: username?.trim() ?? _generateUsername(fullName),
      );

      return AuthResult.ok(response.user!);
    } on AuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('SignUp error: $e');
      return AuthResult.fail('خطای غیرمنتظره. لطفاً دوباره امتحان کنید.');
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        return AuthResult.fail('ورود ناموفق بود.');
      }

      return AuthResult.ok(response.user!);
    } on AuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('SignIn error: $e');
      return AuthResult.fail('خطای غیرمنتظره. لطفاً دوباره امتحان کنید.');
    }
  }

  // ─── Google Sign In ───────────────────────────────────────────────────────────

  Future<AuthResult> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? null
            : 'music.feevo.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // OAuth redirect — result comes via deep link / authStateChanges
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('Google SignIn error: $e');
      return AuthResult.fail('ورود با Google ناموفق بود.');
    }
  }

  // ─── Apple Sign In ────────────────────────────────────────────────────────────

  Future<AuthResult> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb
            ? null
            : 'music.feevo.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('Apple SignIn error: $e');
      return AuthResult.fail('ورود با Apple ناموفق بود.');
    }
  }

  // ─── Password Reset ───────────────────────────────────────────────────────────

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'music.feevo.app://reset-password',
      );
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult.fail('ارسال ایمیل بازیابی ناموفق بود.');
    }
  }

  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('Update password error: $e');
      return AuthResult.fail('تغییر رمز عبور ناموفق بود.');
    }
  }

  // ─── Email Verification ───────────────────────────────────────────────────────

  Future<AuthResult> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
      return const AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult.fail(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.fail('ارسال مجدد ایمیل ناموفق بود.');
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('SignOut error: $e');
    }
  }

  // ─── Session ──────────────────────────────────────────────────────────────────

  Future<bool> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      return response.session != null;
    } catch (e) {
      debugPrint('Session refresh error: $e');
      return false;
    }
  }

  // ─── Profile Creation ─────────────────────────────────────────────────────────

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String username,
  }) async {
    try {
      await _supabase.from('users').upsert({
        'id': userId,
        'email': email,
        'name': fullName,
        'username': username,
        'is_premium': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Profile creation error: $e');
      // Non-fatal — profile can be created on first login too
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  String _generateUsername(String fullName) {
    final base = fullName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    final suffix = DateTime.now().millisecondsSinceEpoch % 10000;
    return '${base}_$suffix';
  }

  String _mapAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return 'ایمیل یا رمز عبور اشتباه است.';
    }
    if (msg.contains('email not confirmed')) {
      return 'لطفاً ابتدا ایمیل خود را تأیید کنید.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'این ایمیل قبلاً ثبت شده است.';
    }
    if (msg.contains('password should be at least')) {
      return 'رمز عبور باید حداقل ۶ کاراکتر باشد.';
    }
    if (msg.contains('rate limit')) {
      return 'تعداد درخواست‌ها زیاد است. کمی صبر کنید.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'خطای اتصال به اینترنت.';
    }
    return 'خطا: $message';
  }
}
