import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tekki/core/services/share_service.dart';

void main() {
  late Directory tempTestDir;

  setUp(() async {
    tempTestDir = await Directory.systemTemp.createTemp('tekki_share_test_');
  });

  tearDown(() async {
    if (await tempTestDir.exists()) {
      await tempTestDir.delete(recursive: true);
    }
  });

  group('SharePlusService Unit Tests', () {
    test(
      'successfully writes bytes to temp directory and delegates to shareXFiles',
      () async {
        final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const testFileName = 'test_passport.pdf';
        List<XFile>? capturedFiles;
        String? capturedSubject;
        String? capturedText;

        final service = SharePlusService(
          getTempDirFn: () async => tempTestDir,
          shareXFilesFn: (files, {subject, text}) async {
            capturedFiles = files;
            capturedSubject = subject;
            capturedText = text;
            return const ShareResult('success', ShareResultStatus.success);
          },
        );

        final result = await service.sharePdfFile(
          bytes: testBytes,
          fileName: testFileName,
          subject: 'Passeport Financier Tekki',
          text: 'Voici mon passeport',
        );

        expect(result, isTrue);
        expect(capturedFiles, isNotNull);
        expect(capturedFiles!.length, 1);
        expect(capturedFiles!.first.name, testFileName);
        expect(capturedFiles!.first.mimeType, 'application/pdf');
        expect(capturedSubject, 'Passeport Financier Tekki');
        expect(capturedText, 'Voici mon passeport');

        final createdFile = File('${tempTestDir.path}/$testFileName');
        expect(await createdFile.exists(), isTrue);
        expect(await createdFile.readAsBytes(), testBytes);
      },
    );

    test('returns false when shareXFiles returns unavailable status', () async {
      final testBytes = Uint8List.fromList([10, 20]);
      final service = SharePlusService(
        getTempDirFn: () async => tempTestDir,
        shareXFilesFn: (files, {subject, text}) async {
          return const ShareResult('failed', ShareResultStatus.unavailable);
        },
      );

      final result = await service.sharePdfFile(
        bytes: testBytes,
        fileName: 'unavailable.pdf',
      );

      expect(result, isFalse);
    });

    test(
      'gracefully catches exceptions and returns false without rethrowing',
      () async {
        final testBytes = Uint8List.fromList([100]);
        final service = SharePlusService(
          getTempDirFn: () async =>
              throw const FileSystemException('Permission denied'),
        );

        final result = await service.sharePdfFile(
          bytes: testBytes,
          fileName: 'error.pdf',
        );

        expect(result, isFalse);
      },
    );
  });
}
