import 'dart:typed_data';

/// Encodeur et décodeur Base45 pur Dart conforme à la RFC 9285.
///
/// L'alphabet Base45 comprend 45 caractères autorisés pour un scan optique QR code ultra-rapide (< 1s) :
/// `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:`
class Base45 {
  static const String charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ \$%*+-./:';

  static const List<String> _encoding = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    ' ',
    '\$',
    '%',
    '*',
    '+',
    '-',
    '.',
    '/',
    ':',
  ];

  static final Map<int, int> _decoding = () {
    final map = <int, int>{};
    for (int i = 0; i < charset.length; i++) {
      map[charset.codeUnitAt(i)] = i;
    }
    return map;
  }();

  /// Encode une séquence d'octets en chaîne Base45 conforme à la RFC 9285.
  ///
  /// Lève un [ArgumentError] si un octet a une valeur hors limites (< 0 ou > 255).
  static String encode(List<int> data) {
    if (data.isEmpty) return '';

    for (int idx = 0; idx < data.length; idx++) {
      final byte = data[idx];
      if (byte < 0 || byte > 255) {
        throw ArgumentError.value(
          byte,
          'data[$idx]',
          'Base45.encode: byte value out of range (must be between 0 and 255)',
        );
      }
    }

    final buffer = StringBuffer();
    final length = data.length;
    int i = 0;

    while (i < length) {
      if (i + 1 < length) {
        final a = data[i];
        final b = data[i + 1];
        final n = (a << 8) | b;
        final c = n % 45;
        final d = (n ~/ 45) % 45;
        final e = (n ~/ 2025) % 45;
        buffer.write(_encoding[c]);
        buffer.write(_encoding[d]);
        buffer.write(_encoding[e]);
        i += 2;
      } else {
        final a = data[i];
        final c = a % 45;
        final d = a ~/ 45;
        buffer.write(_encoding[c]);
        buffer.write(_encoding[d]);
        i += 1;
      }
    }

    return buffer.toString();
  }

  /// Décode une chaîne Base45 en tableau d'octets [Uint8List].
  ///
  /// Lève une [FormatException] si la chaîne contient un caractère invalide,
  /// si sa longueur modulo 3 est égale à 1, ou si une valeur dépasse les bornes.
  static Uint8List decode(String input) {
    if (input.isEmpty) return Uint8List(0);

    final remainder = input.length % 3;
    if (remainder == 1) {
      throw FormatException(
        'Base45: longueur invalide pour le décodage ($input)',
      );
    }

    final codeUnits = input.codeUnits;
    final length = codeUnits.length;
    final wholeChunks = length ~/ 3;
    final resultLength = wholeChunks * 2 + (remainder == 2 ? 1 : 0);
    final result = Uint8List(resultLength);

    int resultIndex = 0;
    int i = 0;
    final wholeChunkEnd = wholeChunks * 3;

    while (i < wholeChunkEnd) {
      final c0 = _decoding[codeUnits[i]];
      final c1 = _decoding[codeUnits[i + 1]];
      final c2 = _decoding[codeUnits[i + 2]];

      if (c0 == null || c1 == null || c2 == null) {
        throw FormatException('Base45: caractère invalide dans "$input"');
      }

      final val = c0 + (c1 * 45) + (c2 * 2025);
      if (val > 65535) {
        throw FormatException(
          'Base45: valeur 16-bit hors limites dans "$input"',
        );
      }

      result[resultIndex++] = (val >> 8) & 0xFF;
      result[resultIndex++] = val & 0xFF;
      i += 3;
    }

    if (remainder == 2) {
      final c0 = _decoding[codeUnits[i]];
      final c1 = _decoding[codeUnits[i + 1]];

      if (c0 == null || c1 == null) {
        throw FormatException('Base45: caractère invalide dans "$input"');
      }

      final val = c0 + (c1 * 45);
      if (val > 255) {
        throw FormatException(
          'Base45: valeur 8-bit hors limites dans "$input"',
        );
      }

      result[resultIndex] = val;
    }

    return result;
  }
}
