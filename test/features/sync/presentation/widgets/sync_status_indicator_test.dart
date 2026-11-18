import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tekki/features/sync/domain/entities/sync_status_summary_entity.dart';
import 'package:tekki/features/sync/presentation/cubit/sync_state.dart';
import 'package:tekki/features/sync/presentation/widgets/sync_status_indicator.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  late MockSyncCubit mockCubit;

  setUp(() {
    mockCubit = MockSyncCubit();
  });

  group('SyncStatusIndicator Widget Tests', () {
    testWidgets('Renders static fallback when no cubit is registered', (
      tester,
    ) async {
      await tester.pumpTekkiWidget(const SyncStatusIndicator());

      expect(
        find.byKey(const ValueKey('sync_status_indicator')),
        findsOneWidget,
      );
      expect(find.text('100% Hors-ligne'), findsOneWidget);
    });

    testWidgets('Renders "Synchronisé" when fully synced and online', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const SyncState(
          summary: SyncStatusSummaryEntity(
            pendingCount: 0,
            failedCount: 0,
            syncedCount: 5,
            isOnline: true,
          ),
        ),
      );

      await tester.pumpTekkiWidget(SyncStatusIndicator(cubit: mockCubit));

      expect(find.text('Synchronisé'), findsOneWidget);
    });

    testWidgets('Renders "3 en attente" when pendingCount > 0 and online', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const SyncState(
          summary: SyncStatusSummaryEntity(
            pendingCount: 3,
            failedCount: 0,
            syncedCount: 5,
            isOnline: true,
          ),
        ),
      );

      await tester.pumpTekkiWidget(SyncStatusIndicator(cubit: mockCubit));

      expect(find.text('3 en attente'), findsOneWidget);
    });

    testWidgets('Renders "Hors-ligne (2)" when offline with pending', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const SyncState(
          summary: SyncStatusSummaryEntity(
            pendingCount: 2,
            failedCount: 0,
            syncedCount: 5,
            isOnline: false,
          ),
        ),
      );

      await tester.pumpTekkiWidget(SyncStatusIndicator(cubit: mockCubit));

      expect(find.text('Hors-ligne (2)'), findsOneWidget);
    });

    testWidgets(
      'Renders "Synchronisation..." with progress indicator when isSyncing is true',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const SyncState(
            isSyncing: true,
            summary: SyncStatusSummaryEntity(
              pendingCount: 1,
              failedCount: 0,
              syncedCount: 5,
              isOnline: true,
            ),
          ),
        );

        await tester.pumpTekkiWidget(SyncStatusIndicator(cubit: mockCubit));

        expect(find.text('Synchronisation...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('Tapping triggers cubit.syncNow() and shows SnackBar', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const SyncState(
          summary: SyncStatusSummaryEntity(
            pendingCount: 2,
            failedCount: 0,
            syncedCount: 5,
            isOnline: true,
          ),
        ),
      );
      when(() => mockCubit.syncNow()).thenAnswer((_) async {});

      await tester.pumpTekkiWidget(SyncStatusIndicator(cubit: mockCubit));

      await tester.tap(find.byKey(const ValueKey('sync_status_indicator')));
      await tester.pump();

      verify(() => mockCubit.syncNow()).called(1);
      expect(
        find.byKey(const ValueKey('sync_status_snackbar')),
        findsOneWidget,
      );
      expect(
        find.text('2 transaction(s) en attente de synchronisation'),
        findsOneWidget,
      );
    });
  });
}
