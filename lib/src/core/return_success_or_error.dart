import 'package:meta/meta.dart';

import '../../return_success_or_error.dart';

/// Sealed result type: either a [SuccessReturn] or an [ErrorReturn].
///
/// Always handle it with an exhaustive `switch` over both cases, or use the
/// helpers [fold], [isSuccess]/[isError], [getOrNull] and [getOrElse].
@immutable
sealed class ReturnSuccessOrError<R> {
  const ReturnSuccessOrError();

  /// Resolves both cases at once. Returns the value produced by [onSuccess] when
  /// this is a [SuccessReturn], or by [onError] when it is an [ErrorReturn].
  ///
  /// Avoids the boilerplate of an exhaustive `switch` when you only need to
  /// fold the result into a single value:
  /// ```dart
  /// final message = result.fold(
  ///   onSuccess: (value) => 'OK: $value',
  ///   onError: (error) => 'Fail: ${error.message}',
  /// );
  /// ```
  T fold<T>({
    required T Function(R success) onSuccess,
    required T Function(AppError error) onError,
  }) => switch (this) {
    SuccessReturn<R>(:final result) => onSuccess(result),
    ErrorReturn<R>(:final result) => onError(result),
  };

  /// Whether this result represents a success.
  bool get isSuccess => this is SuccessReturn<R>;

  /// Whether this result represents an error.
  bool get isError => this is ErrorReturn<R>;

  /// Returns the success value, or `null` when this is an [ErrorReturn].
  R? get getOrNull => switch (this) {
    SuccessReturn<R>(:final result) => result,
    ErrorReturn<R>() => null,
  };

  /// Returns the success value, or the value produced by [orElse] (from the
  /// [AppError]) when this is an [ErrorReturn]. Useful for a non-null fallback:
  /// ```dart
  /// final value = result.getOrElse((error) => 'default');
  /// ```
  R getOrElse(R Function(AppError error) orElse) => switch (this) {
    SuccessReturn<R>(:final result) => result,
    ErrorReturn<R>(:final result) => orElse(result),
  };
}

/// Stores the returned data on success.
final class SuccessReturn<R> extends ReturnSuccessOrError<R> {
  /// The success value.
  final R result;

  const SuccessReturn({required R success}) : result = success;

  @override
  String toString() => "Success: $result";
}

/// Stores the returned error on failure.
final class ErrorReturn<R> extends ReturnSuccessOrError<R> {
  /// The failure.
  final AppError result;

  const ErrorReturn({required AppError error}) : result = error;

  @override
  String toString() => "Error: $result";
}

/// Represents `void` as a result value (a single shared instance).
@immutable
final class Unit {
  static final Unit _instance = Unit._();

  factory Unit() => _instance;

  Unit._();

  @override
  String toString() => 'Unit{} - void';
}

/// The shared [Unit] instance.
Unit get unit => Unit();

/// Represents `null` as a result value (a single shared instance).
@immutable
final class Nil {
  static final Nil _instance = Nil._();

  factory Nil() => _instance;

  Nil._();

  @override
  String toString() => 'Nil{} - null';
}

/// The shared [Nil] instance.
Nil get nil => Nil();
