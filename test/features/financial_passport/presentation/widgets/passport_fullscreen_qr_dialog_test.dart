import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tekki/features/financial_passport/presentation/widgets/passport_fullscreen_qr_dialog.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  group('PassportFullscreenQrDialog Widget Tests', () {
    const testBase45 = 'TEKKI-BASE45-FULLSCREEN';
    const testPin = '9942';
    const testSecondsRemaining = 25;

    testWidgets('renders dialog with 260dp QR code and visual PIN badge', (
      tester,
    ) async {
      await tester.pumpTekkiWidget(
        const PassportFullscreenQrDialog(
          base45Payload: testBase45,
          visualPin: testPin,
          secondsRemaining: testSecondsRemaining,
        ),
      );

      expect(
        find.byKey(const ValueKey('passport_fullscreen_qr_container')),
        findsOneWidget,
      );

      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      final qrWidget = tester.widget<QrImageView>(qrFinder);
      expect(qrWidget.size, 260.0);

      expect(
        find.byKey(const ValueKey('fullscreen_pin_badge')),
        findsOneWidget,
      );
      expect(find.text(testPin), findsOneWidget);
      expect(find.text('Renouvellement dans 25s'), findsOneWidget);
    });

    testWidgets('tapping close button pops dialog', (tester) async {
      await tester.pumpTekkiWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              PassportFullscreenQrDialog.show(
                context,
                base45Payload: testBase45,
                visualPin: testPin,
                secondsRemaining: testSecondsRemaining,
              );
            },
            child: const Text('Open'),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(PassportFullscreenQrDialog), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('close_fullscreen_qr_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PassportFullscreenQrDialog), findsNothing);
    });
  });
}
