import '../../../core/network/api_client.dart';
import '../domain/store_model.dart';

class StoreRepository {
  final ApiClient _apiClient;

  StoreRepository(this._apiClient);

  Future<StoreListResponseModel> getStores({
    double? lat,
    double? lon,
    int? farmId,
    String? district,
    String? category,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (lat != null) query['lat'] = lat;
    if (lon != null) query['lon'] = lon;
    if (farmId != null) query['farm_id'] = farmId;
    if (district != null && district.isNotEmpty) query['district'] = district;
    if (category != null && category.isNotEmpty && category != 'All') query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _apiClient.get(
      '/api/v1/stores',
      queryParameters: query.isNotEmpty ? query : null,
    );

    return StoreListResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AgriStore> getStoreById(int id) async {
    final response = await _apiClient.get('/api/v1/stores/$id');
    return AgriStore.fromJson(response.data as Map<String, dynamic>);
  }
}
