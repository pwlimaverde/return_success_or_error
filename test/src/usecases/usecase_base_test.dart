import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

/// Regra pura: usa os parâmetros **já tipados**, sem nenhum cast.
final class SaudacaoUsecase extends UsecaseBase<String, TestParams, TestError> {
  const SaudacaoUsecase({super.runInIsolate, super.monitorExecutionTime});

  @override
  ProcessPure<String, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) =>
      UnexpectedError('capturado: $exception');

  static ReturnSuccessOrError<String, TestError> _process(
    TestParams parameters,
  ) => parameters.sucesso
      ? Success('Ola ${parameters.nome}')
      : const Failure(ValidationError('parametro invalido'));
}

/// Usecase cujo `process` lança — exercita o [UsecaseBase.onUnexpected].
final class ExplodeUsecase extends UsecaseBase<String, TestParams, TestError> {
  const ExplodeUsecase({super.runInIsolate});

  @override
  ProcessPure<String, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) =>
      UnexpectedError('capturado: $exception');

  static ReturnSuccessOrError<String, TestError> _process(
    TestParams parameters,
  ) => throw StateError('process-boom');
}

final class VoidUsecase extends UsecaseBase<Unit, TestParams, TestError> {
  const VoidUsecase({super.runInIsolate});

  @override
  ProcessPure<Unit, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) =>
      UnexpectedError('$exception');

  static ReturnSuccessOrError<Unit, TestError> _process(TestParams p) =>
      const Success(unit);
}

final class NullUsecase extends UsecaseBase<Nil, TestParams, TestError> {
  const NullUsecase({super.runInIsolate});

  @override
  ProcessPure<Nil, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) =>
      UnexpectedError('$exception');

  static ReturnSuccessOrError<Nil, TestError> _process(TestParams p) =>
      const Success(nil);
}

void main() {
  const parameters = TestParams(nome: 'Dart');

  group('UsecaseBase (regra pura)', () {
    test('Deve retornar um success com o valor processado', () async {
      final result = await const SaudacaoUsecase()(parameters);

      switch (result) {
        case Success(:final value):
          expect(value, equals('Ola Dart'));
        case Failure():
          fail('Esperava Success');
      }
    });

    test(
      'Deve retornar um success com o valor processado em isolate',
      () async {
        final result = await const SaudacaoUsecase(runInIsolate: true)(
          parameters,
        );

        switch (result) {
          case Success(:final value):
            expect(value, equals('Ola Dart'));
          case Failure():
            fail('Esperava Success');
        }
      },
    );

    test('Deve retornar um Failure com o erro de negócio da feature', () async {
      final result = await const SaudacaoUsecase()(
        const TestParams(sucesso: false),
      );

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<ValidationError>());
          expect(textOf(error), 'parametro invalido');
      }
    });

    test('Deve retornar um success com Unit', () async {
      final result = await const VoidUsecase()(parameters);

      expect(result, equals(const Success<Unit, TestError>(unit)));
    });

    test('Deve retornar um success com Nil', () async {
      final result = await const NullUsecase()(parameters);

      expect(result, equals(const Success<Nil, TestError>(nil)));
    });
  });

  group('onUnexpected', () {
    test('Exceção no process vira Failure no caminho direto', () async {
      final result = await const ExplodeUsecase()(parameters);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<UnexpectedError>());
          expect(textOf(error), contains('process-boom'));
      }
    });

    test('Exceção no process vira Failure no caminho isolate', () async {
      final result = await const ExplodeUsecase(runInIsolate: true)(parameters);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<UnexpectedError>());
          expect(textOf(error), contains('process-boom'));
      }
    });

    test('O usecase nunca lança para o chamador', () async {
      // Nos dois modos o resultado é um valor, nunca uma exceção propagada.
      expect(
        await const ExplodeUsecase()(parameters),
        isA<Failure<String, TestError>>(),
      );
      expect(
        await const ExplodeUsecase(runInIsolate: true)(parameters),
        isA<Failure<String, TestError>>(),
      );
    });
  });

  group('Paridade direto × isolate', () {
    test('Sucesso produz resultado idêntico nos dois modos', () async {
      expect(
        await const SaudacaoUsecase(runInIsolate: true)(parameters),
        equals(await const SaudacaoUsecase()(parameters)),
      );
    });

    test('Erro de negócio produz resultado idêntico nos dois modos', () async {
      const falha = TestParams(sucesso: false);

      expect(
        await const SaudacaoUsecase(runInIsolate: true)(falha),
        equals(await const SaudacaoUsecase()(falha)),
      );
    });
  });
}
