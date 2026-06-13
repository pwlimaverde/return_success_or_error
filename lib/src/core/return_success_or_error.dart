import '../../return_success_or_error.dart';

sealed class ReturnSuccessOrError<R> {
  final AppError? _error;
  final R? _success;
  const ReturnSuccessOrError({
    this._success,
    this._error,
  });

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
  }) =>
      switch (this) {
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
}

///Responsible for storing the returned data when successful.
final class SuccessReturn<R> extends ReturnSuccessOrError<R> {
  const SuccessReturn({
    required R super.success,
  });

  R get result => _success!;

  @override
  String toString() {
    return "Success: $result";
  }
}

///Responsible for storing the returned data when error.
final class ErrorReturn<R> extends ReturnSuccessOrError<R> {
  const ErrorReturn({
    required AppError super.error,
  });

  AppError get result => _error!;

  @override
  String toString() {
    return "Error: $result";
  }
}

/// Representation of void as a result
final class Unit {
  static final Unit _instance = Unit._();
  
  factory Unit() => _instance;
  
  Unit._();
  
  @override
  String toString() {
    return 'Unit{} - void';
  }
}

/// Getter for loading the Unit instance
Unit get unit => Unit();

/// Representation of null as a result
final class Nil {
  static final Nil _instance = Nil._();
  
  factory Nil() => _instance;
  
  Nil._();
  
  @override
  String toString() {
    return 'Nil{} - null';
  }
}

/// Getter for loading the Nil instance
Nil get nil => Nil();
