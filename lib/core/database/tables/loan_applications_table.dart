import 'package:drift/drift.dart';

@DataClassName('LoanApplication')
@TableIndex(name: 'loan_applications_shop_idx', columns: {#shopId})
@TableIndex(name: 'loan_applications_status_idx', columns: {#status})
@TableIndex(name: 'loan_applications_sync_idx', columns: {#syncStatus})
class LoanApplications extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text().named('shop_id')();
  TextColumn get partnerId => text().named('partner_id')();
  TextColumn get partnerName => text().named('partner_name')();
  IntColumn get requestedAmount => integer().named('requested_amount')();
  IntColumn get durationMonths => integer().named('duration_months')();
  IntColumn get monthlyPaymentEstimate =>
      integer().named('monthly_payment_estimate')();
  TextColumn get purpose => text().named('purpose')();
  TextColumn get status =>
      text().named('status').withDefault(const Constant('PENDING'))();
  IntColumn get passportScoreAtSubmission => integer()
      .named('passport_score_at_submission')
      .withDefault(const Constant(0))();
  TextColumn get submissionDate => text().named('submission_date')();
  TextColumn get decisionNotes => text().named('decision_notes').nullable()();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
