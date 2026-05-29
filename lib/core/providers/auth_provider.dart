import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  // ─── Getters ──────────────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get userId => _user?.id;
  String? get userEmail => _user?.email;

  // ─── Init ─────────────────────────────────────────────────────────────────────

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _authService.currentUser;
    _status = _user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    _authSubscription = _authService.authStateChanges.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      debugPrint('Auth event: $event');

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          _user = session?.user;
          _status = AuthStatus.authenticated;
          _errorMessage = null;
          break;

        case AuthChangeEvent.signedOut:
          _user = null;
          _status = AuthStatus.unauthenticated;
          break;

        case AuthChangeEvent.passwordRecovery:
          // Handled separately
          break;

        case AuthChangeEvent.initialSession:
          _user = session?.user;
          _status = _user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated;
          break;

        default:
          break;
      }

      notifyListeners();
    });
  }

  // ─── Auth Actions ─────────────────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      username: username,
    );

    _setLoading(false);

    if (!result.success) {
      _setError(result.error!);
      return false;
    }

    // Supabase sends confirmation email — user stays unauthenticated
    // until they verify (depending on your project settings)
    return true;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (!result.success) {
      _setError(result.error!);
      return false;
    }

    return true;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithGoogle();

    _setLoading(false);

    if (!result.success && result.error != null) {
      _setError(result.error!);
      return false;
    }

    return true;
  }

  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithApple();

    _setLoading(false);

    if (!result.success && result.error != null) {
      _setError(result.error!);
      return false;
    }

    return true;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.sendPasswordResetEmail(email);

    _setLoading(false);

    if (!result.success) {
      _setError(result.error!);
      return false;
    }

    return true;
  }

  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.updatePassword(newPassword);

    _setLoading(false);

    if (!result.success) {
      _setError(result.error!);
      return false;
    }

    return true;
  }

  Future<bool> resendVerificationEmail(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.resendVerificationEmail(email);

    _setLoading(false);

    if (!result.success) {
      _setError(result.error!);
      return false;
    }

    return true;
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
