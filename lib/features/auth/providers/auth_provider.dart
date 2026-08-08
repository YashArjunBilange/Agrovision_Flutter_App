import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepository(apiClient, storageService);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(
        identifier: identifier,
        password: password,
      );
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    String preferredLanguage = 'mr',
    String stateName = 'Maharashtra',
    String? district,
    String? taluka,
    String? village,
    double totalLandAcres = 0.0,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        preferredLanguage: preferredLanguage,
        state: stateName,
        district: district,
        taluka: taluka,
        village: village,
        totalLandAcres: totalLandAcres,
      );
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateProfile(data);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).value;
});
