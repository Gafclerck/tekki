import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/karne_bor/data/datasources/debt_local_data_source.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debt_payment_entity.dart';
import 'package:tekki/features/karne_bor/domain/entities/debtor_entity.dart';
import 'package:tekki/features/karne_bor/domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  DebtRepositoryImpl({required this.localDataSource});

  final DebtLocalDataSource localDataSource;

  @override
  Future<Result<DebtorEntity, Failure>> createDebtor(DebtorEntity debtor) async {
    try {
      await localDataSource.insertDebtor(debtor);
      return Success(debtor);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<DebtorEntity?, Failure>> getDebtorById(String id) async {
    try {
      final debtor = await localDataSource.getDebtorById(id);
      return Success(debtor);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<DebtorEntity?, Failure>> findDebtorByName(String name) async {
    try {
      final debtor = await localDataSource.findDebtorByName(name);
      return Success(debtor);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<DebtorEntity>, Failure>> searchDebtors(
    String query, {
    int limit = 20,
  }) async {
    try {
      final debtors = await localDataSource.searchDebtors(query, limit: limit);
      return Success(debtors);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<DebtorEntity>, Failure>> getAllDebtors({int limit = 50}) async {
    try {
      final debtors = await localDataSource.getAllDebtors(limit: limit);
      return Success(debtors);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Stream<List<DebtorEntity>> watchAllDebtors({int limit = 50}) {
    return localDataSource.watchAllDebtors(limit: limit);
  }

  @override
  Future<Result<DebtEntity, Failure>> recordDebtWithDebtor({
    required DebtorEntity debtor,
    required DebtEntity debt,
    bool isNewDebtor = true,
  }) async {
    try {
      await localDataSource.recordDebtWithDebtor(
        debtor: debtor,
        debt: debt,
        isNewDebtor: isNewDebtor,
      );
      final completeDebt = debt.copyWith(debtor: debtor);
      return Success(completeDebt);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<DebtPaymentEntity, Failure>> recordDebtPayment({
    required DebtPaymentEntity payment,
    required DebtEntity updatedDebt,
  }) async {
    try {
      await localDataSource.recordDebtPayment(
        payment: payment,
        updatedDebt: updatedDebt,
      );
      return Success(payment);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<DebtPaymentEntity>, Failure>> getPaymentsByDebt(
    String debtId,
  ) async {
    try {
      final payments = await localDataSource.getPaymentsByDebt(debtId);
      return Success(payments);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<DebtEntity?, Failure>> getDebtById(String id) async {
    try {
      final debt = await localDataSource.getDebtById(id);
      return Success(debt);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<DebtEntity>, Failure>> getDebtsByDebtor(String debtorId) async {
    try {
      final debts = await localDataSource.getDebtsByDebtor(debtorId);
      return Success(debts);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<DebtEntity>, Failure>> getActiveDebts({
    int limit = 50,
    int? offset,
  }) async {
    try {
      final debts = await localDataSource.getActiveDebts(limit: limit, offset: offset);
      return Success(debts);
    } on DatabaseException catch (e) {
      return Error(DatabaseFailure(message: e.message));
    } catch (e) {
      return Error(DatabaseFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Stream<List<DebtEntity>> watchActiveDebts({int limit = 50}) {
    return localDataSource.watchActiveDebts(limit: limit);
  }

  @override
  Stream<List<DebtEntity>> watchAllDebtsWithDebtor({int limit = 50}) {
    return localDataSource.watchAllDebtsWithDebtor(limit: limit);
  }
}
