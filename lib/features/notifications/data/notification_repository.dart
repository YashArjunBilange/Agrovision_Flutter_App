import '../../../core/network/api_client.dart';
import '../domain/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<AlertListModel> getAlerts({int? farmId}) async {
    final response = await _apiClient.get(
      '/api/v1/notifications/alerts',
      queryParameters: farmId != null ? {'farm_id': farmId} : null,
    );
    return AlertListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markAlertRead(int alertId) async {
    await _apiClient.post('/api/v1/notifications/alerts/$alertId/read');
  }
}
