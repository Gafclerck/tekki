import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/repositories/financial_partner_repository.dart';

class GetFinancialPartnersUseCase {
  const GetFinancialPartnersUseCase({required this.repository});

  final FinancialPartnerRepository repository;

  Future<List<FinancialPartnerEntity>> call() async {
    return repository.getPartners();
  }
}
