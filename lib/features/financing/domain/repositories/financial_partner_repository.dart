import 'package:tekki/features/financing/domain/entities/financial_partner_entity.dart';

abstract class FinancialPartnerRepository {
  Future<List<FinancialPartnerEntity>> getPartners();
  Future<FinancialPartnerEntity?> getPartnerById(String id);
}
