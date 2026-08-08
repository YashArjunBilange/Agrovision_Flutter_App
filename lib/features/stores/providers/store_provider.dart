import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/store_repository.dart';
import '../domain/store_model.dart';

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

  return await repository.getStores(
    lat: activeFarm?.latitude ?? 18.8262,
    lon: activeFarm?.longitude ?? 74.3779,
    farmId: activeFarm?.id,
    district: activeFarm?.district,
    category: category == 'All' ? null : category,
    search: search.trim().isEmpty ? null : search.trim(),
  );
});
