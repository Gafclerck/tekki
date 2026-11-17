import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class SecurityFailure extends Failure {
  const SecurityFailure({required super.message});
}

class CryptoFailure extends Failure {
  const CryptoFailure({required super.message});
}
