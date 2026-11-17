import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/services/audio_service.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/collect_debt_payment_cubit.dart';
import 'package:tekki/features/karne_bor/presentation/cubit/collect_debt_payment_state.dart';

class MockRecordDebtPaymentUseCase extends Mock
    implements RecordDebtPaymentUseCase {}

class MockAudioPlayerService extends Mock implements IAudioPlayerService {}

void main() {
  late MockRecordDebtPaymentUseCase mockUseCase;
  late MockAudioPlayerService mockAudioService;
  bool hapticTriggered = false;

  final tDebtor = DebtorEntity(
    id: 'debtor-1',
    name: 'Amadou Diallo',
    createdAt: DateTime.utc(2026, 11, 1),
  );

  final tDebt = DebtEntity(
    id: 'debt-10',
    debtorId: 'debtor-1',
    initialAmount: 8000,
    remainingAmount: 8000,
    dueDate: DateTime.utc(2026, 12, 10),
    status: DebtStatus.active,
    createdAt: DateTime.utc(2026, 11, 1),
    debtor: tDebtor,
  );

  final tCreatedPayment = DebtPaymentEntity(
    id: 'payment-1',
    debtId: 'debt-10',
    paymentAmount: 8000,
    paymentMethod: 'ESPECES',
    paidAt: DateTime.utc(2026, 11, 17),
  );

  setUpAll(() {
    registerFallbackValue(tDebt);
  });

  setUp(() {
    mockUseCase = MockRecordDebtPaymentUseCase();
    mockAudioService = MockAudioPlayerService();
    hapticTriggered = false;
    when(() => mockAudioService.playCashDrawerSound()).thenAnswer((_) async {});
  });

  group('CollectDebtPaymentCubit', () {
    test(
      'initial state has isFullPayment: true, canSubmit: true and correct effective amount',
      () {
        final cubit = CollectDebtPaymentCubit(
          debt: tDebt,
          recordDebtPaymentUseCase: mockUseCase,
          audioPlayerService: mockAudioService,
        );

        expect(cubit.state.debt, tDebt);
        expect(cubit.state.status, CollectDebtPaymentStatus.initial);
        expect(cubit.state.isFullPayment, isTrue);
        expect(cubit.state.effectiveAmount, 8000);
        expect(cubit.state.remainingAfterPayment, 0);
        expect(cubit.state.canSubmit, isTrue);
        cubit.close();
      },
    );

    blocTest<CollectDebtPaymentCubit, CollectDebtPaymentState>(
      'selectCustomPayment switches isFullPayment to false and initializes customAmount',
      build: () => CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      ),
      act: (cubit) => cubit.selectCustomPayment(3000),
      expect: () => [
        CollectDebtPaymentState(
          debt: tDebt,
          isFullPayment: false,
          customAmount: 3000,
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.effectiveAmount, 3000);
        expect(cubit.state.remainingAfterPayment, 5000);
        expect(cubit.state.canSubmit, isTrue);
      },
    );

    blocTest<CollectDebtPaymentCubit, CollectDebtPaymentState>(
      'setCustomAmount sets errorMessage when amount exceeds remainingAmount',
      build: () => CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      ),
      act: (cubit) {
        cubit.selectCustomPayment();
        cubit.setCustomAmount(9000);
      },
      expect: () => [
        CollectDebtPaymentState(
          debt: tDebt,
          isFullPayment: false,
          customAmount: 0,
        ),
        CollectDebtPaymentState(
          debt: tDebt,
          isFullPayment: false,
          customAmount: 9000,
          errorMessage:
              'Le montant ne peut pas dépasser le solde restant (8 000 FCFA).',
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.canSubmit, isFalse);
      },
    );

    blocTest<CollectDebtPaymentCubit, CollectDebtPaymentState>(
      'setCustomAmount sets errorMessage when amount is negative',
      build: () => CollectDebtPaymentCubit(
        debt: tDebt,
        recordDebtPaymentUseCase: mockUseCase,
      ),
      act: (cubit) {
        cubit.selectCustomPayment();
        cubit.setCustomAmount(-100);
      },
      expect: () => [
        CollectDebtPaymentState(
          debt: tDebt,
          isFullPayment: false,
          customAmount: 0,
        ),
        CollectDebtPaymentState(
          debt: tDebt,
          isFullPayment: false,
          customAmount: 0,
          errorMessage: 'Le montant ne peut pas être négatif.',
        ),
      ],
    );

    blocTest<CollectDebtPaymentCubit, CollectDebtPaymentState>(
      'submitPayment emits submitting then success and triggers audio + haptic on success',
      build: () {
        when(
          () => mockUseCase(
            debt: tDebt,
            paymentAmount: 8000,
            paymentMethod: 'ESPECES',
          ),
        ).thenAnswer((_) async => Success(tCreatedPayment));

        return CollectDebtPaymentCubit(
          debt: tDebt,
          recordDebtPaymentUseCase: mockUseCase,
          audioPlayerService: mockAudioService,
          hapticFeedbackCallback: () => hapticTriggered = true,
        );
      },
      act: (cubit) => cubit.submitPayment(),
      expect: () => [
        CollectDebtPaymentState(
          debt: tDebt,
          status: CollectDebtPaymentStatus.submitting,
        ),
        CollectDebtPaymentState(
          debt: tDebt,
          status: CollectDebtPaymentStatus.success,
          createdPayment: tCreatedPayment,
        ),
      ],
      verify: (_) {
        verify(() => mockAudioService.playCashDrawerSound()).called(1);
        expect(hapticTriggered, isTrue);
      },
    );

    blocTest<CollectDebtPaymentCubit, CollectDebtPaymentState>(
      'submitPayment emits submitting then failure on use case error',
      build: () {
        when(
          () => mockUseCase(
            debt: tDebt,
            paymentAmount: 8000,
            paymentMethod: 'ESPECES',
          ),
        ).thenAnswer(
          (_) async => const Error(DatabaseFailure(message: 'Database locked')),
        );

        return CollectDebtPaymentCubit(
          debt: tDebt,
          recordDebtPaymentUseCase: mockUseCase,
          audioPlayerService: mockAudioService,
        );
      },
      act: (cubit) => cubit.submitPayment(),
      expect: () => [
        CollectDebtPaymentState(
          debt: tDebt,
          status: CollectDebtPaymentStatus.submitting,
        ),
        CollectDebtPaymentState(
          debt: tDebt,
          status: CollectDebtPaymentStatus.failure,
          errorMessage: 'Database locked',
        ),
      ],
    );
  });
}
