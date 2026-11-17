import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats zero amount with currency symbol', () {
      final result = CurrencyFormatter.format(0);
      expect(result, equals('0 FCFA'));
    });

    test('formats positive amounts with thousand separators', () {
      final result = CurrencyFormatter.format(5000);
      expect(result, equals('5 000 FCFA'));
    });

    test('formats large amounts accurately without decimals', () {
      final result = CurrencyFormatter.format(1250000);
      expect(result, equals('1 250 000 FCFA'));
    });
  });
}
