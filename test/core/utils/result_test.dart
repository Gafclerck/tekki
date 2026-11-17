import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Success returns correct value on fold', () {
      const Result<int, Failure> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);

      final folded = result.fold(
        onSuccess: (val) => 'value: $val',
        onError: (f) => 'error: ${f.message}',
      );
      expect(folded, equals('value: 42'));
    });

    test('Error returns correct failure on fold', () {
      const Result<int, Failure> result = Error(
        DatabaseFailure(message: 'Record not found'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);

      final folded = result.fold(
        onSuccess: (val) => 'value: $val',
        onError: (f) => 'error: ${f.message}',
      );
      expect(folded, equals('error: Record not found'));
    });
  });
}
