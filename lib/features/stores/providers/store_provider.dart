import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/store_repository.dart';
import '../domain/store_model.dart';
import 'package:geolocator/geolocator.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StoreRepository(apiClient);
});

final storeCategoryFilterProvider = StateProvider<String>((ref) => 'All');
final storeSearchQueryProvider = StateProvider<String>((ref) => '');

final nearbyStoresProvider = FutureProvider.autoDispose<StoreListResponseModel>((ref) async {
  final repository = ref.watch(storeRepositoryProvider);
  final activeFarm = ref.watch(activeFarmProvider);
  final category = ref.watch(storeCategoryFilterProvider);
  final search = ref.watch(storeSearchQueryProvider);

  double? lat = activeFarm?.latitude;
  double? lon = activeFarm?.longitude;

  if (lat == null || lon == null) {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
          );
          lat = position.latitude;
          lon = position.longitude;
        }
      }
    } catch (e) {
      // Ignore geolocator errors
    }
  }

  return await repository.getStores(
    lat: lat ?? 18.8262, // Fallback to Pune
    lon: lon ?? 74.3779,
    farmId: activeFarm?.id,
    district: activeFarm?.district,
    category: category == 'All' ? null : category,
    search: search.trim().isEmpty ? null : search.trim(),
  );
});
