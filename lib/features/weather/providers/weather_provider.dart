import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/weather_repository.dart';
import '../domain/weather_model.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WeatherRepository(apiClient);
});

final currentWeatherProvider = FutureProvider<WeatherForecastModel>((ref) async {
  final repository = ref.watch(weatherRepositoryProvider);
  final activeFarm = ref.watch(activeFarmProvider);

  if (activeFarm != null) {
    try {
      return await repository.getWeatherForFarm(activeFarm.id);
    } catch (_) {
      // Fallback to coordinates
      return await repository.getWeatherByCoordinates(
        latitude: activeFarm.latitude ?? 19.7515,
        longitude: activeFarm.longitude ?? 75.7139,
        farmName: activeFarm.name,
      );
    }
  }

  return await repository.getWeatherByCoordinates(
    latitude: 19.7515,
    longitude: 75.7139,
    farmName: 'Maharashtra (Default / महाराष्ट्र)',
  );
});
