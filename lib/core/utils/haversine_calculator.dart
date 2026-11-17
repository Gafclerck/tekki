import 'dart:math' as math;

/// Utility class for calculating great-circle distance between two geographic coordinates
/// using the Haversine formula in pure Dart (zero Flutter/external dependencies).
abstract final class HaversineCalculator {
  /// Mean Earth radius in meters (WGS 84 spherical approximation).
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates the distance in meters between two points (lat1, lon1) and (lat2, lon2).
  ///
  /// Latitudes must be in degrees [-90, 90].
  /// Longitudes must be in degrees [-180, 180].
  /// Returns 0.0 if the coordinates are identical.
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    if (lat1 == lat2 && lon1 == lon2) {
      return 0.0;
    }

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    final sinDLat2 = math.sin(dLat / 2);
    final sinDLon2 = math.sin(dLon / 2);

    final a =
        sinDLat2 * sinDLat2 +
        math.cos(rLat1) * math.cos(rLat2) * sinDLon2 * sinDLon2;

    // Clamp 'a' to [0, 1] to avoid domain errors with math.asin or math.sqrt
    final clampedA = a.clamp(0.0, 1.0);
    final c = 2 * math.asin(math.sqrt(clampedA));

    return earthRadiusMeters * c;
  }

  /// Positional convenience overload.
  static double distance(double lat1, double lon1, double lat2, double lon2) =>
      calculateDistance(lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2);

  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);
}
