import 'package:tekki/features/financing/data/datasources/financial_partner_catalog.dart';
import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';
import 'package:tekki/features/financing/domain/repositories/financial_partner_repository.dart';

class FinancialPartnerRepositoryImpl implements FinancialPartnerRepository {
  const FinancialPartnerRepositoryImpl();

  @override
  Future<List<FinancialPartnerEntity>> getPartners() async {
    return FinancialPartnerCatalog.defaultPartners;
  }

  @override
  Future<FinancialPartnerEntity?> getPartnerById(String id) async {
    try {
      return FinancialPartnerCatalog.defaultPartners.firstWhere(
        (p) => p.id == id,
      );
    } catch (_) {
      return null;
    }
  }
}
