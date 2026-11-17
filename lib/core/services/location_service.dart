import 'package:equatable/equatable.dart';

/// Immutable representation of geographic coordinates in pure Dart.
class GeoLocation extends Equatable {
  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime? timestamp;

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    accuracy,
    altitude,
    timestamp,
  ];
}

/// Abstract contract for location acquisition (DIP / LSP).
/// Implemented by platform-specific adapters (e.g. GeolocatorLocationService)
/// or fake services during tests.
abstract class ILocationService {
  /// Attempts to capture the current geographic position.
  /// Returns [GeoLocation] on success, or `null` if location services are disabled,
  /// permission is denied, a timeout expires, or any platform failure occurs.
  Future<GeoLocation?> getCurrentLocation({Duration? timeout});
}
