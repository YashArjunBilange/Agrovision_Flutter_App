import '../../../core/network/api_client.dart';
import '../domain/weather_model.dart';

class WeatherRepository {
  final ApiClient _apiClient;

  WeatherRepository(this._apiClient);

  Future<WeatherForecastModel> getWeatherByCoordinates({
    double latitude = 19.7515,
    double longitude = 75.7139,
    String? farmName,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (farmName != null) 'farm_name': farmName,
    };

    final response = await _apiClient.get(
      '/api/v1/weather',
      queryParameters: queryParams,
    );

    return WeatherForecastModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WeatherForecastModel> getWeatherForFarm(int farmId) async {
    final response = await _apiClient.get(
      '/api/v1/weather/farm/$farmId',
    );

    return WeatherForecastModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SprayAdvisoryModel> getSprayAdvisory({
    required double temp,
    required double windSpeed,
    int rainProb = 0,
    double precipitation = 0.0,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/weather/spray-advisory',
      queryParameters: {
        'temp': temp,
        'wind_speed': windSpeed,
        'rain_prob': rainProb,
        'precipitation': precipitation,
      },
    );

    return SprayAdvisoryModel.fromJson(response.data as Map<String, dynamic>);
  }
}
