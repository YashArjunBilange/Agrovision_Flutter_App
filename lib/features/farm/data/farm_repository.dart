import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/farm_model.dart';

class FarmRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  FarmRepository(this._apiClient, this._storageService);

  Future<List<FarmModel>> getFarms() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.farms);
      final list = (response.data as List)
          .map((item) => FarmModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Cache active farm ID
      final primary = list.where((f) => f.isPrimary).firstOrNull ?? list.firstOrNull;
      if (primary != null) {
        await _storageService.saveActiveFarmId(primary.id.toString());
      }

      return list;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<FarmModel> getFarm(int farmId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.farms}/$farmId');
      return FarmModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<FarmModel> createFarm(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.farms,
        data: data,
      );
      final farm = FarmModel.fromJson(response.data as Map<String, dynamic>);
      if (farm.isPrimary) {
        await _storageService.saveActiveFarmId(farm.id.toString());
      }
      return farm;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<FarmModel> updateFarm(int farmId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.farms}/$farmId',
        data: data,
      );
      final farm = FarmModel.fromJson(response.data as Map<String, dynamic>);
      if (farm.isPrimary) {
        await _storageService.saveActiveFarmId(farm.id.toString());
      }
      return farm;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> deleteFarm(int farmId) async {
    try {
      await _apiClient.delete('${ApiEndpoints.farms}/$farmId');
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<FarmModel> setActiveFarm(int farmId) async {
    try {
      final response = await _apiClient.post('${ApiEndpoints.farms}/$farmId/set-active');
      final farm = FarmModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.saveActiveFarmId(farm.id.toString());
      return farm;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
