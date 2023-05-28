import 'package:flutter_test/flutter_test.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

final class ErrorTeste implements AppError {
  @override
  String message;
  ErrorTeste({required this.message});
  @override
  String toString() {
    return "ErrorTeste - $message";
  }
}

void main() {
  test('Deve retornar um AppError', () async {
    final result = ErrorTeste(message: "Teste Error");
    final message = result.message;
    print("teste result - $result");
    expect(result, isA<AppError>());
    expect(message, equals("Teste Error"));
  });
}
