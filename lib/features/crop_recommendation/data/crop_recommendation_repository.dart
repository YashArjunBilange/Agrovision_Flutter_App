import '../../../core/network/api_client.dart';
import '../domain/crop_recommendation_model.dart';

class CropRecommendationRepository {
  final ApiClient _apiClient;

  CropRecommendationRepository(this._apiClient);

  Future<CropRecommendationResponseModel> getRecommendations(
    CropRecommendationRequestModel request,
  ) async {
    final response = await _apiClient.post(
      '/api/v1/recommendations/recommend',
      data: request.toJson(),
    );

    return CropRecommendationResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<dynamic>> getSupportedCrops() async {
    final response = await _apiClient.get(
      '/api/v1/recommendations/supported',
    );
    return response.data as List<dynamic>;
  }
}
