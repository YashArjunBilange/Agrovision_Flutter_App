import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/finance_repository.dart';
import '../domain/finance_model.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FinanceRepository(apiClient);
});

final financeSummaryProvider = FutureProvider.autoDispose<FinanceSummaryModel>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  final activeFarm = ref.watch(activeFarmProvider);
  return await repository.getSummary(farmId: activeFarm?.id);
});

final economicsReportProvider = FutureProvider.autoDispose<EconomicsReportModel>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  final activeFarm = ref.watch(activeFarmProvider);
  return await repository.getEconomicsReport(farmId: activeFarm?.id);
});

class TransactionsState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;
  final String selectedFilter; // 'all', 'expense', 'income'

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.selectedFilter = 'all',
  });

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    String? selectedFilter,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final FinanceRepository _repository;
  final Ref _ref;

  TransactionsNotifier(this._repository, this._ref) : super(const TransactionsState()) {
    fetchTransactions();
  }

  Future<void> fetchTransactions({String? filter}) async {
    final activeFilter = filter ?? state.selectedFilter;
    state = state.copyWith(isLoading: true, error: null, selectedFilter: activeFilter);

    try {
      final activeFarm = _ref.read(activeFarmProvider);
      final type = activeFilter == 'all' ? null : activeFilter;
      final txns = await _repository.getTransactions(
        farmId: activeFarm?.id,
        type: type,
      );
      state = state.copyWith(transactions: txns, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createTransaction(data);
      _ref.invalidate(financeSummaryProvider);
      _ref.invalidate(economicsReportProvider);
      await fetchTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      _ref.invalidate(financeSummaryProvider);
      _ref.invalidate(economicsReportProvider);
      await fetchTransactions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final transactionsNotifierProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return TransactionsNotifier(repo, ref);
});
