import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

void main() {
  group('Success', () {
    test('Deve expor o valor tipado em .value', () {
      const ReturnSuccessOrError<int, TestError> result = Success(42);

      expect((result as Success<int, TestError>).value, equals(42));
    });

    test('Deve comparar por valor', () {
      expect(
        const Success<int, TestError>(42),
        equals(const Success<int, TestError>(42)),
      );
      expect(
        const Success<int, TestError>(42).hashCode,
        equals(const Success<int, TestError>(42).hashCode),
      );
      expect(
        const Success<int, TestError>(42),
        isNot(equals(const Success<int, TestError>(7))),
      );
    });

    test('toString', () {
      expect(const Success<int, TestError>(42).toString(), 'Success: 42');
    });
  });

  group('Failure', () {
    test('Deve expor o erro tipado em .error', () {
      const ReturnSuccessOrError<int, TestError> result = Failure(
        NotFoundError('nao encontrado'),
      );

      expect(
        (result as Failure<int, TestError>).error,
        isA<NotFoundError>().having(textOf, 'message', 'nao encontrado'),
      );
    });

    test('Deve comparar por valor', () {
      expect(
        const Failure<int, TestError>(NotFoundError('x')),
        equals(const Failure<int, TestError>(NotFoundError('x'))),
      );
      expect(
        const Failure<int, TestError>(NotFoundError('x')),
        isNot(equals(const Failure<int, TestError>(ValidationError('x')))),
      );
    });

    test('toString', () {
      expect(
        const Failure<int, TestError>(NotFoundError('x')).toString(),
        'Failure: NotFoundError - x',
      );
    });
  });

  group('Consumo exaustivo', () {
    test('Deve tratar sucesso e falha no switch dos dois níveis', () {
      String consumir(ReturnSuccessOrError<int, TestError> result) =>
          switch (result) {
            Success(:final value) => 'ok:$value',
            // Sem braço `default`: o compilador prova que os três erros
            // possíveis da feature estão cobertos.
            Failure(:final error) => switch (error) {
              NotFoundError() => 'nao-encontrado',
              ValidationError() => 'invalido',
              UnexpectedError() => 'inesperado',
            },
          };

      expect(consumir(const Success(1)), 'ok:1');
      expect(consumir(const Failure(NotFoundError('x'))), 'nao-encontrado');
      expect(consumir(const Failure(ValidationError('x'))), 'invalido');
      expect(consumir(const Failure(UnexpectedError('x'))), 'inesperado');
    });
  });

  group('Simetria da igualdade (contrato de Object.==)', () {
    // Regressão: testar os argumentos de tipo no `==` tornava a comparação
    // assimétrica, porque genéricos são covariantes em Dart —
    // Success<String, TestError> É um Success<String, dynamic>, mas não o
    // inverso, então `a == b` dava true e `b == a` dava false.
    //
    // `<String, dynamic>` é exatamente o tipo que a inferência produz em
    // `expect(result, Success('x'))`: o TError não aparece em nenhum argumento
    // do construtor, então não há de onde inferi-lo.
    //
    // Os `ignore` abaixo são o próprio objeto do teste: o analyzer avisa da
    // comparação entre tipos não relacionados, que é o cenário exercitado.

    test('Success compara igual nos dois sentidos', () {
      const ReturnSuccessOrError<String, TestError> tipado = Success('x');
      const semTipar = Success<String, dynamic>('x');

      // ignore: unrelated_type_equality_checks
      expect(tipado == semTipar, isTrue);
      // ignore: unrelated_type_equality_checks
      expect(semTipar == tipado, isTrue);
      expect(tipado.hashCode, equals(semTipar.hashCode));
    });

    test('Failure compara igual nos dois sentidos', () {
      const ReturnSuccessOrError<String, TestError> tipado = Failure(
        NotFoundError('x'),
      );
      const semTipar = Failure<String, dynamic>(NotFoundError('x'));

      // ignore: unrelated_type_equality_checks
      expect(tipado == semTipar, isTrue);
      // ignore: unrelated_type_equality_checks
      expect(semTipar == tipado, isTrue);
    });

    test('Success nunca é igual a Failure', () {
      const success = Success<String, TestError>('x');
      const failure = Failure<String, TestError>(NotFoundError('x'));

      // ignore: unrelated_type_equality_checks
      expect(success == failure, isFalse);
      // ignore: unrelated_type_equality_checks
      expect(failure == success, isFalse);
    });

    test('Valores diferentes continuam diferentes', () {
      const ReturnSuccessOrError<String, TestError> tipado = Success('x');
      const outro = Success<String, dynamic>('y');

      // ignore: unrelated_type_equality_checks
      expect(tipado == outro, isFalse);
      // ignore: unrelated_type_equality_checks
      expect(outro == tipado, isFalse);
    });
  });

  group('Unit e Nil', () {
    test('São singletons const canonicalizados', () {
      expect(identical(unit, const Unit()), isTrue);
      expect(identical(nil, const Nil()), isTrue);
    });

    test('toString', () {
      expect(unit.toString(), 'Unit - void');
      expect(nil.toString(), 'Nil - null');
    });

    test('Podem ser o valor de um Success', () {
      expect(const Success<Unit, TestError>(unit).value, isA<Unit>());
      expect(const Success<Nil, TestError>(nil).value, isA<Nil>());
    });
  });
}
