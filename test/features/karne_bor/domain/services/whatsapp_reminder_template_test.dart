import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/features/karne_bor/domain/services/whatsapp_reminder_template.dart';

void main() {
  final dueDate = DateTime.utc(2026, 11, 20);

  group('WhatsAppReminderTemplate', () {
    group('Wolof', () {
      test('generates polite Wolof message for upcoming / due debt', () {
        final message = WhatsAppReminderTemplate.generate(
          debtorName: 'Modou Fall',
          remainingAmount: 15000,
          dueDate: dueDate,
          language: WhatsAppReminderLanguage.wolof,
          isOverdue: false,
        );

        expect(message, contains('Salamalekum Modou Fall'));
        expect(message, contains('15 000 FCFA'));
        expect(message, contains('20/11/2026'));
        expect(message, contains('bu wara faju'));
        expect(message, contains('soutoura'));
        expect(message, contains('Jërëjëf !'));
      });

      test('generates polite Wolof message for overdue debt with soutoura', () {
        final message = WhatsAppReminderTemplate.generate(
          debtorName: 'Fatou Kiné',
          remainingAmount: 5000,
          dueDate: dueDate,
          language: WhatsAppReminderLanguage.wolof,
          isOverdue: true,
        );

        expect(message, contains('Salamalekum Fatou Kiné'));
        expect(message, contains('5 000 FCFA'));
        expect(message, contains('waroon faju ba pare'));
        expect(message, contains('soutoura'));
      });

      test(
        'uses fallback salutation when debtorName is empty or whitespace in Wolof',
        () {
          final message = WhatsAppReminderTemplate.generate(
            debtorName: '   ',
            remainingAmount: 2500,
            dueDate: dueDate,
            language: WhatsAppReminderLanguage.wolof,
            isOverdue: false,
          );

          expect(message, contains('Salamalekum sama xarit'));
        },
      );
    });

    group('French', () {
      test('generates benevolent French message for upcoming / due debt', () {
        final message = WhatsAppReminderTemplate.generate(
          debtorName: 'Ousmane Sarr',
          remainingAmount: 20000,
          dueDate: dueDate,
          language: WhatsAppReminderLanguage.french,
          isOverdue: false,
        );

        expect(message, contains('Bonjour Ousmane Sarr'));
        expect(message, contains('20 000 FCFA'));
        expect(message, contains('20/11/2026'));
        expect(message, contains('rappel amical'));
        expect(message, contains('confiance'));
      });

      test(
        'generates benevolent French message for overdue debt without aggressive words',
        () {
          final message = WhatsAppReminderTemplate.generate(
            debtorName: 'Awa Diop',
            remainingAmount: 12000,
            dueDate: dueDate,
            language: WhatsAppReminderLanguage.french,
            isOverdue: true,
          );

          expect(message, contains('Bonjour Awa Diop'));
          expect(message, contains('12 000 FCFA'));
          expect(message, contains('rappel'));
          expect(message, contains('bienveillance'));
          expect(message, contains('respect et la confiance mutuelle'));

          // Never aggressive
          expect(message.toLowerCase(), isNot(contains('pénalité')));
          expect(message.toLowerCase(), isNot(contains('amende')));
          expect(message.toLowerCase(), isNot(contains('avocat')));
          expect(message.toLowerCase(), isNot(contains('menace')));
        },
      );

      test(
        'uses fallback salutation when debtorName is empty or whitespace in French',
        () {
          final message = WhatsAppReminderTemplate.generate(
            debtorName: '',
            remainingAmount: 3000,
            dueDate: dueDate,
            language: WhatsAppReminderLanguage.french,
            isOverdue: true,
          );

          expect(message, contains('Bonjour cher client'));
        },
      );
    });
  });
}
