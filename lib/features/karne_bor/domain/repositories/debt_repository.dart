import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';

abstract class DebtRepository {
  Future<Result<DebtorEntity, Failure>> createDebtor(DebtorEntity debtor);
  Future<Result<DebtorEntity?, Failure>> getDebtorById(String id);
  Future<Result<DebtorEntity?, Failure>> findDebtorByName(String name);
  Future<Result<List<DebtorEntity>, Failure>> searchDebtors(
    String query, {
    int limit = 20,
  });
  Future<Result<List<DebtorEntity>, Failure>> getAllDebtors({int limit = 50});
  Stream<List<DebtorEntity>> watchAllDebtors({int limit = 50});

  Future<Result<DebtEntity, Failure>> recordDebtWithDebtor({
    required DebtorEntity debtor,
    required DebtEntity debt,
    bool isNewDebtor = true,
  });

  Future<Result<DebtEntity?, Failure>> getDebtById(String id);
  Future<Result<List<DebtEntity>, Failure>> getDebtsByDebtor(String debtorId);
  Future<Result<List<DebtEntity>, Failure>> getActiveDebts({
    int limit = 50,
    int? offset,
  });
  Stream<List<DebtEntity>> watchActiveDebts({int limit = 50});
  Stream<List<DebtEntity>> watchAllDebtsWithDebtor({int limit = 50});
}
