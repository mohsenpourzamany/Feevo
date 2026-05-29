import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── Fetch profile from Supabase ─────────────────────────────────────────────

  Future<void> fetchProfile() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await _supabase.from('users').select().eq('id', uid).maybeSingle();
      if (data == null) {
        _error = 'پروفایل یافت نشد';
        debugPrint('UserProvider: no row found for uid=$uid');
      } else {
        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      _error = 'خطا: $e';
      debugPrint('UserProvider fetchProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update profile ───────────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('users').update(updates).eq('id', uid);

      // Update local state
      if (_user != null) {
        _user = _user!.copyWith(
          name: name,
          username: username,
          bio: bio,
          avatarUrl: avatarUrl,
        );
      }
      return true;
    } catch (e) {
      _error = 'خطا در ذخیره اطلاعات';
      debugPrint('UserProvider updateProfile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Clear on logout ──────────────────────────────────────────────────────────

  void clear() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
