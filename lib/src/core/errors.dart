abstract class AppError implements Exception {
  String message;

  AppError({required this.message});

  @override
  String toString() {
    return "AppError - $message";
  }
}

class ErrorReturnResult implements AppError {
  String message;

  ErrorReturnResult({required this.message});

  @override
  String toString() {
    return message;
  }
}
