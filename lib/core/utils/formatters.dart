import 'package:intl/intl.dart';

class AppFormatters {
  // Indian Rupee (INR) Formatter
  static String formatCurrency(num amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return format.format(amount);
  }

  // Percentage Formatter
  static String formatPercentage(double value) {
    return '${(value * (value <= 1.0 ? 100 : 1)).toStringAsFixed(1)}%';
  }

  // Date Formatter
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Short Date Formatter
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  // Area Formatter
  static String formatArea(double area, String unit) {
    return '${area.toStringAsFixed(1)} $unit';
  }
}
