///calsse implements Exception and requires the String with the error message.
abstract interface class AppError implements Exception {
  late final String message;

  @override
  String toString() {
    return "Error - $message";
  }
}

final class ErrorGeneric implements AppError {
  @override
  String message;
  ErrorGeneric({required this.message});
  @override
  String toString() {
    return "ErrorGeneric - $message";
  }
}
