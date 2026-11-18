import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/financing/data/datasources/financial_partner_catalog.dart';
import 'package:tekki/features/financing/domain/repositories/financial_partner_repository.dart';
import 'package:tekki/features/financing/domain/usecases/get_financial_partners_use_case.dart';

class MockFinancialPartnerRepository extends Mock
    implements FinancialPartnerRepository {}

void main() {
  late MockFinancialPartnerRepository mockRepo;
  late GetFinancialPartnersUseCase useCase;

  setUp(() {
    mockRepo = MockFinancialPartnerRepository();
    useCase = GetFinancialPartnersUseCase(repository: mockRepo);
  });

  group('GetFinancialPartnersUseCase Unit Tests', () {
    test('returns partners list from repository', () async {
      when(
        () => mockRepo.getPartners(),
      ).thenAnswer((_) async => FinancialPartnerCatalog.defaultPartners);

      final result = await useCase();

      expect(result.length, equals(4));
      expect(result.first.name, equals('Baobab Sénégal'));
      verify(() => mockRepo.getPartners()).called(1);
    });
  });
}
