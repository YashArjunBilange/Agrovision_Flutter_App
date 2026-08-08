class TransactionModel {
  final int id;
  final int? farmId;
  final int? cropCycleId;
  final String type; // 'expense' or 'income'
  final String category;
  final String title;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? paymentMethod;
  final double? quantity;
  final String? unit;
  final double? ratePerUnit;

  const TransactionModel({
    required this.id,
    this.farmId,
    this.cropCycleId,
    required this.type,
    required this.category,
    required this.title,
    required this.amount,
    required this.date,
    this.notes,
    this.paymentMethod,
    this.quantity,
    this.unit,
    this.ratePerUnit,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      farmId: json['farm_id'] as int?,
      cropCycleId: json['crop_cycle_id'] as int?,
      type: json['type'] as String? ?? 'expense',
      category: json['category'] as String? ?? 'Other',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] as String?,
      paymentMethod: json['payment_method'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      ratePerUnit: (json['rate_per_unit'] as num?)?.toDouble(),
    );
  }
}

class CategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;

  const CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FinanceSummaryModel {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final double profitMarginPercent;
  final List<CategoryBreakdown> expenseBreakdown;
  final List<CategoryBreakdown> incomeBreakdown;
  final List<TransactionModel> recentTransactions;

  const FinanceSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.profitMarginPercent,
    required this.expenseBreakdown,
    required this.incomeBreakdown,
    required this.recentTransactions,
  });

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinanceSummaryModel(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
      profitMarginPercent: (json['profit_margin_percent'] as num?)?.toDouble() ?? 0.0,
      expenseBreakdown: (json['expense_breakdown'] as List<dynamic>?)
              ?.map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      incomeBreakdown: (json['income_breakdown'] as List<dynamic>?)
              ?.map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class EconomicsReportModel {
  final int? farmId;
  final String? farmName;
  final double areaAcres;
  final double totalExpense;
  final double totalIncome;
  final double netProfit;
  final double costPerAcre;
  final double revenuePerAcre;
  final double profitPerAcre;
  final double roiPercent;
  final List<CategoryBreakdown> topExpenseCategories;

  const EconomicsReportModel({
    this.farmId,
    this.farmName,
    required this.areaAcres,
    required this.totalExpense,
    required this.totalIncome,
    required this.netProfit,
    required this.costPerAcre,
    required this.revenuePerAcre,
    required this.profitPerAcre,
    required this.roiPercent,
    required this.topExpenseCategories,
  });

  factory EconomicsReportModel.fromJson(Map<String, dynamic> json) {
    return EconomicsReportModel(
      farmId: json['farm_id'] as int?,
      farmName: json['farm_name'] as String?,
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 1.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
      costPerAcre: (json['cost_per_acre'] as num?)?.toDouble() ?? 0.0,
      revenuePerAcre: (json['revenue_per_acre'] as num?)?.toDouble() ?? 0.0,
      profitPerAcre: (json['profit_per_acre'] as num?)?.toDouble() ?? 0.0,
      roiPercent: (json['roi_percent'] as num?)?.toDouble() ?? 0.0,
      topExpenseCategories: (json['top_expense_categories'] as List<dynamic>?)
              ?.map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
