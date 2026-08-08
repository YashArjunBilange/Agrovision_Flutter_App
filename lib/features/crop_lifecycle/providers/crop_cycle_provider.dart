import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/crop_cycle_repository.dart';
import '../domain/crop_cycle_model.dart';

final cropCycleRepositoryProvider = Provider<CropCycleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CropCycleRepository(apiClient);
});

class ActiveCropCycleNotifier extends StateNotifier<AsyncValue<CropCycleModel?>> {
  final CropCycleRepository _repository;
  final int? _farmId;

  ActiveCropCycleNotifier(this._repository, this._farmId) : super(const AsyncValue.loading()) {
    loadCycle();
  }

  Future<void> loadCycle() async {
    state = const AsyncValue.loading();
    try {
      final cycle = await _repository.getActiveCropCycle(farmId: _farmId);
      state = AsyncValue.data(cycle);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startNewCycle({
    required int farmId,
    String cropName = 'Maize',
    String? varietyName,
    String season = 'Kharif',
    required String sowingDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newCycle = await _repository.createCropCycle(
        farmId: farmId,
        cropName: cropName,
        varietyName: varietyName,
        season: season,
        sowingDate: sowingDate,
      );
      state = AsyncValue.data(newCycle);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleTask(int taskId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic UI update
    final updatedTasks = current.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(isCompleted: !t.isCompleted);
      }
      return t;
    }).toList();

    state = AsyncValue.data(CropCycleModel(
      id: current.id,
      userId: current.userId,
      farmId: current.farmId,
      cropName: current.cropName,
      varietyName: current.varietyName,
      season: current.season,
      sowingDate: current.sowingDate,
      expectedHarvestDate: current.expectedHarvestDate,
      status: current.status,
      daysSinceSowing: current.daysSinceSowing,
      progressPercentage: current.progressPercentage,
      currentStage: current.currentStage,
      tasks: updatedTasks,
    ));

    try {
      await _repository.toggleTask(taskId);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(current);
    }
  }
}

final activeCropCycleProvider = StateNotifierProvider<ActiveCropCycleNotifier, AsyncValue<CropCycleModel?>>((ref) {
  final repository = ref.watch(cropCycleRepositoryProvider);
  final activeFarm = ref.watch(activeFarmProvider);
  return ActiveCropCycleNotifier(repository, activeFarm?.id);
});

final stagesCatalogProvider = FutureProvider<List<CropStageModel>>((ref) async {
  final repository = ref.watch(cropCycleRepositoryProvider);
  return repository.getStagesCatalog();
});

final selectedStageIdProvider = StateProvider<String?>((ref) => null);
