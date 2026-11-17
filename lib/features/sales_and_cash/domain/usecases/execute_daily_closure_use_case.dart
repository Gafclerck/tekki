import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/errors/failures.dart';
import 'package:tekki/core/services/location_service.dart';
import 'package:tekki/core/utils/haversine_calculator.dart';
import 'package:tekki/core/utils/result.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/daily_closure_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/entities/shop_entity.dart';
import 'package:tekki/features/sales_and_cash/domain/repositories/closure_repository.dart';
import 'package:uuid/uuid.dart';

class ExecuteDailyClosureUseCase {
  const ExecuteDailyClosureUseCase({
    required this.repository,
    this.locationService,
    this.uuid = const Uuid(),
  });

  final ClosureRepository repository;
  final ILocationService? locationService;
  final Uuid uuid;

  Future<Result<DailyClosureEntity, Failure>> call({
    required DateTime cutoffTimestamp,
    required int totalSalesAmount,
    int totalExpensesAmount = 0,
    int cashCounted = 0,
    int totalCashDebtInflow = 0,
    int totalCreditSalesAmount = 0,
    String shopId = 'default-shop',
    String? closureDate,
    double? gpsLatitude,
    double? gpsLongitude,
    double? distanceMeters,
    bool? isFlaggedLocation,
  }) async {
    if (totalSalesAmount < 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant total des ventes ne peut pas être négatif.',
        ),
      );
    }
    if (totalExpensesAmount < 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant des dépenses ne peut pas être négatif.',
        ),
      );
    }
    if (cashCounted < 0) {
      return const Error(
        ValidationFailure(
          message: 'Le montant des espèces comptées ne peut pas être négatif.',
        ),
      );
    }
    if (totalCashDebtInflow < 0) {
      return const Error(
        ValidationFailure(
          message: 'Les remboursements de dettes ne peuvent pas être négatifs.',
        ),
      );
    }
    if (totalCreditSalesAmount < 0) {
      return const Error(
        ValidationFailure(
          message: 'Les ventes à crédit ne peuvent pas être négatives.',
        ),
      );
    }

    final utcCutoff = cutoffTimestamp.toUtc();
    final dateStr = closureDate ??
        '${utcCutoff.year.toString().padLeft(4, '0')}-${utcCutoff.month.toString().padLeft(2, '0')}-${utcCutoff.day.toString().padLeft(2, '0')}';

    // Passive GPS Location Capture & Haversine Geofencing
    double? finalGpsLat;
    double? finalGpsLon;
    double? finalDistance;
    bool finalIsFlagged;

    GeoLocation? capturedLocation;
    if (locationService != null) {
      try {
        capturedLocation = await locationService!.getCurrentLocation(
          timeout: const Duration(seconds: AppConstants.locationTimeoutSeconds),
        );
      } catch (_) {
        capturedLocation = null;
      }
    }

    final effectiveLat = capturedLocation?.latitude ?? gpsLatitude;
    final effectiveLon = capturedLocation?.longitude ?? gpsLongitude;

    if (effectiveLat == null || effectiveLon == null) {
      // GPS signal unavailable, timed out (5s), or permission denied
      finalGpsLat = null;
      finalGpsLon = null;
      finalDistance = null;
      finalIsFlagged = isFlaggedLocation ?? true;
    } else {
      finalGpsLat = effectiveLat;
      finalGpsLon = effectiveLon;

      // Query shop reference coordinates with fallback to first shop
      final shopResult = await repository.getShopById(shopId);
      var shop = shopResult is Success<ShopEntity?, Failure>
          ? shopResult.data
          : null;

      if (shop == null) {
        final fallbackResult = await repository.getShop();
        shop = fallbackResult is Success<ShopEntity?, Failure>
            ? fallbackResult.data
            : null;
      }

      if (shop == null) {
        // Shop not found in local database: keep GPS, distance is null, flagged
        finalDistance = distanceMeters;
        finalIsFlagged = isFlaggedLocation ?? true;
      } else {
        final calculatedDistance = HaversineCalculator.calculateDistance(
          lat1: effectiveLat,
          lon1: effectiveLon,
          lat2: shop.refLatitude,
          lon2: shop.refLongitude,
        );
        final rawDistance = distanceMeters ?? calculatedDistance;
        if (rawDistance.isNaN || rawDistance.isInfinite) {
          finalDistance = null;
          finalIsFlagged = true;
        } else {
          finalDistance = rawDistance;
          finalIsFlagged = isFlaggedLocation ??
              (finalDistance > AppConstants.shopGeofenceRadiusMeters);
        }
      }
    }

    try {
      final closure = DailyClosureEntity(
        id: uuid.v4(),
        shopId: shopId,
        closureDate: dateStr,
        cutoffTimestamp: utcCutoff,
        totalSalesAmount: totalSalesAmount,
        totalExpensesAmount: totalExpensesAmount,
        cashCounted: cashCounted,
        totalCashDebtInflow: totalCashDebtInflow,
        totalCreditSalesAmount: totalCreditSalesAmount,
        gpsLatitude: finalGpsLat,
        gpsLongitude: finalGpsLon,
        distanceMeters: finalDistance,
        isFlaggedLocation: finalIsFlagged,
        syncStatus: 'pending',
        createdAt: DateTime.now().toUtc(),
      );

      return await repository.executeDailyClosure(closure);
    } catch (e) {
      return Error(ValidationFailure(message: e.toString()));
    }
  }
}
