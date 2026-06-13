import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

void main() {
  group('SuccessReturn', () {
    const ReturnSuccessOrError<int> result = SuccessReturn(success: 42);

    test('expõe o valor via result', () {
      expect((result as SuccessReturn<int>).result, equals(42));
    });

    test('isSuccess/isError', () {
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
    });

    test('getOrNull retorna o valor', () {
      expect(result.getOrNull, equals(42));
    });

    test('fold chama onSuccess', () {
      final out = result.fold(
        onSuccess: (value) => "ok:$value",
        onError: (error) => "fail:${error.message}",
      );
      expect(out, equals("ok:42"));
    });

    test('toString', () {
      expect(result.toString(), equals("Success: 42"));
    });
  });

  group('ErrorReturn', () {
    const ReturnSuccessOrError<int> result =
        ErrorReturn(error: ErrorGeneric(message: "falhou"));

    test('expõe o erro via result', () {
      expect((result as ErrorReturn<int>).result.message, equals("falhou"));
    });

    test('isSuccess/isError', () {
      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
    });

    test('getOrNull retorna null', () {
      expect(result.getOrNull, isNull);
    });

    test('fold chama onError', () {
      final out = result.fold(
        onSuccess: (value) => "ok:$value",
        onError: (error) => "fail:${error.message}",
      );
      expect(out, equals("fail:falhou"));
    });

    test('toString', () {
      expect(result.toString(), equals("Error: ErrorGeneric - falhou"));
    });
  });

  group('Unit/Nil', () {
    test('são singletons', () {
      expect(identical(unit, Unit()), isTrue);
      expect(identical(nil, Nil()), isTrue);
    });

    test('toString', () {
      expect(unit.toString(), equals("Unit{} - void"));
      expect(nil.toString(), equals("Nil{} - null"));
    });
  });
}
