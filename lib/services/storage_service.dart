import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý persistent storage cho auth tokens và onboarding state.
/// Dùng FlutterSecureStorage (mã hóa) thay vì SharedPreferences (plaintext).
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final _storage = const FlutterSecureStorage();

  // ── Keys ──
  static const _keyToken = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyUserId = 'user_id';
  static const _keyRole = 'user_role';
  static const _keyRecentSearches = 'recent_searches';

  // ── Auth tokens ──
  Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  Future<String?> getToken() =>
      _storage.read(key: _keyToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyRole);
  }

  // ── User ID ──
  Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  Future<String?> getUserId() =>
      _storage.read(key: _keyUserId);

  Future<void> clearUserId() =>
      _storage.delete(key: _keyUserId);

  // ── Role — cache để router quyết định redirect ngay khi khởi động, không cần chờ gọi API ──
  Future<void> saveRole(String role) =>
      _storage.write(key: _keyRole, value: role);

  Future<String?> getRole() =>
      _storage.read(key: _keyRole);

  // ── Onboarding state ──
  Future<void> setOnboardingDone() =>
      _storage.write(key: _keyOnboardingDone, value: 'true');

  Future<bool> isOnboardingDone() async {
    final v = await _storage.read(key: _keyOnboardingDone);
    return v == 'true';
  }

  // ── Recent searches (không nhạy cảm → SharedPreferences là đủ) ──
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyRecentSearches) ?? const [];
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRecentSearches, searches);
  }
}
