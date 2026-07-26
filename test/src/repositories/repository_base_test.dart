import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

final class DatasourceMock extends Mock
    implements Datasource<int, TestParams> {}

/// Repositório que traduz a exceção técnica em um dos erros do conjunto fechado.
final class TranslatingRepository
    extends RepositoryBase<int, TestParams, TestError> {
  const TranslatingRepository({required super.datasource});

  @override
  TestError mapError(
    Object exception,
    StackTrace stackTrace,
    TestParams parameters,
  ) => switch (exception) {
    FormatException() => ValidationError(
      'invalido em ${parameters.nome}: $exception',
    ),
    StateError() => NotFoundError('nao encontrado: $exception'),
    _ => UnexpectedError('inesperado: $exception'),
  };
}

/// Repositório que reporta o stack trace recebido — prova que a fronteira não
/// descarta a origem da falha.
final class StackTraceCapturingRepository
    extends RepositoryBase<int, TestParams, TestError> {
  const StackTraceCapturingRepository({
    required super.datasource,
    required this.capturado,
  });

  final List<StackTrace> capturado;

  @override
  TestError mapError(
    Object exception,
    StackTrace stackTrace,
    TestParams parameters,
  ) {
    capturado.add(stackTrace);
    return UnexpectedError('$exception');
  }
}

void main() {
  late DatasourceMock datasource;
  late TranslatingRepository repository;
  const parameters = TestParams(nome: 'relatorio');

  setUp(() {
    datasource = DatasourceMock();
    repository = TranslatingRepository(datasource: datasource);
  });

  group('RepositoryBase', () {
    test('Deve retornar um success com o dado bruto da fonte', () async {
      when(() => datasource(parameters)).thenAnswer((_) async => 42);

      final result = await repository(parameters);

      switch (result) {
        case Success(:final value):
          expect(value, equals(42));
        case Failure():
          fail('Esperava Success');
      }
    });

    test('Deve traduzir a exceção da fonte via mapError', () async {
      when(
        () => datasource(parameters),
      ).thenThrow(const FormatException('csv quebrado'));

      final result = await repository(parameters);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<ValidationError>());
          expect(textOf(error), contains('csv quebrado'));
      }
    });

    test(
      'Deve usar o braço default do mapError no caso não previsto',
      () async {
        when(() => datasource(parameters)).thenThrow(Exception('boom'));

        final result = await repository(parameters);

        switch (result) {
          case Success():
            fail('Esperava Failure');
          case Failure(:final error):
            expect(error, isA<UnexpectedError>());
            expect(textOf(error), contains('boom'));
        }
      },
    );

    test('Deve preservar o caso concreto traduzido', () async {
      when(() => datasource(parameters)).thenThrow(StateError('sem registro'));

      final result = await repository(parameters);

      expect(result, isA<Failure<int, TestError>>());
      expect((result as Failure<int, TestError>).error, isA<NotFoundError>());
    });

    test('Deve passar os parameters como contexto para o mapError', () async {
      when(
        () => datasource(parameters),
      ).thenThrow(const FormatException('erro'));

      final result = await repository(parameters);

      expect(result, isA<Failure<int, TestError>>());
      expect(
        textOf((result as Failure<int, TestError>).error),
        contains('relatorio'),
      );
    });

    test('Nenhuma exceção da fonte escapa da fronteira', () async {
      when(() => datasource(parameters)).thenThrow(Exception('qualquer'));

      // Não lança: o resultado é sempre um ReturnSuccessOrError.
      expect(await repository(parameters), isA<Failure<int, TestError>>());
    });

    test('Deve entregar ao mapError o stack trace da falha', () async {
      final capturado = <StackTrace>[];
      final comStackTrace = StackTraceCapturingRepository(
        datasource: datasource,
        capturado: capturado,
      );
      when(
        () => datasource(parameters),
      ).thenThrow(StateError('origem rastreável'));

      await comStackTrace(parameters);

      // O stack trace não é descartado no catch: em Dart ele não viaja dentro
      // da exceção, então precisa ser repassado explicitamente.
      expect(capturado, hasLength(1));
      expect(capturado.single, isNot(StackTrace.empty));
    });
  });
}
