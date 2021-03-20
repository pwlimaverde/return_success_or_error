///calsse implements Exception and requires the String with the error message.
abstract class AppError implements Exception {
  String message;

  AppError({required this.message});

  @override
  String toString() {
    return "AppError - $message";
  }
}

///Implementation of AppError to customize errors.
class ErrorReturnResult implements AppError {
  String message;

  ErrorReturnResult({required this.message});

  @override
  String toString() {
    return message;
  }
}
