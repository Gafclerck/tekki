import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';

class GetDebtorsUseCase {
  const GetDebtorsUseCase({required this.repository});

  final DebtRepository repository;

  Future<Result<List<DebtorEntity>, Failure>> call({
    String? query,
    int limit = 50,
  }) {
    if (query != null && query.trim().isNotEmpty) {
      return repository.searchDebtors(query.trim(), limit: limit);
    }
    return repository.getAllDebtors(limit: limit);
  }
}
