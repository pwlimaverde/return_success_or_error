abstract class AppError implements Exception {}

class ErroReturnResult implements AppError {
  final String message;

  ErroReturnResult({required this.message});

  @override
  String toString() {
    return "ErroReturnResult - $message";
  }
}
