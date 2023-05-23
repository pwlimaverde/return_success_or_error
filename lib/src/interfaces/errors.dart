///calsse implements Exception and requires the String with the error message.
abstract interface class AppError implements Exception {
  late final String message;

  @override
  String toString() {
    return "Error - $message";
  }
}

final class ErrorReturnResult implements AppError {
  @override
  String message;
  ErrorReturnResult({required this.message});
  @override
  String toString() {
    return "ErrorReturnResult - $message";
  }
}
