import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';

class GetClosurePrefillUseCase {
  const GetClosurePrefillUseCase({required this.repository});

  final ClosureRepository repository;

  Future<Result<int, Failure>> call(DateTime cutoffTimestamp) async {
    return repository.getPrefillSalesAmount(cutoffTimestamp.toUtc());
  }
}
