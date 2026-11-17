import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekki/core/services/geolocator_location_service.dart';
import 'package:tekki/core/services/location_service.dart';

/// Fake in-memory location service for testing domain & presentation layers.
class FakeLocationService implements ILocationService {
  FakeLocationService({this.nextLocation, this.shouldDelay = Duration.zero});

  GeoLocation? nextLocation;
  Duration shouldDelay;

  @override
  Future<GeoLocation?> getCurrentLocation({Duration? timeout}) async {
    if (shouldDelay > Duration.zero) {
      if (timeout != null && shouldDelay > timeout) {
        await Future<void>.delayed(timeout);
        return null;
      }
      await Future<void>.delayed(shouldDelay);
    }
    return nextLocation;
  }
}

void main() {
  group('GeoLocation Entity', () {
    test('supports value equality via Equatable', () {
      const loc1 = GeoLocation(
        latitude: 14.6937,
        longitude: -17.4441,
        accuracy: 10.0,
      );
      const loc2 = GeoLocation(
        latitude: 14.6937,
        longitude: -17.4441,
        accuracy: 10.0,
      );
      expect(loc1, equals(loc2));
    });
  });

  group('FakeLocationService', () {
    test('returns pre-configured location', () async {
      final fake = FakeLocationService(
        nextLocation: const GeoLocation(latitude: 14.7, longitude: -17.4),
      );
      final loc = await fake.getCurrentLocation();
      expect(loc?.latitude, equals(14.7));
      expect(loc?.longitude, equals(-17.4));
    });

    test(
      'returns null when configured to simulate failure/unavailable',
      () async {
        final fake = FakeLocationService(nextLocation: null);
        final loc = await fake.getCurrentLocation();
        expect(loc, isNull);
      },
    );

    test('respects timeout when delayed', () async {
      final fake = FakeLocationService(
        nextLocation: const GeoLocation(latitude: 14.7, longitude: -17.4),
        shouldDelay: const Duration(milliseconds: 100),
      );
      final loc = await fake.getCurrentLocation(
        timeout: const Duration(milliseconds: 10),
      );
      expect(loc, isNull);
    });
  });

  group('GeolocatorLocationService (Adapter)', () {
    final fixedTimestamp = DateTime.utc(2026, 11, 17, 12, 0);

    Position createPosition({
      double latitude = 14.6937,
      double longitude = -17.4441,
    }) {
      return Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: fixedTimestamp,
        accuracy: 5.0,
        altitude: 12.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }

    test(
      'returns GeoLocation on nominal enabled and permitted capture',
      () async {
        final service = GeolocatorLocationService(
          isServiceEnabled: () async => true,
          checkPermission: () async => LocationPermission.always,
          getPosition: ({locationSettings}) async => createPosition(),
        );

        final loc = await service.getCurrentLocation();
        expect(loc, isNotNull);
        expect(loc?.latitude, equals(14.6937));
        expect(loc?.longitude, equals(-17.4441));
        expect(loc?.accuracy, equals(5.0));
      },
    );

    test('returns null without prompting interactive permission dialog when status is denied', () async {
      final service = GeolocatorLocationService(
        isServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.denied,
        getPosition: ({locationSettings}) async => createPosition(),
      );

      final loc = await service.getCurrentLocation();
      expect(loc, isNull);
    });

    test('returns null silently when location service is disabled', () async {
      final service = GeolocatorLocationService(
        isServiceEnabled: () async => false,
      );

      final loc = await service.getCurrentLocation();
      expect(loc, isNull);
    });

    test('returns null silently when permission is denied', () async {
      final service = GeolocatorLocationService(
        isServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.denied,
      );

      final loc = await service.getCurrentLocation();
      expect(loc, isNull);
    });

    test('returns null silently when permission is deniedForever', () async {
      final service = GeolocatorLocationService(
        isServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.deniedForever,
      );

      final loc = await service.getCurrentLocation();
      expect(loc, isNull);
    });

    test(
      'returns null silently when position capture exceeds timeout',
      () async {
        final service = GeolocatorLocationService(
          timeout: const Duration(milliseconds: 30),
          isServiceEnabled: () async => true,
          checkPermission: () async => LocationPermission.always,
          getPosition: ({locationSettings}) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return createPosition();
          },
        );

        final loc = await service.getCurrentLocation();
        expect(loc, isNull);
      },
    );

    test('returns null silently on platform exception', () async {
      final service = GeolocatorLocationService(
        isServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.always,
        getPosition: ({locationSettings}) async {
          throw Exception('PlatformChannel GPS failure');
        },
      );

      final loc = await service.getCurrentLocation();
      expect(loc, isNull);
    });
  });
}
