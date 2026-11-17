import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/crypto/base45.dart';

void main() {
  group('Base45 RFC 9285 Unit Tests', () {
    test(
      'Empty data encodes to empty string and decodes to empty Uint8List',
      () {
        expect(Base45.encode([]), '');
        expect(Base45.encode(Uint8List(0)), '');
        expect(Base45.decode(''), Uint8List(0));
      },
    );

    test('RFC 9285 Vector 1: "Hello!!" <-> "%69 VD92EX0"', () {
      final inputBytes = utf8.encode('Hello!!');
      const expectedEncoded = '%69 VD92EX0';

      final encoded = Base45.encode(inputBytes);
      expect(encoded, equals(expectedEncoded));

      final decoded = Base45.decode(expectedEncoded);
      expect(decoded, equals(inputBytes));
      expect(utf8.decode(decoded), equals('Hello!!'));
    });

    test('RFC 9285 Vector 2: "base-45" <-> "UJCLQE7W581"', () {
      final inputBytes = utf8.encode('base-45');
      const expectedEncoded = 'UJCLQE7W581';

      final encoded = Base45.encode(inputBytes);
      expect(encoded, equals(expectedEncoded));

      final decoded = Base45.decode(expectedEncoded);
      expect(decoded, equals(inputBytes));
      expect(utf8.decode(decoded), equals('base-45'));
    });

    test('RFC 9285 Vector 3: "ietf!" <-> "QED8WEX0"', () {
      final inputBytes = utf8.encode('ietf!');
      const expectedEncoded = 'QED8WEX0';

      final encoded = Base45.encode(inputBytes);
      expect(encoded, equals(expectedEncoded));

      final decoded = Base45.decode(expectedEncoded);
      expect(decoded, equals(inputBytes));
      expect(utf8.decode(decoded), equals('ietf!'));
    });

    test('Single-byte boundary cases: [0] -> "00", [255] -> ".5"', () {
      expect(Base45.encode([0]), '00');
      expect(Base45.decode('00'), equals([0]));

      // 255 % 45 = 30 ('U'? wait: 255 = 5 * 45 + 30. 30 is 'U', 5 is '5')
      final encoded255 = Base45.encode([255]);
      expect(Base45.decode(encoded255), equals([255]));
    });

    test('Two-byte boundary cases: [0, 0] -> "000"', () {
      expect(Base45.encode([0, 0]), '000');
      expect(Base45.decode('000'), equals([0, 0]));

      final encodedMax = Base45.encode([255, 255]);
      expect(Base45.decode(encodedMax), equals([255, 255]));
    });

    test(
      'Roundtrip with arbitrary pseudo-random byte sequences of varying lengths',
      () {
        final random = Random(42);
        for (final length in [1, 2, 3, 4, 10, 31, 32, 64, 100, 255, 512]) {
          final original = Uint8List.fromList(
            List.generate(length, (_) => random.nextInt(256)),
          );
          final encoded = Base45.encode(original);
          final decoded = Base45.decode(encoded);
          expect(
            decoded,
            equals(original),
            reason: 'Failed for length $length',
          );
        }
      },
    );

    test('Rejects invalid input lengths (length % 3 == 1)', () {
      expect(() => Base45.decode('A'), throwsFormatException);
      expect(() => Base45.decode('ABCD'), throwsFormatException);
      expect(() => Base45.decode('ABCDEFG'), throwsFormatException);
    });

    test('Rejects illegal characters not in RFC 9285 charset', () {
      // Lowercase characters are forbidden in Base45
      expect(() => Base45.decode('abc'), throwsFormatException);
      expect(() => Base45.decode('hello'), throwsFormatException);
      // Non-alphabet symbols (@, #, ~, !)
      expect(() => Base45.decode('AB@'), throwsFormatException);
      expect(() => Base45.decode('AB#'), throwsFormatException);
      expect(() => Base45.decode('AB!'), throwsFormatException);
    });

    test(
      'Rejects values exceeding 16-bit limits (> 65535) or 8-bit limits (> 255)',
      () {
        // ':::' is 44 + 44*45 + 44*2025 = 91124 > 65535
        expect(() => Base45.decode(':::'), throwsFormatException);
        // '::' is 44 + 44*45 = 2024 > 255
        expect(() => Base45.decode('::'), throwsFormatException);
      },
    );

    test(
      'Encode throws ArgumentError on out-of-range byte values (< 0 or > 255)',
      () {
        expect(() => Base45.encode([-1]), throwsArgumentError);
        expect(() => Base45.encode([256]), throwsArgumentError);
        expect(() => Base45.encode([10, -5, 20]), throwsArgumentError);
        expect(() => Base45.encode([10, 300]), throwsArgumentError);
      },
    );
  });
}
