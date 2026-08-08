import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../farm/providers/farm_provider.dart';
import '../domain/finance_model.dart';
import '../providers/finance_provider.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final summaryAsync = ref.watch(financeSummaryProvider);
    final reportAsync = ref.watch(economicsReportProvider);
    final txnsState = ref.watch(transactionsNotifierProvider);
    final activeFarm = ref.watch(activeFarmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'शेती नफा-तोटा व अर्थकारण' : 'Farm Finance & Economics',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(financeSummaryProvider);
              ref.invalidate(economicsReportProvider);
              ref.read(transactionsNotifierProvider.notifier).fetchTransactions();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          isMr ? 'नोंद करा' : 'Add Entry',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddTransactionModal(context, isMr),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financeSummaryProvider);
          ref.invalidate(economicsReportProvider);
          await ref.read(transactionsNotifierProvider.notifier).fetchTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active Farm Context Badge
              if (activeFarm != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${activeFarm.name} (${activeFarm.areaAcres} ${isMr ? 'एकर' : 'Acres'})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              // 1. Hero P&L Summary Card
              summaryAsync.when(
                data: (summary) => _buildHeroSummaryCard(summary, isMr),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Text(err.toString()),
              ),

              const SizedBox(height: 16),

              // 2. Unit Economics / Per-Acre Analysis
              reportAsync.when(
                data: (report) => _buildUnitEconomicsCard(report, isMr),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // 3. Categorical Expense Breakdown
              summaryAsync.when(
                data: (summary) => summary.expenseBreakdown.isNotEmpty
                    ? _buildExpenseBreakdownCard(summary.expenseBreakdown, summary.totalExpense, isMr)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // 4. Transactions List & Filter
              _buildTransactionsSection(txnsState, isMr),

              const SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSummaryCard(FinanceSummaryModel summary, bool isMr) {
    final isProfit = summary.netProfit >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFFB71C1C), const Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMr ? 'निव्वळ नफा / तोटा (Net P&L)' : 'Net Profit / Loss',
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.profitMarginPercent.toStringAsFixed(1)}% ${isMr ? 'मार्जिन' : 'Margin'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _currencyFormat.format(summary.netProfit),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          isMr ? 'एकूण उत्पन्न (Income)' : 'Total Income',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(summary.totalIncome),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.orangeAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          isMr ? 'एकूण खर्च (Expense)' : 'Total Expense',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(summary.totalExpense),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitEconomicsCard(EconomicsReportModel report, bool isMr) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_rounded, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  isMr ? 'प्रति एकर अर्थकारण (Per Acre ROI)' : 'Unit Economics (Per Acre)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerAcreMetric(
                  isMr ? 'खर्च/एकर' : 'Cost/Acre',
                  _currencyFormat.format(report.costPerAcre),
                  Colors.orange.shade800,
                ),
                Container(width: 1, height: 28, color: Colors.grey.shade300),
                _buildPerAcreMetric(
                  isMr ? 'उत्पन्न/एकर' : 'Revenue/Acre',
                  _currencyFormat.format(report.revenuePerAcre),
                  Colors.green.shade800,
                ),
                Container(width: 1, height: 28, color: Colors.grey.shade300),
                _buildPerAcreMetric(
                  isMr ? 'नफा/एकर' : 'Profit/Acre',
                  _currencyFormat.format(report.profitPerAcre),
                  report.profitPerAcre >= 0 ? AppColors.primaryGreen : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerAcreMetric(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownCard(List<CategoryBreakdown> breakdown, double total, bool isMr) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMr ? 'खर्च विभागणी (Expense Breakdown)' : 'Expense Breakdown',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...breakdown.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          '${_currencyFormat.format(item.amount)} (${item.percentage.toStringAsFixed(0)}%)',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? item.amount / total : 0,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(TransactionsState state, bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMr ? 'खर्च व उत्पन्न वहिवाट (Ledger)' : 'Transaction Ledger',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${state.transactions.length} ${isMr ? 'नोंदी' : 'Entries'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Filter chips
        Row(
          children: [
            _buildFilterChip('all', isMr ? 'सर्व' : 'All', state.selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip('expense', isMr ? 'फक्त खर्च' : 'Expenses', state.selectedFilter),
            const SizedBox(width: 8),
            _buildFilterChip('income', isMr ? 'फक्त उत्पन्न' : 'Income', state.selectedFilter),
          ],
        ),
        const SizedBox(height: 12),

        if (state.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (state.transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    isMr ? 'अजून कोणतीही नोंद नाही.' : 'No transactions recorded yet.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...state.transactions.map((txn) => _buildTransactionItem(txn, isMr)),
      ],
    );
  }

  Widget _buildFilterChip(String id, String label, String current) {
    final isSelected = current == id;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
      onSelected: (_) {
        ref.read(transactionsNotifierProvider.notifier).fetchTransactions(filter: id);
      },
    );
  }

  Widget _buildTransactionItem(TransactionModel txn, bool isMr) {
    final isExpense = txn.type == 'expense';
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.green.withValues(alpha: 0.1),
          child: Icon(
            isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: isExpense ? Colors.red : Colors.green,
            size: 20,
          ),
        ),
        title: Text(
          txn.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${txn.category} • ${dateFormat.format(txn.date)}${txn.paymentMethod != null ? ' • ${txn.paymentMethod}' : ''}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isExpense ? '-' : '+'}${_currencyFormat.format(txn.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isExpense ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
              onPressed: () {
                ref.read(transactionsNotifierProvider.notifier).removeTransaction(txn.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context, bool isMr) {
    String type = 'expense';
    String category = 'Fertilizers';
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    String paymentMethod = 'Cash';

    final expenseCategories = [
      'Seeds',
      'Fertilizers',
      'Pesticides',
      'Labor',
      'Machinery',
      'Irrigation',
      'Other Expense',
    ];

    final incomeCategories = [
      'Crop Harvest',
      'Fodder Sale',
      'Govt Subsidy',
      'Other Income',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isMr ? 'नवीन नोंद जोडा' : 'Add New Transaction',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Type Toggle Segment
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'expense',
                          label: Text(isMr ? 'खर्च (Expense)' : 'Expense'),
                          icon: const Icon(Icons.arrow_upward, color: Colors.red),
                        ),
                        ButtonSegment(
                          value: 'income',
                          label: Text(isMr ? 'उत्पन्न (Income)' : 'Income'),
                          icon: const Icon(Icons.arrow_downward, color: Colors.green),
                        ),
                      ],
                      selected: {type},
                      onSelectionChanged: (set) {
                        setModalState(() {
                          type = set.first;
                          category = type == 'expense' ? 'Fertilizers' : 'Crop Harvest';
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: InputDecoration(
                        labelText: isMr ? 'प्रवर्ग (Category)' : 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: (type == 'expense' ? expenseCategories : incomeCategories).map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Title
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: isMr ? 'तपशील / शीर्षक (उदा. डीएपी खत २ गोणी)' : 'Title / Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Amount
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isMr ? 'रक्कम (Amount ₹)' : 'Amount (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quantity & Unit
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: isMr ? 'प्रमाण (Quantity)' : 'Qty',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: unitCtrl,
                            decoration: InputDecoration(
                              labelText: isMr ? 'एकक (Bags/Qntl/Lit)' : 'Unit',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final amt = double.tryParse(amountCtrl.text.trim());
                        final title = titleCtrl.text.trim();
                        if (amt == null || amt <= 0 || title.isEmpty) return;

                        final activeFarm = ref.read(activeFarmProvider);
                        final payload = {
                          'farm_id': activeFarm?.id,
                          'type': type,
                          'category': category,
                          'title': title,
                          'amount': amt,
                          'payment_method': paymentMethod,
                          if (quantityCtrl.text.isNotEmpty) 'quantity': double.tryParse(quantityCtrl.text),
                          if (unitCtrl.text.isNotEmpty) 'unit': unitCtrl.text.trim(),
                        };

                        Navigator.pop(ctx);
                        await ref.read(transactionsNotifierProvider.notifier).addTransaction(payload);
                      },
                      child: Text(
                        isMr ? 'नोंद जतन करा' : 'Save Transaction',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
