import '../../../core/network/api_client.dart';
import '../domain/crop_cycle_model.dart';

class CropCycleRepository {
  final ApiClient _apiClient;

  CropCycleRepository(this._apiClient);

  Future<CropCycleModel?> getActiveCropCycle({int? farmId}) async {
    final response = await _apiClient.get(
      '/api/v1/crops/active',
      queryParameters: farmId != null ? {'farm_id': farmId} : null,
    );

    if (response.data == null) {
      return null;
    }
    return CropCycleModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CropCycleModel> createCropCycle({
    required int farmId,
    String cropName = 'Maize',
    String? varietyName,
    String season = 'Kharif',
    required String sowingDate,
  }) async {
    final payload = {
      'farm_id': farmId,
      'crop_name': cropName,
      if (varietyName != null && varietyName.isNotEmpty) 'variety_name': varietyName,
      'season': season,
      'sowing_date': sowingDate,
    };

    final response = await _apiClient.post(
      '/api/v1/crops',
      data: payload,
    );

    return CropCycleModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<CropStageModel>> getStagesCatalog() async {
    final response = await _apiClient.get('/api/v1/crops/stages');
    final list = response.data as List<dynamic>;
    return list.map((e) => CropStageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FertilizerCalculationModel> calculateFertilizer({
    required String stageId,
    required double acreage,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/crops/calculate-fertilizer',
      data: {
        'stage_id': stageId,
        'acreage': acreage,
      },
    );

    return FertilizerCalculationModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CropTaskModel> toggleTask(int taskId) async {
    final response = await _apiClient.put(
      '/api/v1/crops/tasks/$taskId/toggle',
    );

    return CropTaskModel.fromJson(response.data as Map<String, dynamic>);
  }
}
