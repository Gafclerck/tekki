import 'package:intl/intl.dart';
import 'package:tekki/core/constants/app_constants.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0', 'fr_FR');

  static String format(int amount) {
    final formatted = _formatter.format(amount).replaceAll('\u00A0', ' ');
    return '$formatted ${AppConstants.currencySymbol}';
  }
}
