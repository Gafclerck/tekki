import 'package:url_launcher/url_launcher.dart';

abstract class IWhatsAppService {
  String sanitizePhoneNumber(String rawNumber);
  Uri buildWhatsAppUri({required String phoneNumber, required String message});
  Future<bool> launchWhatsApp({
    required String phoneNumber,
    required String message,
  });
}

class UrlLauncherWhatsAppService implements IWhatsAppService {
  const UrlLauncherWhatsAppService({this.launchUrlFn});

  final Future<bool> Function(Uri uri, {LaunchMode? mode})? launchUrlFn;

  @override
  String sanitizePhoneNumber(String rawNumber) {
    var digits = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00221')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('221') && digits.length == 12) {
      digits = digits.substring(3);
    } else if (digits.length == 10 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    // Numéro sénégalais standard à 9 chiffres débutant par 7 (77, 78, 76, 70, 75...)
    if (digits.length == 9 && digits.startsWith('7')) {
      return '221$digits';
    }
    return digits;
  }

  @override
  Uri buildWhatsAppUri({required String phoneNumber, required String message}) {
    final cleanPhone = sanitizePhoneNumber(phoneNumber);
    return Uri.https('wa.me', '/$cleanPhone', {'text': message});
  }

  @override
  Future<bool> launchWhatsApp({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final uri = buildWhatsAppUri(phoneNumber: phoneNumber, message: message);
      final customLaunch = launchUrlFn;
      if (customLaunch != null) {
        return await customLaunch(uri, mode: LaunchMode.externalApplication);
      }
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
