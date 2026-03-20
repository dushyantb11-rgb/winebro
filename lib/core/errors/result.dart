/// Sealed Result type for typed error handling.
/// All repository methods return Result<T> — never throw.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  T unwrapOr(T fallback) => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => fallback,
  };

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final failure) => err(failure),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Result.ok(transform(value)),
    Err<T>(:final failure) => Result.err(failure),
  };

  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => transform(value),
    Err<T>(:final failure) => Result.err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Err<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Err($failure)';
}

/// Typed failure hierarchy. Exhaustive switch ensures no case is missed.
sealed class Failure {
  const Failure({required this.message});
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});
  final int? statusCode;
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message, this.code});
  final String? code;
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, required this.field});
  final String field;
}

final class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

