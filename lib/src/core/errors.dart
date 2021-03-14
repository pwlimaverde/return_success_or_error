abstract class AppError implements Exception {}

class ErrorReturnResult implements AppError {
  final String message;

  ErrorReturnResult({required this.message});

  @override
  String toString() {
    return "ErrorReturnResult - $message";
  }
}
