import 'package:intl/intl.dart';
import 'package:tekki/core/constants/app_constants.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0', 'fr_FR');

  static String format(int amount) {
    final formatted = _formatter
        .format(amount)
        .replaceAll(RegExp(r'[\u00A0\u202F]'), ' ');
    return '$formatted ${AppConstants.currencySymbol}';
  }
}
