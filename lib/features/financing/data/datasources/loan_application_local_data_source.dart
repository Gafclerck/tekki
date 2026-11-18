import 'package:drift/drift.dart';
import 'package:tekki/core/database/app_database.dart';
import 'package:tekki/core/errors/exceptions.dart';
import 'package:tekki/features/financing/domain/entities/loan_application_entity.dart';

abstract class LoanApplicationLocalDataSource {
  Future<void> insertApplication(LoanApplicationEntity application);
  Stream<List<LoanApplicationEntity>> watchApplications({
    required String shopId,
  });
  Future<List<LoanApplicationEntity>> getApplications({required String shopId});
  Future<void> deleteAllApplications();
}

class LoanApplicationLocalDataSourceImpl
    implements LoanApplicationLocalDataSource {
  const LoanApplicationLocalDataSourceImpl({required AppDatabase database})
    : _db = database;

  final AppDatabase _db;

  LoanApplicationEntity _toEntity(LoanApplication row) {
    return LoanApplicationEntity(
      id: row.id,
      shopId: row.shopId,
      partnerId: row.partnerId,
      partnerName: row.partnerName,
      requestedAmount: row.requestedAmount,
      durationMonths: row.durationMonths,
      monthlyPaymentEstimate: row.monthlyPaymentEstimate,
      purpose: LoanPurposeX.fromString(row.purpose),
      status: LoanStatusX.fromString(row.status),
      submissionDate: DateTime.parse(row.submissionDate),
      passportScoreAtSubmission: row.passportScoreAtSubmission,
      decisionNotes: row.decisionNotes,
      createdAt: DateTime.tryParse(row.createdAt),
    );
  }

  @override
  Future<void> insertApplication(LoanApplicationEntity application) async {
    try {
      await _db
          .into(_db.loanApplications)
          .insert(
            LoanApplicationsCompanion(
              id: Value(application.id),
              shopId: Value(application.shopId),
              partnerId: Value(application.partnerId),
              partnerName: Value(application.partnerName),
              requestedAmount: Value(application.requestedAmount),
              durationMonths: Value(application.durationMonths),
              monthlyPaymentEstimate: Value(application.monthlyPaymentEstimate),
              purpose: Value(application.purpose.name),
              status: Value(application.status.name.toUpperCase()),
              passportScoreAtSubmission: Value(
                application.passportScoreAtSubmission,
              ),
              submissionDate: Value(
                application.submissionDate.toIso8601String(),
              ),
              decisionNotes: Value(application.decisionNotes),
              syncStatus: const Value('pending'),
              createdAt: Value(
                (application.createdAt ?? DateTime.now()).toIso8601String(),
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
    } catch (e) {
      throw DatabaseException(
        'Erreur lors de l\'enregistrement de la demande de prêt : $e',
      );
    }
  }

  @override
  Stream<List<LoanApplicationEntity>> watchApplications({
    required String shopId,
  }) {
    final query = _db.select(_db.loanApplications)
      ..where((tbl) => tbl.shopId.equals(shopId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<LoanApplicationEntity>> getApplications({
    required String shopId,
  }) async {
    try {
      final query = _db.select(_db.loanApplications)
        ..where((tbl) => tbl.shopId.equals(shopId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
      final rows = await query.get();
      return rows.map(_toEntity).toList();
    } catch (e) {
      throw DatabaseException(
        'Erreur lors de la récupération des demandes de prêt : $e',
      );
    }
  }

  @override
  Future<void> deleteAllApplications() async {
    try {
      await _db.delete(_db.loanApplications).go();
    } catch (e) {
      throw DatabaseException(
        'Erreur lors de la suppression des demandes de prêt : $e',
      );
    }
  }
}
