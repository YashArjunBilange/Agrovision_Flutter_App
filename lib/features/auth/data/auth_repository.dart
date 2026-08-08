import 'dart:convert';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  static const String _userCacheKey = 'cached_farmer_user';

  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'identifier': identifier.trim(),
          'password': password,
        },
      );

      final authData = AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      await _storageService.setString(_userCacheKey, jsonEncode(authData.user.toJson()));

      return authData.user;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    String preferredLanguage = 'mr',
    String state = 'Maharashtra',
    String? district,
    String? taluka,
    String? village,
    double totalLandAcres = 0.0,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          if (email != null && email.isNotEmpty) 'email': email.trim(),
          'password': password,
          'preferred_language': preferredLanguage,
          'state': state,
          'district': district,
          'taluka': taluka,
          'village': village,
          'total_land_acres': totalLandAcres,
        },
      );

      final authData = AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      await _storageService.setString(_userCacheKey, jsonEncode(authData.user.toJson()));

      return authData.user;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await _apiClient.get(ApiEndpoints.me);
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.setString(_userCacheKey, jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      // Fallback to locally cached user if offline
      final cached = _storageService.getString(_userCacheKey);
      if (cached != null) {
        return UserModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      }
      return null;
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.auth}/me/profile',
        data: data,
      );
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.setString(_userCacheKey, jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> logout() async {
    await _storageService.clearTokens();
    await _storageService.remove(_userCacheKey);
  }
}
