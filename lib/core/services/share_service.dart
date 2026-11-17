import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Contrat abstrait de service de partage de documents natif.
abstract class IShareService {
  /// Enregistre les octets du fichier PDF dans un cache temporaire et
  /// déclenche la feuille de partage native du système d'exploitation.
  Future<bool> sharePdfFile({
    required Uint8List bytes,
    required String fileName,
    String? subject,
    String? text,
  });
}

/// Implémentation concrète de [IShareService] basée sur [Share] de share_plus
/// et [getTemporaryDirectory] de path_provider.
class SharePlusService implements IShareService {
  const SharePlusService({this.getTempDirFn, this.shareXFilesFn});

  final Future<Directory> Function()? getTempDirFn;
  final Future<ShareResult> Function(
    List<XFile> files, {
    String? subject,
    String? text,
  })?
  shareXFilesFn;

  @override
  Future<bool> sharePdfFile({
    required Uint8List bytes,
    required String fileName,
    String? subject,
    String? text,
  }) async {
    try {
      final tempDir = getTempDirFn != null
          ? await getTempDirFn!()
          : await getTemporaryDirectory();
      final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final separator = Platform.pathSeparator;
      final filePath = '${tempDir.path}$separator$sanitizedFileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      final shareFn = shareXFilesFn ?? Share.shareXFiles;
      final xFile = XFile(
        file.path,
        mimeType: 'application/pdf',
        name: sanitizedFileName,
      );

      final result = await shareFn([xFile], subject: subject, text: text);

      return result.status != ShareResultStatus.unavailable;
    } catch (_) {
      return false;
    }
  }
}
