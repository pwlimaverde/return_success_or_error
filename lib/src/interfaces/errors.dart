/// Immutable error contract. Implements [Exception] and exposes a [message].
///
/// Implementations must be immutable: to enrich an error (for example, to
/// append context while it bubbles up through the layers), use [copyWith] to
/// produce a new instance instead of mutating the existing one.
abstract interface class AppError implements Exception {
  /// Human readable description of the error.
  String get message;

  /// Returns a copy of this error, optionally replacing the [message].
  AppError copyWith({String? message});

  @override
  String toString() => "Error - $message";
}

/// Default concrete [AppError] implementation.
final class ErrorGeneric implements AppError {
  @override
  final String message;

  const ErrorGeneric({required this.message});

  @override
  ErrorGeneric copyWith({String? message}) =>
      ErrorGeneric(message: message ?? this.message);

  @override
  String toString() => "ErrorGeneric - $message";
}
