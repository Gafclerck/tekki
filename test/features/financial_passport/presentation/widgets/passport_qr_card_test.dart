import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_fullscreen_qr_dialog.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_qr_card.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  group('PassportQrCard Widget Tests', () {
    const testBase45 = 'TEKKI-BASE45-PAYLOAD-TEST';
    const testPin = '4821';
    const testSecondsRemaining = 42;

    testWidgets('renders QR code with 150x150dp size and 8dp white padding', (
      tester,
    ) async {
      await tester.pumpTekkiWidget(
        const PassportQrCard(
          base45Payload: testBase45,
          visualPin: testPin,
          secondsRemaining: testSecondsRemaining,
        ),
      );

      expect(find.byKey(const ValueKey('passport-qr-card')), findsOneWidget);

      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      final qrWidget = tester.widget<QrImageView>(qrFinder);
      expect(qrWidget.size, 150.0);

      // Verify the white container padding around the QR code is 8dp
      final inkWellFinder = find.byKey(const ValueKey('qr_code_tap_target'));
      expect(inkWellFinder, findsOneWidget);

      final containerFinder = find.descendant(
        of: inkWellFinder,
        matching: find.byType(Container),
      );
      final containerWidget = tester.widget<Container>(containerFinder.first);
      expect(containerWidget.padding, const EdgeInsets.all(8));
    });

    testWidgets('renders 4-digit PIN badge with exact digits', (tester) async {
      await tester.pumpTekkiWidget(
        const PassportQrCard(
          base45Payload: testBase45,
          visualPin: testPin,
          secondsRemaining: testSecondsRemaining,
        ),
      );

      expect(find.byKey(const ValueKey('pin-code-badge')), findsOneWidget);
      expect(find.text(testPin), findsOneWidget);
      expect(find.text('PIN :'), findsOneWidget);
    });

    testWidgets('renders 1-minute renewal countdown indicator', (tester) async {
      await tester.pumpTekkiWidget(
        const PassportQrCard(
          base45Payload: testBase45,
          visualPin: testPin,
          secondsRemaining: testSecondsRemaining,
        ),
      );

      expect(find.text('42s'), findsOneWidget);
      expect(find.text('Validation anti-rejeu'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('pin_renewal_progress_bar')),
        findsOneWidget,
      );
    });

    testWidgets('tapping QR code triggers onTapQr callback if provided', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpTekkiWidget(
        PassportQrCard(
          base45Payload: testBase45,
          visualPin: testPin,
          secondsRemaining: testSecondsRemaining,
          onTapQr: () => tapped = true,
        ),
      );

      await tester.tap(find.byKey(const ValueKey('qr_code_tap_target')));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets(
      'tapping QR code opens PassportFullscreenQrDialog by default when callback is null',
      (tester) async {
        await tester.pumpTekkiWidget(
          const PassportQrCard(
            base45Payload: testBase45,
            visualPin: testPin,
            secondsRemaining: testSecondsRemaining,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('qr_code_tap_target')));
        await tester.pumpAndSettle();

        expect(find.byType(PassportFullscreenQrDialog), findsOneWidget);
        expect(
          find.byKey(const ValueKey('passport_fullscreen_qr_container')),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping zoom button opens fullscreen dialog', (tester) async {
      await tester.pumpTekkiWidget(
        const PassportQrCard(
          base45Payload: testBase45,
          visualPin: testPin,
          secondsRemaining: testSecondsRemaining,
        ),
      );

      await tester.tap(find.byKey(const ValueKey('zoom_qr_button')));
      await tester.pumpAndSettle();

      expect(find.byType(PassportFullscreenQrDialog), findsOneWidget);
    });
  });
}
