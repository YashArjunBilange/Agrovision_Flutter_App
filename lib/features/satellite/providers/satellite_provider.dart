import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../domain/satellite_model.dart';

final satelliteProvider = Provider<SatelliteService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SatelliteService(apiClient);
});

class SatelliteService {
  final dynamic _apiClient;

  SatelliteService(this._apiClient);

  Future<SatelliteObservation> getLatestObservation(int farmId) async {
    final response = await _apiClient.get('/satellite/$farmId/latest');
    return SatelliteObservation.fromJson(response);
  }

  Future<SatelliteHistory> getHistory(int farmId) async {
    final response = await _apiClient.get('/satellite/$farmId/history');
    return SatelliteHistory.fromJson(response);
  }
}

final latestSatelliteObservationProvider = FutureProvider.family<SatelliteObservation, int>((ref, farmId) async {
  final service = ref.watch(satelliteProvider);
  return await service.getLatestObservation(farmId);
});

final satelliteHistoryProvider = FutureProvider.family<SatelliteHistory, int>((ref, farmId) async {
  final service = ref.watch(satelliteProvider);
  return await service.getHistory(farmId);
});
