import 'package:drift/drift.dart';

@DataClassName('SyncOutboxEntry')
@TableIndex(name: 'sync_outbox_status_idx', columns: {#status})
@TableIndex(name: 'sync_outbox_created_at_idx', columns: {#createdAt})
class SyncOutbox extends Table {
  TextColumn get clientEventId => text().named('client_event_id')();
  TextColumn get eventType => text().named('event_type')();
  TextColumn get targetTable => text().named('target_table')();
  TextColumn get targetId => text().named('target_id')();
  TextColumn get payloadJson => text().named('payload_json')();
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();
  TextColumn get status =>
      text().named('status').withDefault(const Constant('PENDING'))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get lastAttemptAt => text().named('last_attempt_at').nullable()();
  TextColumn get errorMessage => text().named('error_message').nullable()();

  @override
  Set<Column> get primaryKey => {clientEventId};
}
