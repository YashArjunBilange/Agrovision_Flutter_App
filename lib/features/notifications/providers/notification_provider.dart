import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/notification_repository.dart';
import '../domain/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient);
});

final farmAlertsProvider = FutureProvider.autoDispose<AlertListModel>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final activeFarm = ref.watch(activeFarmProvider);
  return await repository.getAlerts(farmId: activeFarm?.id);
});
