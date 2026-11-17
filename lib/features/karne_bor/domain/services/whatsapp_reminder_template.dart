import 'package:intl/intl.dart';
import 'package:tekki/core/utils/currency_formatter.dart';

enum WhatsAppReminderLanguage { wolof, french }

abstract final class WhatsAppReminderTemplate {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Génère un message courtois et bienveillant adapté à la culture sénégalaise
  /// (Teranga, Soutoura) sans aucune agressivité ni mention de pénalités.
  static String generate({
    required String debtorName,
    required int remainingAmount,
    required DateTime dueDate,
    required WhatsAppReminderLanguage language,
    bool isOverdue = false,
  }) {
    final cleanName = debtorName.trim();
    final formattedAmount = CurrencyFormatter.format(remainingAmount);
    final formattedDate = _dateFormat.format(dueDate);

    switch (language) {
      case WhatsAppReminderLanguage.wolof:
        final salutationName = cleanName.isNotEmpty ? cleanName : 'sama xarit';
        if (isOverdue) {
          return 'Salamalekum $salutationName, na nga def ? Sa yaram jàmm ? '
              'Ma ngi lay ziar te di la fàttali ci soutoura sunu kóllëre bu tollu ci $formattedAmount '
              'bi waroon faju ba pare ($formattedDate). '
              'Boo amee ak jot ma ngi lay xaar ci jàmm ak soutoura. Jërëjëf !';
        } else {
          return 'Salamalekum $salutationName, na nga def ? Sa yaram jàmm ? '
              'Ma ngi lay ziar te di la fàttali ci soutoura sunu kóllëre bu tollu ci $formattedAmount '
              'bu wara faju ci bisub $formattedDate. '
              'Yàlla na nu Yàlla boole ci jàmm. Jërëjëf !';
        }

      case WhatsAppReminderLanguage.french:
        final salutationName = cleanName.isNotEmpty ? cleanName : 'cher client';
        if (isOverdue) {
          return 'Bonjour $salutationName, j\'espère que vous et votre famille vous portez bien. '
              'Je me permets de vous rappeler avec bienveillance notre accord concernant le montant de $formattedAmount '
              'arrivé à échéance le $formattedDate. '
              'Merci de me faire signe dès que possible, dans le respect et la confiance mutuelle. Excellente journée !';
        } else {
          return 'Bonjour $salutationName, j\'espère que vous et votre famille vous portez bien. '
              'Je vous envoie ce petit rappel amical concernant notre accord pour le montant de $formattedAmount '
              'convenu pour le $formattedDate. '
              'Merci pour votre confiance et excellente journée !';
        }
    }
  }
}
