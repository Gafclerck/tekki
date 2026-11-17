import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';

class WatchActiveDebtsUseCase {
  const WatchActiveDebtsUseCase({required this.repository});

  final DebtRepository repository;

  Stream<List<DebtEntity>> call({int limit = 50}) {
    return repository.watchActiveDebts(limit: limit);
  }
}
