class DatabaseException implements Exception {
  const DatabaseException(this.message);
  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class SecurityException implements Exception {
  const SecurityException(this.message);
  final String message;

  @override
  String toString() => 'SecurityException: $message';
}
