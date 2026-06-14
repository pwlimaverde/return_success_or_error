import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

void main() {
  group('SuccessReturn', () {
    const ReturnSuccessOrError<int> result = SuccessReturn(success: 42);

    test('expõe o valor via result no pattern matching', () {
      switch (result) {
        case SuccessReturn<int>():
          expect(result.result, equals(42));
        case ErrorReturn<int>():
          fail('Esperava SuccessReturn');
      }
    });

    test('result via contrato da base retorna Object?', () {
      // Acessando via tipo base — retorna Object?
      expect(result.result, equals(42));
    });

    test('toString', () {
      expect(result.toString(), equals("Success: 42"));
    });

    test('igualdade por valor', () {
      expect(
        const SuccessReturn(success: 42),
        equals(const SuccessReturn(success: 42)),
      );
      expect(
        const SuccessReturn(success: 42).hashCode,
        equals(const SuccessReturn(success: 42).hashCode),
      );
      expect(
        const SuccessReturn(success: 42),
        isNot(equals(const SuccessReturn(success: 99))),
      );
      // Discrimina por tipo do resultado, não só pelo caso.
      expect(
        const SuccessReturn(success: 42),
        isNot(equals(const SuccessReturn(success: '42'))),
      );
    });
  });

  group('ErrorReturn', () {
    const ReturnSuccessOrError<int> result = ErrorReturn(
      error: ErrorGeneric(message: "falhou"),
    );

    test('expõe o erro via result no pattern matching', () {
      switch (result) {
        case SuccessReturn<int>():
          fail('Esperava ErrorReturn');
        case ErrorReturn<int>():
          expect(result.result.message, equals("falhou"));
      }
    });

    test('result via contrato da base retorna Object?', () {
      expect(result.result, isA<AppError>());
    });

    test('toString', () {
      expect(result.toString(), equals("Error: ErrorGeneric - falhou"));
    });

    test('igualdade por valor', () {
      expect(
        const ErrorReturn<int>(error: ErrorGeneric(message: "falhou")),
        equals(const ErrorReturn<int>(error: ErrorGeneric(message: "falhou"))),
      );
      expect(
        const ErrorReturn<int>(error: ErrorGeneric(message: "falhou")).hashCode,
        equals(
          const ErrorReturn<int>(
            error: ErrorGeneric(message: "falhou"),
          ).hashCode,
        ),
      );
      expect(
        const ErrorReturn<int>(error: ErrorGeneric(message: "falhou")),
        isNot(
          equals(const ErrorReturn<int>(error: ErrorGeneric(message: "outro"))),
        ),
      );
    });
  });

  group('Unit/Nil', () {
    test('const constructor produz instâncias idênticas', () {
      expect(identical(unit, const Unit()), isTrue);
      expect(identical(nil, const Nil()), isTrue);
    });

    test('toString', () {
      expect(unit.toString(), equals("Unit{} - void"));
      expect(nil.toString(), equals("Nil{} - null"));
    });
  });
}
