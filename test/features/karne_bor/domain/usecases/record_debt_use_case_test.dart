import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_status.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';
import 'package:tekki/features/karne_bor/domain/usecases/record_debt_use_case.dart';
import 'package:uuid/uuid.dart';

class MockDebtRepository extends Mock implements DebtRepository {}

class MockUuid extends Mock implements Uuid {}

class FakeDebtorEntity extends Fake implements DebtorEntity {}

class FakeDebtEntity extends Fake implements DebtEntity {}

void main() {
  late MockDebtRepository mockRepository;
  late MockUuid mockUuid;
  late RecordDebtUseCase useCase;
  var uuidCount = 0;

  final testDate = DateTime.utc(2026, 11, 17, 12, 0);

  setUpAll(() {
    registerFallbackValue(FakeDebtorEntity());
    registerFallbackValue(FakeDebtEntity());
  });

  setUp(() {
    mockRepository = MockDebtRepository();
    mockUuid = MockUuid();
    uuidCount = 0;
    when(() => mockUuid.v4()).thenAnswer((_) => 'uuid-${++uuidCount}');
    useCase = RecordDebtUseCase(repository: mockRepository, uuid: mockUuid);
  });

  group('RecordDebtUseCase - Nominal & Matrix Cases', () {
    test(
      'Matrix row 1: Nominale - creates debtor and debt atomically',
      () async {
        when(() => mockRepository.findDebtorByName('Fatou Kiné'))
            .thenAnswer((_) async => const Success(null));

        when(
          () => mockRepository.recordDebtWithDebtor(
            debtor: any(named: 'debtor'),
            debt: any(named: 'debt'),
            isNewDebtor: any(named: 'isNewDebtor'),
          ),
        ).thenAnswer((invocation) async {
          final debt = invocation.namedArguments[#debt] as DebtEntity;
          final debtor = invocation.namedArguments[#debtor] as DebtorEntity;
          return Success(debt.copyWith(debtor: debtor));
        });

        final result = await useCase(
          RecordDebtParams(
            debtorName: 'Fatou Kiné',
            debtorPhone: '+221771234567',
            amount: 5000,
            dueDate: testDate.add(const Duration(days: 7)),
          ),
        );

        expect(result.isSuccess, isTrue);
        final debt = (result as Success<DebtEntity, Failure>).data;
        expect(debt.initialAmount, 5000);
        expect(debt.remainingAmount, 5000);
        expect(debt.status, DebtStatus.active);
        expect(debt.syncStatus, 'pending');
        expect(debt.debtor?.name, 'Fatou Kiné');
        expect(debt.debtor?.phoneNumber, '+221771234567');

        verify(
          () => mockRepository.recordDebtWithDebtor(
            debtor: any(
              named: 'debtor',
              that: predicate<DebtorEntity>(
                (d) =>
                    d.name == 'Fatou Kiné' && d.phoneNumber == '+221771234567',
              ),
            ),
            debt: any(
              named: 'debt',
              that: predicate<DebtEntity>(
                (d) =>
                    d.initialAmount == 5000 &&
                    d.remainingAmount == 5000 &&
                    d.status == DebtStatus.active,
              ),
            ),
            isNewDebtor: true,
          ),
        ).called(1);
      },
    );

    test(
      'Matrix row 2: Existing debtor selected by ID reuses debtor',
      () async {
        final existingDebtor = DebtorEntity(
          id: 'existing-id-123',
          name: 'Fatou Kiné',
          phoneNumber: '+221771234567',
          createdAt: testDate,
        );

        when(() => mockRepository.getDebtorById('existing-id-123'))
            .thenAnswer((_) async => Success(existingDebtor));

        when(
          () => mockRepository.recordDebtWithDebtor(
            debtor: any(named: 'debtor'),
            debt: any(named: 'debt'),
            isNewDebtor: any(named: 'isNewDebtor'),
          ),
        ).thenAnswer((invocation) async {
          final debt = invocation.namedArguments[#debt] as DebtEntity;
          return Success(debt.copyWith(debtor: existingDebtor));
        });

        final result = await useCase(
          const RecordDebtParams(
            debtorName: 'Ignored because ID is set',
            amount: 3000,
            existingDebtorId: 'existing-id-123',
          ),
        );

        expect(result.isSuccess, isTrue);
        final debt = (result as Success<DebtEntity, Failure>).data;
        expect(debt.debtorId, 'existing-id-123');
        expect(debt.debtor?.name, 'Fatou Kiné');

        verify(
          () => mockRepository.recordDebtWithDebtor(
            debtor: existingDebtor,
            debt: any(named: 'debt'),
            isNewDebtor: false,
          ),
        ).called(1);
      },
    );

    test('Matrix row 3: Saisie sans numéro de téléphone', () async {
      when(() => mockRepository.findDebtorByName('Modou Fall'))
          .thenAnswer((_) async => const Success(null));

      when(
        () => mockRepository.recordDebtWithDebtor(
          debtor: any(named: 'debtor'),
          debt: any(named: 'debt'),
          isNewDebtor: any(named: 'isNewDebtor'),
        ),
      ).thenAnswer((invocation) async {
        final debt = invocation.namedArguments[#debt] as DebtEntity;
        final debtor = invocation.namedArguments[#debtor] as DebtorEntity;
        return Success(debt.copyWith(debtor: debtor));
      });

      final result = await useCase(
        const RecordDebtParams(
          debtorName: 'Modou Fall',
          debtorPhone: '',
          amount: 15000,
        ),
      );

      expect(result.isSuccess, isTrue);
      final debt = (result as Success<DebtEntity, Failure>).data;
      expect(debt.debtor?.phoneNumber, isNull);
    });

    test(
      'Matrix row 4: Montant zéro ou négatif rejeté avec ValidationFailure',
      () async {
        final resultZero = await useCase(
          const RecordDebtParams(debtorName: 'Ablaye', amount: 0),
        );
        expect(resultZero.isError, isTrue);
        expect(
          (resultZero as Error<DebtEntity, Failure>).failure,
          isA<ValidationFailure>(),
        );

        final resultNeg = await useCase(
          const RecordDebtParams(debtorName: 'Ablaye', amount: -500),
        );
        expect(resultNeg.isError, isTrue);
        expect(
          (resultNeg as Error<DebtEntity, Failure>).failure.message,
          contains('strictement supérieur à zéro'),
        );
      },
    );

    test(
      'Matrix row 5: Nom de client vide rejeté avec ValidationFailure',
      () async {
        final resultEmpty = await useCase(
          const RecordDebtParams(debtorName: '   ', amount: 2500),
        );
        expect(resultEmpty.isError, isTrue);
        expect(
          (resultEmpty as Error<DebtEntity, Failure>).failure,
          isA<ValidationFailure>(),
        );
        expect(resultEmpty.failure.message, contains('nom du client'));
      },
    );

    test(
      'Matrix row 6: Date d\'échéance par défaut sur J+7 si non fournie',
      () async {
        when(() => mockRepository.findDebtorByName('Ibrahima'))
            .thenAnswer((_) async => const Success(null));

        when(
          () => mockRepository.recordDebtWithDebtor(
            debtor: any(named: 'debtor'),
            debt: any(named: 'debt'),
            isNewDebtor: any(named: 'isNewDebtor'),
          ),
        ).thenAnswer((invocation) async {
          final debt = invocation.namedArguments[#debt] as DebtEntity;
          return Success(debt);
        });

        final before = DateTime.now().toUtc();
        final result = await useCase(
          const RecordDebtParams(
            debtorName: 'Ibrahima',
            amount: 1000,
            dueDate: null,
          ),
        );
        final after = DateTime.now().toUtc();

        expect(result.isSuccess, isTrue);
        final debt = (result as Success<DebtEntity, Failure>).data;
        final expectedMin = before.add(const Duration(days: 6, hours: 23));
        final expectedMax = after.add(const Duration(days: 7, hours: 1));
        expect(debt.dueDate.isAfter(expectedMin), isTrue);
        expect(debt.dueDate.isBefore(expectedMax), isTrue);
      },
    );

    test('Matrix row 7: Défaillance SQLite remonte DatabaseFailure', () async {
      when(() => mockRepository.findDebtorByName('Khadim'))
          .thenAnswer((_) async => const Success(null));

      when(
        () => mockRepository.recordDebtWithDebtor(
          debtor: any(named: 'debtor'),
          debt: any(named: 'debt'),
          isNewDebtor: any(named: 'isNewDebtor'),
        ),
      ).thenAnswer(
        (_) async => const Error(
          DatabaseFailure(message: 'Disk I/O error on transaction'),
        ),
      );

      final result = await useCase(
        const RecordDebtParams(debtorName: 'Khadim', amount: 4000),
      );

      expect(result.isError, isTrue);
      expect(
        result.fold(onSuccess: (_) => null, onError: (failure) => failure),
        isA<DatabaseFailure>(),
      );
    });

    test('Reuses existing debtor when matching name is found', () async {
      final existing = DebtorEntity(
        id: 'existing-named-debtor-id',
        name: 'Moussa Diop',
        phoneNumber: '770000000',
        createdAt: testDate,
      );

      when(() => mockRepository.findDebtorByName('Moussa Diop'))
          .thenAnswer((_) async => Success(existing));

      when(
        () => mockRepository.recordDebtWithDebtor(
          debtor: any(named: 'debtor'),
          debt: any(named: 'debt'),
          isNewDebtor: any(named: 'isNewDebtor'),
        ),
      ).thenAnswer((invocation) async {
        final debt = invocation.namedArguments[#debt] as DebtEntity;
        return Success(debt.copyWith(debtor: existing));
      });

      final result = await useCase(
        const RecordDebtParams(debtorName: 'Moussa Diop', amount: 8000),
      );

      expect(result.isSuccess, isTrue);
      final debt = (result as Success<DebtEntity, Failure>).data;
      expect(debt.debtorId, 'existing-named-debtor-id');

      verify(
        () => mockRepository.recordDebtWithDebtor(
          debtor: existing,
          debt: any(named: 'debt'),
          isNewDebtor: false,
        ),
      ).called(1);
    });
  });
}
