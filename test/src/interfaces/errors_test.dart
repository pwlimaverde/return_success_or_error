import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:test/test.dart';

final class ErrorTeste implements AppError {
  @override
  final String message;

  const ErrorTeste({required this.message});

  @override
  ErrorTeste copyWith({String? message}) =>
      ErrorTeste(message: message ?? this.message);

  @override
  String toString() => "ErrorTeste - $message";
}

void main() {
  test('Deve retornar um AppError', () {
    const result = ErrorTeste(message: "Teste Error");

    expect(result, isA<AppError>());
    expect(result.message, equals("Teste Error"));
  });

  test('copyWith deve substituir apenas a message', () {
    const result = ErrorTeste(message: "Original");
    final copy = result.copyWith(message: "Novo");

    expect(copy, isA<ErrorTeste>());
    expect(copy.message, equals("Novo"));
    expect(result.message, equals("Original"));
  });

  test('ErrorGeneric deve comparar por valor (== e hashCode)', () {
    const a = ErrorGeneric(message: "mesma");
    const b = ErrorGeneric(message: "mesma");
    const c = ErrorGeneric(message: "diferente");

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(c)));
  });
}
