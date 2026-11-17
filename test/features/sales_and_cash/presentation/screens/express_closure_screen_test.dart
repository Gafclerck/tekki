import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/theme/app_colors.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart';
import 'package:tekki/features/sales_and_cash/presentation/cubit/express_closure_state.dart';
import 'package:tekki/features/sales_and_cash/presentation/screens/express_closure_screen.dart';

class MockExpressClosureCubit extends MockCubit<ExpressClosureState>
    implements ExpressClosureCubit {}

class MockAudioPlayerService extends Mock implements IAudioPlayerService {}

void main() {
  late MockExpressClosureCubit mockCubit;
  final fixedCutoff = DateTime(2026, 11, 17, 21, 0).toUtc();

  setUp(() {
    mockCubit = MockExpressClosureCubit();
  });

  Widget buildSubject({
    IAudioPlayerService? audioPlayerService,
    void Function(DailyClosureEntity)? onClosureSuccess,
  }) {
    return MaterialApp(
      home: ExpressClosureScreen(
        cubit: mockCubit,
        audioPlayerService: audioPlayerService,
        onClosureSuccess: onClosureSuccess,
      ),
    );
  }

  group('ExpressClosureScreen Widget UI', () {
    testWidgets(
      'renders all initial elements: top bar, timer badge, 3 steps, streak and CTA',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.ready,
            prefilledSalesAmount: 17500,
            totalSalesAmount: 17500,
            totalExpensesAmount: 2500,
            cashCounted: 15000,
          ),
        );

        await tester.pumpWidget(buildSubject());

        // Top bar title & date
        expect(find.text('Clôture de Caisse'), findsOneWidget);
        expect(find.textContaining('Mardi 17 Novembre'), findsOneWidget);
        expect(find.byKey(const ValueKey('back_button')), findsOneWidget);

        // Timer & reassurance badge
        expect(find.byKey(const ValueKey('timer_badge')), findsOneWidget);
        expect(find.text('< 30 secondes'), findsOneWidget);
        expect(find.text('Étape 1/3'), findsOneWidget);

        // Step 1: Sales
        expect(find.byKey(const ValueKey('step_1_card')), findsOneWidget);
        expect(find.text('1. Total Encaissé Aujourd’hui'), findsOneWidget);
        expect(find.byKey(const ValueKey('sales_input_field')), findsOneWidget);

        // Step 2: Expenses
        expect(find.byKey(const ValueKey('step_2_card')), findsOneWidget);
        expect(find.text('2. Dépenses / Achats du Jour'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('expenses_input_field')),
          findsOneWidget,
        );

        // Step 3: Cash counted
        expect(find.byKey(const ValueKey('step_3_card')), findsOneWidget);
        expect(
          find.text('3. Espèces en Caisse à la Fermeture'),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cash_counted_input_field')),
          findsOneWidget,
        );

        // Streak banner
        expect(find.byKey(const ValueKey('streak_banner')), findsOneWidget);
        expect(
          find.text('Clôture quotidienne · Série active !'),
          findsOneWidget,
        );
        expect(find.textContaining('Ancrage GPS'), findsOneWidget);

        // Bottom CTA Button
        expect(
          find.byKey(const ValueKey('button-validate-closure')),
          findsOneWidget,
        );
        expect(find.text('Valider et Verrouiller la Caisse'), findsOneWidget);
      },
    );

    testWidgets(
      'validation CTA button has minHeight >= 52dp and accent color',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.ready,
          ),
        );

        await tester.pumpWidget(buildSubject());

        final buttonFinder = find.byKey(
          const ValueKey('button-validate-closure'),
        );
        expect(buttonFinder, findsOneWidget);

        final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
        final bg = buttonWidget.style?.backgroundColor?.resolve({});
        expect(bg, equals(AppColors.accent));

        final renderBox = tester.renderObject<RenderBox>(buttonFinder);
        expect(renderBox.size.height, greaterThanOrEqualTo(52.0));
      },
    );

    testWidgets(
      'prefilled sales amount is displayed in field and hint on transition to ready',
      (tester) async {
        whenListen(
          mockCubit,
          Stream.fromIterable([
            ExpressClosureState(
              cutoffTimestamp: fixedCutoff,
              status: ExpressClosureStatus.loadingPrefill,
            ),
            ExpressClosureState(
              cutoffTimestamp: fixedCutoff,
              status: ExpressClosureStatus.ready,
              prefilledSalesAmount: 94500,
              totalSalesAmount: 94500,
            ),
          ]),
          initialState: ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.loadingPrefill,
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, '94500'), findsOneWidget);
        expect(find.textContaining('94500 FCFA'), findsOneWidget);
      },
    );

    testWidgets('editing fields updates cubit amounts', (tester) async {
      when(() => mockCubit.state).thenReturn(
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.ready,
        ),
      );

      await tester.pumpWidget(buildSubject());

      // Edit Sales
      await tester.enterText(
        find.byKey(const ValueKey('sales_input_field')),
        '108500',
      );
      verify(() => mockCubit.setTotalSales(108500)).called(1);

      // Edit Expenses
      await tester.enterText(
        find.byKey(const ValueKey('expenses_input_field')),
        '15000',
      );
      verify(() => mockCubit.setTotalExpenses(15000)).called(1);

      // Edit Cash counted
      await tester.enterText(
        find.byKey(const ValueKey('cash_counted_input_field')),
        '93500',
      );
      verify(() => mockCubit.setCashCounted(93500)).called(1);
    });

    testWidgets('tapping submit CTA triggers cubit.submitClosure()', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.ready,
          totalSalesAmount: 17500,
          totalExpensesAmount: 2500,
          cashCounted: 15000,
        ),
      );
      when(() => mockCubit.setTotalSales(any())).thenReturn(null);
      when(() => mockCubit.setTotalExpenses(any())).thenReturn(null);
      when(() => mockCubit.setCashCounted(any())).thenReturn(null);
      when(
        () => mockCubit.submitClosure(shopId: any(named: 'shopId')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());

      final buttonFinder = find.byKey(
        const ValueKey('button-validate-closure'),
      );
      await tester.tap(buttonFinder);
      await tester.pump();

      verify(() => mockCubit.submitClosure()).called(1);
    });

    testWidgets(
      'submitting state displays CircularProgressIndicator and disables button',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.submitting,
          ),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        final button = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('button-validate-closure')),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('failure state displays error banner', (tester) async {
      when(() => mockCubit.state).thenReturn(
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.failure,
          errorMessage: 'Échec de la transaction SQL',
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(
        find.byKey(const ValueKey('closure_error_banner')),
        findsOneWidget,
      );
      expect(find.text('Échec de la transaction SQL'), findsOneWidget);
    });

    testWidgets(
      'success state triggers SnackBar and onClosureSuccess callback',
      (tester) async {
        final testClosure = DailyClosureEntity(
          id: 'closure-done-1',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 17500,
        );

        whenListen(
          mockCubit,
          Stream.fromIterable([
            ExpressClosureState(
              cutoffTimestamp: fixedCutoff,
              status: ExpressClosureStatus.submitting,
            ),
            ExpressClosureState(
              cutoffTimestamp: fixedCutoff,
              status: ExpressClosureStatus.success,
              createdClosure: testClosure,
            ),
          ]),
          initialState: ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.submitting,
          ),
        );

        var callbackCalled = false;
        await tester.pumpWidget(
          buildSubject(
            onClosureSuccess: (closure) {
              callbackCalled = true;
              expect(closure.id, equals('closure-done-1'));
            },
          ),
        );

        await tester.pumpAndSettle();

        expect(callbackCalled, isTrue);
        expect(
          find.byKey(const ValueKey('closure_success_snackbar')),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping back button pops the screen', (tester) async {
      when(() => mockCubit.state).thenReturn(
        ExpressClosureState(
          cutoffTimestamp: fixedCutoff,
          status: ExpressClosureStatus.ready,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                key: const ValueKey('open_closure'),
                onPressed: () {
                  Navigator.of(ctx).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExpressClosureScreen(cubit: mockCubit),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.byKey(const ValueKey('open_closure')));
      await tester.pumpAndSettle();

      expect(find.byType(ExpressClosureScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const ValueKey('back_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ExpressClosureScreen), findsNothing);
    });

    testWidgets(
      'dynamic streak banner displays active streak count and monthly closures',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.ready,
            activeStreak: 7,
            monthlyClosuresCount: 18,
          ),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.byKey(const ValueKey('streak_banner')), findsOneWidget);
        expect(
          find.text('Clôture quotidienne · Série active (7 j) !'),
          findsOneWidget,
        );
        expect(
          find.text('7 jours consécutifs · 18 clôtures ce mois-ci'),
          findsOneWidget,
        );
        expect(find.textContaining('Ancrage GPS'), findsOneWidget);
      },
    );

    testWidgets(
      'success state triggers cash drawer sound and haptic feedback safely',
      (tester) async {
        final mockAudio = MockAudioPlayerService();
        when(() => mockAudio.playCashDrawerSound()).thenAnswer((_) async {});

        final testClosure = DailyClosureEntity(
          id: 'closure-audio-test',
          shopId: 'shop-1',
          closureDate: '2026-11-17',
          cutoffTimestamp: fixedCutoff,
          totalSalesAmount: 17500,
        );

        whenListen(
          mockCubit,
          Stream.fromIterable([
            ExpressClosureState(
              cutoffTimestamp: fixedCutoff,
              status: ExpressClosureStatus.submitting,
              activeStreak: 3,
              monthlyClosuresCount: 10,
            ),
            ExpressClosureState(
              cutoffTimestamp: fixedCutoff,
              status: ExpressClosureStatus.success,
              createdClosure: testClosure,
              activeStreak: 4,
              monthlyClosuresCount: 11,
            ),
          ]),
          initialState: ExpressClosureState(
            cutoffTimestamp: fixedCutoff,
            status: ExpressClosureStatus.submitting,
            activeStreak: 3,
            monthlyClosuresCount: 10,
          ),
        );

        await tester.pumpWidget(buildSubject(audioPlayerService: mockAudio));
        await tester.pumpAndSettle();

        verify(() => mockAudio.playCashDrawerSound()).called(1);
        expect(
          find.byKey(const ValueKey('closure_success_snackbar')),
          findsOneWidget,
        );
        expect(find.textContaining('Série : 4 jours'), findsOneWidget);
        expect(find.textContaining('11 ce mois'), findsOneWidget);
      },
    );
  });
}
