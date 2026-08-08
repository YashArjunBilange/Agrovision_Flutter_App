import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/crop_recommendation_repository.dart';
import '../domain/crop_recommendation_model.dart';

final cropRecommendationRepositoryProvider = Provider<CropRecommendationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CropRecommendationRepository(apiClient);
});

class CropRecommendationState {
  final CropRecommendationResponseModel? result;
  final bool isLoading;
  final String? error;

  const CropRecommendationState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  CropRecommendationState copyWith({
    CropRecommendationResponseModel? result,
    bool? isLoading,
    String? error,
  }) {
    return CropRecommendationState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CropRecommendationNotifier extends StateNotifier<CropRecommendationState> {
  final CropRecommendationRepository _repository;
  final Ref _ref;

  CropRecommendationNotifier(this._repository, this._ref)
      : super(const CropRecommendationState()) {
    // Initial fetch on mount
    fetchRecommendations();
  }

  Future<void> fetchRecommendations([CropRecommendationRequestModel? customRequest]) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final activeFarm = _ref.read(activeFarmProvider);
      final request = customRequest ??
          CropRecommendationRequestModel(
            farmId: activeFarm?.id,
            soilType: activeFarm?.soilType ?? 'Medium Black',
            irrigationAvailable: activeFarm?.irrigationType != 'Rainfed',
          );

      final response = await _repository.getRecommendations(request);
      state = state.copyWith(result: response, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final cropRecommendationProvider =
    StateNotifierProvider<CropRecommendationNotifier, CropRecommendationState>((ref) {
  final repository = ref.watch(cropRecommendationRepositoryProvider);
  return CropRecommendationNotifier(repository, ref);
});
