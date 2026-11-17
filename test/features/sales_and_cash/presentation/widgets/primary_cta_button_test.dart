import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/sales_and_cash/presentation/widgets/primary_cta_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> methodCalls = [];

  setUp(() {
    methodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      methodCalls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget buildSubject({
    VoidCallback? onPressed,
    bool isLocked = false,
    String text = '🔒 Clôturer la caisse',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PrimaryCtaButton(
            key: const ValueKey('button-primary-cta'),
            onPressed: onPressed,
            isLocked: isLocked,
            text: text,
          ),
        ),
      ),
    );
  }

  group('PrimaryCtaButton Widget', () {
    testWidgets('renders with correct styling, text, and height >= 52dp',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(onPressed: () {}),
      );

      final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));
      expect(buttonFinder, findsOneWidget);

      // Verify height >= 52dp
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.height, greaterThanOrEqualTo(52.0));

      // Verify text
      expect(find.text('🔒 Clôturer la caisse'), findsOneWidget);

      // Verify ElevatedButton styling
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = elevatedButton.style;
      expect(style?.backgroundColor?.resolve({}), equals(AppColors.accent));
      expect(style?.foregroundColor?.resolve({}), equals(Colors.white));
    });

    testWidgets('triggers onPressed and haptic feedback on single tap',
        (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        buildSubject(onPressed: () => tapCount++),
      );

      final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(tapCount, equals(1));

      // Verify haptic feedback was invoked
      final hasHapticCall = methodCalls.any(
        (call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.lightImpact',
      );
      expect(hasHapticCall, isTrue);
    });

    testWidgets('anti-double-click locks immediately and prevents second tap',
        (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        buildSubject(onPressed: () => tapCount++),
      );

      final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));

      // First tap
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(tapCount, equals(1));

      // Second immediate tap
      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pump();
      expect(tapCount, equals(1)); // Still 1, not 2

      // Verify button is now disabled (onPressed is null)
      final disabledButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(disabledButton.onPressed, isNull);
    });

    testWidgets('disabled when isLocked is true from props', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        buildSubject(onPressed: () => tapCount++, isLocked: true),
      );

      final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pump();
      expect(tapCount, equals(0));
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        buildSubject(onPressed: null),
      );

      final buttonFinder = find.byKey(const ValueKey('button-primary-cta'));
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
