import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/services/location_service.dart';

typedef LocationServiceChecker = Future<bool> Function();
typedef PermissionChecker = Future<LocationPermission> Function();
typedef PermissionRequester = Future<LocationPermission> Function();
typedef PositionGetter = Future<Position> Function({
  LocationSettings? locationSettings,
});

/// Concrete [ILocationService] implementation wrapping the `geolocator` package.
/// Guarantees a passive, non-blocking capture with a strict 5-second overall timeout
/// and zero interactive permission prompts during closing.
class GeolocatorLocationService implements ILocationService {
  GeolocatorLocationService({
    this.timeout = const Duration(seconds: AppConstants.locationTimeoutSeconds),
    LocationServiceChecker? isServiceEnabled,
    PermissionChecker? checkPermission,
    PositionGetter? getPosition,
  }) : _isServiceEnabled =
           isServiceEnabled ?? Geolocator.isLocationServiceEnabled,
       _checkPermission = checkPermission ?? Geolocator.checkPermission,
       _getPosition = getPosition ?? Geolocator.getCurrentPosition;

  final Duration timeout;
  final LocationServiceChecker _isServiceEnabled;
  final PermissionChecker _checkPermission;
  final PositionGetter _getPosition;

  Future<GeoLocation?> _captureLocation() async {
    // 1. Check if GPS / Location services are enabled
    final isEnabled = await _isServiceEnabled();
    if (!isEnabled) {
      return null;
    }

    // 2. Check permission without interactive dialog during passive closure
    final permission = await _checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return null;
    }

    // 3. Acquire current position
    final position = await _getPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return GeoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );
  }

  @override
  Future<GeoLocation?> getCurrentLocation({Duration? timeout}) async {
    final effectiveTimeout = timeout ?? this.timeout;

    try {
      // Single overall timeout wrapping the entire execution
      return await _captureLocation().timeout(effectiveTimeout);
    } on TimeoutException {
      return null;
    } catch (_) {
      // Intercept all platform errors, sensor failures, permission dismissals silently
      return null;
    }
  }
}
