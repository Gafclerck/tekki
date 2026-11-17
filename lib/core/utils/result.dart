import 'package:equatable/equatable.dart';
import 'package:tekki/core/errors/failures.dart';

sealed class Result<T, F extends Failure> extends Equatable {
  const Result();

  static Result<T, F> success<T, F extends Failure>(T data) => Success(data);
  static Result<T, F> failure<T, F extends Failure>(F failure) => Error(failure);

  bool get isSuccess => this is Success<T, F>;
  bool get isError => this is Error<T, F>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(F failure) onError,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Error(failure: final failure) => onError(failure),
    };
  }
}

final class Success<T, F extends Failure> extends Result<T, F> {
  const Success(this.data);
  final T data;

  @override
  List<Object?> get props => [data];
}

final class Error<T, F extends Failure> extends Result<T, F> {
  const Error(this.failure);
  final F failure;

  @override
  List<Object?> get props => [failure];
}
