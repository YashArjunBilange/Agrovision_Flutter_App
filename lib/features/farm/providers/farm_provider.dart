import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../data/farm_repository.dart';
import '../domain/farm_model.dart';

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return FarmRepository(apiClient, storageService);
});

class FarmsNotifier extends StateNotifier<AsyncValue<List<FarmModel>>> {
  final FarmRepository _repository;

  FarmsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFarms();
  }

  Future<void> loadFarms() async {
    state = const AsyncValue.loading();
    try {
      final farms = await _repository.getFarms();
      state = AsyncValue.data(farms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<FarmModel> addFarm(Map<String, dynamic> data) async {
    try {
      final newFarm = await _repository.createFarm(data);
      await loadFarms();
      return newFarm;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<FarmModel> updateFarm(int farmId, Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateFarm(farmId, data);
      await loadFarms();
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteFarm(int farmId) async {
    try {
      await _repository.deleteFarm(farmId);
      await loadFarms();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> setActiveFarm(int farmId) async {
    try {
      await _repository.setActiveFarm(farmId);
      await loadFarms();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final farmsProvider = StateNotifierProvider<FarmsNotifier, AsyncValue<List<FarmModel>>>((ref) {
  final repo = ref.watch(farmRepositoryProvider);
  return FarmsNotifier(repo);
});

final activeFarmProvider = Provider<FarmModel?>((ref) {
  final farmsAsync = ref.watch(farmsProvider);
  return farmsAsync.when(
    data: (farms) {
      if (farms.isEmpty) return null;
      return farms.where((f) => f.isPrimary).firstOrNull ?? farms.first;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
