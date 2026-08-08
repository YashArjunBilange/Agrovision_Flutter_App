import '../../../core/network/api_client.dart';
import '../domain/finance_model.dart';

class FinanceRepository {
  final ApiClient _apiClient;

  FinanceRepository(this._apiClient);

  Future<FinanceSummaryModel> getSummary({int? farmId}) async {
    final response = await _apiClient.get(
      '/api/v1/finance/summary',
      queryParameters: farmId != null ? {'farm_id': farmId} : null,
    );
    return FinanceSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EconomicsReportModel> getEconomicsReport({int? farmId}) async {
    final response = await _apiClient.get(
      '/api/v1/finance/economics-report',
      queryParameters: farmId != null ? {'farm_id': farmId} : null,
    );
    return EconomicsReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TransactionModel>> getTransactions({
    int? farmId,
    String? type,
    String? category,
  }) async {
    final query = <String, dynamic>{};
    if (farmId != null) query['farm_id'] = farmId;
    if (type != null) query['type'] = type;
    if (category != null) query['category'] = category;

    final response = await _apiClient.get(
      '/api/v1/finance/transactions',
      queryParameters: query.isNotEmpty ? query : null,
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TransactionModel> createTransaction(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/api/v1/finance/transactions',
      data: data,
    );
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(int transactionId) async {
    await _apiClient.delete('/api/v1/finance/transactions/$transactionId');
  }
}
