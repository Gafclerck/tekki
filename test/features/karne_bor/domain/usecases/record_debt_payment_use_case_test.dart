import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart';
import 'package:uuid/uuid.dart';

class MockDebtRepository extends Mock implements DebtRepository {}
class MockUuid extends Mock implements Uuid {}

void main() {
  late RecordDebtPaymentUseCase useCase;
  late MockDebtRepository mockRepository;
  late MockUuid mockUuid;

  final tDebtor = DebtorEntity(
    id: 'debtor-1',
    name: 'Fatou Sow',
    phoneNumber: '+221771234567',
    createdAt: DateTime.utc(2026, 11, 1),
  );

  final tActiveDebt = DebtEntity(
    id: 'debt-1',
    debtorId: 'debtor-1',
    initialAmount: 10000,
    remainingAmount: 10000,
    dueDate: DateTime.utc(2026, 12, 1),
    status: DebtStatus.active,
    createdAt: DateTime.utc(2026, 11, 1),
    debtor: tDebtor,
  );

  setUpAll(() {
    registerFallbackValue(
      DebtPaymentEntity(
        id: 'fallback-id',
        debtId: 'fallback-debt',
        paymentAmount: 1000,
        paidAt: DateTime.utc(2026, 11, 17),
      ),
    );
    registerFallbackValue(tActiveDebt);
  });

  setUp(() {
    mockRepository = MockDebtRepository();
    mockUuid = MockUuid();
    when(() => mockUuid.v4()).thenReturn('generated-payment-uuid');
    useCase = RecordDebtPaymentUseCase(
      repository: mockRepository,
      uuid: mockUuid,
    );
  });

  group('RecordDebtPaymentUseCase', () {
    test('rejects payment amount <= 0 with ValidationFailure', () async {
      final resultZero = await useCase(debt: tActiveDebt, paymentAmount: 0);
      expect(resultZero.isError, isTrue);
      expect(
        (resultZero as Error<DebtPaymentEntity, Failure>).failure,
        isA<ValidationFailure>(),
      );

      final resultNeg = await useCase(debt: tActiveDebt, paymentAmount: -500);
      expect(resultNeg.isError, isTrue);
      expect(
        (resultNeg as Error<DebtPaymentEntity, Failure>).failure.message,
        contains('strictement positif'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('rejects payment amount exceeding remainingAmount with ValidationFailure', () async {
      final result = await useCase(
        debt: tActiveDebt,
        paymentAmount: 15000,
      );
      expect(result.isError, isTrue);
      final failure = (result as Error<DebtPaymentEntity, Failure>).failure;
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('ne peut pas dépasser le solde restant'));
      verifyZeroInteractions(mockRepository);
    });

    test('records full payment, sets remainingAmount to 0 and status to SETTLED', () async {
      final expectedPayment = DebtPaymentEntity(
        id: 'generated-payment-uuid',
        debtId: 'debt-1',
        paymentAmount: 10000,
        paymentMethod: 'ESPECES',
        paidAt: DateTime.utc(2026, 11, 17),
      );

      when(
        () => mockRepository.recordDebtPayment(
          payment: any(named: 'payment'),
          updatedDebt: any(named: 'updatedDebt'),
        ),
      ).thenAnswer((_) async => Success(expectedPayment));

      final result = await useCase(
        debt: tActiveDebt,
        paymentAmount: 10000,
        paidAt: DateTime.utc(2026, 11, 17),
      );

      expect(result.isSuccess, isTrue);
      final recorded = (result as Success<DebtPaymentEntity, Failure>).data;
      expect(recorded.id, 'generated-payment-uuid');
      expect(recorded.paymentAmount, 10000);
      expect(recorded.paymentMethod, 'ESPECES');

      final captured = verify(
        () => mockRepository.recordDebtPayment(
          payment: captureAny(named: 'payment'),
          updatedDebt: captureAny(named: 'updatedDebt'),
        ),
      ).captured;

      final capturedPayment = captured[0] as DebtPaymentEntity;
      final capturedDebt = captured[1] as DebtEntity;

      expect(capturedPayment.paymentAmount, 10000);
      expect(capturedDebt.remainingAmount, 0);
      expect(capturedDebt.status, DebtStatus.settled);
    });

    test('records partial payment (acompte), reduces remainingAmount and preserves status', () async {
      final expectedPayment = DebtPaymentEntity(
        id: 'generated-payment-uuid',
        debtId: 'debt-1',
        paymentAmount: 4000,
        paymentMethod: 'ESPECES',
        paidAt: DateTime.utc(2026, 11, 17),
      );

      when(
        () => mockRepository.recordDebtPayment(
          payment: any(named: 'payment'),
          updatedDebt: any(named: 'updatedDebt'),
        ),
      ).thenAnswer((_) async => Success(expectedPayment));

      final result = await useCase(
        debt: tActiveDebt,
        paymentAmount: 4000,
        paidAt: DateTime.utc(2026, 11, 17),
      );

      expect(result.isSuccess, isTrue);

      final captured = verify(
        () => mockRepository.recordDebtPayment(
          payment: captureAny(named: 'payment'),
          updatedDebt: captureAny(named: 'updatedDebt'),
        ),
      ).captured;

      final capturedDebt = captured[1] as DebtEntity;
      expect(capturedDebt.remainingAmount, 6000);
      expect(capturedDebt.status, DebtStatus.active);
    });
  });
}
