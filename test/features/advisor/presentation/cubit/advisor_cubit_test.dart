import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/advisor/domain/entities/financial_health_entity.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_cubit.dart';
import 'package:tekki/features/advisor/presentation/cubit/advisor_state.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockEvaluateFinancialHealthUseCase mockUseCase;
  late AdvisorCubit cubit;

  final fixedHealth = createTestFinancialHealth();

  setUp(() {
    mockUseCase = MockEvaluateFinancialHealthUseCase();
    cubit = AdvisorCubit(evaluateFinancialHealthUseCase: mockUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('AdvisorCubit', () {
    test('initial state is AdvisorInitial', () {
      expect(cubit.state, equals(const AdvisorInitial()));
    });

    blocTest<AdvisorCubit, AdvisorState>(
      'emits [AdvisorLoading, AdvisorLoaded] when loadFinancialHealth succeeds',
      build: () {
        when(
          () => mockUseCase(
            asOf: any<DateTime?>(named: 'asOf'),
            windowDays: any<int>(named: 'windowDays'),
          ),
        ).thenAnswer((_) async => Success(fixedHealth));
        return cubit;
      },
      act: (cubit) => cubit.loadFinancialHealth(),
      expect: () => [
        const AdvisorLoading(),
        AdvisorLoaded(financialHealth: fixedHealth),
      ],
      verify: (_) {
        verify(
          () => mockUseCase(
            asOf: any<DateTime?>(named: 'asOf'),
            windowDays: any<int>(named: 'windowDays'),
          ),
        ).called(1);
      },
    );

    blocTest<AdvisorCubit, AdvisorState>(
      'emits [AdvisorLoading, AdvisorError] when loadFinancialHealth fails',
      build: () {
        when(
          () => mockUseCase(
            asOf: any<DateTime?>(named: 'asOf'),
            windowDays: any<int>(named: 'windowDays'),
          ),
        ).thenAnswer(
          (_) async => const Error<FinancialHealthEntity, Failure>(
            DatabaseFailure(message: 'Lecture échouée'),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadFinancialHealth(),
      expect: () => [
        const AdvisorLoading(),
        const AdvisorError(message: 'Lecture échouée'),
      ],
      verify: (_) {
        verify(
          () => mockUseCase(
            asOf: any<DateTime?>(named: 'asOf'),
            windowDays: any<int>(named: 'windowDays'),
          ),
        ).called(1);
      },
    );
  });
}
