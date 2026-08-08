import '../../../core/network/api_client.dart';
import '../domain/assistant_model.dart';

class AssistantRepository {
  final ApiClient _apiClient;

  AssistantRepository(this._apiClient);

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    int? farmId,
    required String language,
  }) async {
    final payload = {
      'message': message,
      if (farmId != null) 'farm_id': farmId,
      'language': language,
    };

    final response = await _apiClient.post(
      '/api/v1/assistant/chat',
      data: payload,
    );

    return response.data as Map<String, dynamic>;
  }

  Future<List<QuickPrompt>> getQuickPrompts() async {
    final response = await _apiClient.get('/api/v1/assistant/quick-prompts');
    final list = response.data as List<dynamic>;
    return list.map((e) => QuickPrompt.fromJson(e as Map<String, dynamic>)).toList();
  }
}
