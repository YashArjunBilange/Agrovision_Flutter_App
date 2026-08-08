import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final SharedPreferences _sharedPrefs;

  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserLanguage = 'user_preferred_language';
  static const String _keyActiveFarmId = 'active_farm_id';

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _secureStorage.write(key: _keyToken, value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<String?> getAccessToken() async {
    return await getToken();
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyRefreshToken);
  }

  // Generic key-value preferences
  Future<void> setString(String key, String value) async {
    await _sharedPrefs.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPrefs.getString(key);
  }

  Future<void> remove(String key) async {
    await _sharedPrefs.remove(key);
  }

  // Language Preferences (en / mr)
  Future<void> saveLanguage(String langCode) async {
    await _sharedPrefs.setString(_keyUserLanguage, langCode);
  }

  String getLanguage() {
    return _sharedPrefs.getString(_keyUserLanguage) ?? 'en';
  }

  // Active Farm Cache
  Future<void> saveActiveFarmId(String farmId) async {
    await _sharedPrefs.setString(_keyActiveFarmId, farmId);
  }

  String? getActiveFarmId() {
    return _sharedPrefs.getString(_keyActiveFarmId);
  }
}
