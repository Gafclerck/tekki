import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/utils/haversine_calculator.dart';

void main() {
  group('HaversineCalculator', () {
    test('returns 0.0 for identical coordinates', () {
      final distance = HaversineCalculator.calculateDistance(
        lat1: 14.6937,
        lon1: -17.44406,
        lat2: 14.6937,
        lon2: -17.44406,
      );
      expect(distance, equals(0.0));
    });

    test('returns 0.0 for identical coordinates at (0, 0)', () {
      final distance = HaversineCalculator.distance(0.0, 0.0, 0.0, 0.0);
      expect(distance, equals(0.0));
    });

    test('calculates nominal distance ~35m accurately (< 200m geofence)', () {
      // Reference shop: Marché Sandaga, Dakar (14.67100, -17.43800)
      const shopLat = 14.67100;
      const shopLon = -17.43800;
      // Offset ~35m North (0.000315 deg lat ~ 35.0m)
      const clientLat = 14.671315;
      const clientLon = -17.43800;

      final dist = HaversineCalculator.calculateDistance(
        lat1: clientLat,
        lon1: clientLon,
        lat2: shopLat,
        lon2: shopLon,
      );

      expect(dist, greaterThan(34.0));
      expect(dist, lessThan(36.0));
      expect(dist, lessThanOrEqualTo(AppConstants.shopGeofenceRadiusMeters));
    });

    test('calculates distance ~450m accurately (> 200m geofence)', () {
      const shopLat = 14.67100;
      const shopLon = -17.43800;
      // Offset ~450m East (at 14.67 deg, 1 deg lon is ~107.5 km, 450m is ~0.004186 deg)
      const clientLat = 14.67100;
      const clientLon = -17.433814;

      final dist = HaversineCalculator.calculateDistance(
        lat1: clientLat,
        lon1: clientLon,
        lat2: shopLat,
        lon2: shopLon,
      );

      expect(dist, greaterThan(440.0));
      expect(dist, lessThan(460.0));
      expect(dist, greaterThan(AppConstants.shopGeofenceRadiusMeters));
    });

    test('calculates known long-distance route (Dakar to Paris ~4200 km)', () {
      // Dakar: 14.6937, -17.4441
      // Paris: 48.8566, 2.3522
      final dist = HaversineCalculator.calculateDistance(
        lat1: 14.6937,
        lon1: -17.4441,
        lat2: 48.8566,
        lon2: 2.3522,
      );

      // Known great-circle distance is approx 4,200 km
      expect(dist, greaterThan(4150000.0));
      expect(dist, lessThan(4250000.0));
    });

    test('handles antipodal points safely without domain NaN error', () {
      final dist = HaversineCalculator.calculateDistance(
        lat1: 90.0,
        lon1: 0.0,
        lat2: -90.0,
        lon2: 0.0,
      );

      // Half circumference: pi * R = 3.14159265 * 6371000 ~= 20,015,087 m
      expect(dist, greaterThan(20000000.0));
      expect(dist.isNaN, isFalse);
    });

    test('is symmetric: distance(A, B) == distance(B, A)', () {
      final d1 = HaversineCalculator.calculateDistance(
        lat1: 14.7167,
        lon1: -17.4677,
        lat2: 14.6937,
        lon2: -17.4441,
      );
      final d2 = HaversineCalculator.calculateDistance(
        lat1: 14.6937,
        lon1: -17.4441,
        lat2: 14.7167,
        lon2: -17.4677,
      );
      expect((d1 - d2).abs(), lessThan(1e-9));
    });
  });
}
