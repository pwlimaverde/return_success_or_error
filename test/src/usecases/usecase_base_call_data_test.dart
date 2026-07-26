import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:test/test.dart';

import '../../test_fixtures.dart';

final class RepositoryMock extends Mock
    implements Repository<int, TestParams, TestError> {}

/// Conta as execuções do `process` — prova o curto-circuito. Só é observável no
/// caminho direto (um isolate não compartilha memória com o principal).
int processCallCount = 0;

final class ValorUsecase
    extends UsecaseBaseCallData<String, int, TestParams, TestError> {
  const ValorUsecase({
    required super.repository,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<String, int, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) =>
      UnexpectedError('capturado: $exception');

  static ReturnSuccessOrError<String, TestError> _process(
    int data,
    TestParams parameters,
  ) {
    processCallCount++;
    return Success('valor: $data');
  }
}

final class ExplodeCallDataUsecase
    extends UsecaseBaseCallData<String, int, TestParams, TestError> {
  const ExplodeCallDataUsecase({required super.repository, super.runInIsolate});

  @override
  ProcessData<String, int, TestParams, TestError> get process => _process;

  @override
  TestError onUnexpected(Object exception, StackTrace stackTrace) =>
      UnexpectedError('capturado: $exception');

  static ReturnSuccessOrError<String, TestError> _process(
    int data,
    TestParams parameters,
  ) => throw StateError('process-boom');
}

/// Datasource sendable, para o teste de integração das três camadas.
final class DobroDatasource implements Datasource<int, TestParams> {
  const DobroDatasource();

  @override
  Future<int> call(TestParams parameters) async =>
      parameters.sucesso ? 21 : throw const FormatException('entrada invalida');
}

final class DobroRepository extends RepositoryBase<int, TestParams, TestError> {
  const DobroRepository({required super.datasource});

  @override
  TestError mapError(
    Object exception,
    StackTrace stackTrace,
    TestParams parameters,
  ) => switch (exception) {
    FormatException() => ValidationError('invalido: $exception'),
    _ => UnexpectedError('inesperado: $exception'),
  };
}

/// Repository implementado **à mão** (sem `RepositoryBase`) que quebra o
/// contrato e lança em vez de devolver `Failure`. Existe para provar que nem
/// assim o usecase propaga exceção ao chamador.
final class RepositoryQueLanca
    implements Repository<int, TestParams, TestError> {
  const RepositoryQueLanca();

  @override
  Future<ReturnSuccessOrError<int, TestError>> call(TestParams parameters) =>
      throw StateError('repository-boom');
}

void main() {
  late RepositoryMock repository;
  const parameters = TestParams();

  RepositoryMock repositoryReturning(
    ReturnSuccessOrError<int, TestError> result,
  ) {
    final mock = RepositoryMock();
    when(() => mock(parameters)).thenAnswer((_) async => result);
    return mock;
  }

  setUp(() {
    processCallCount = 0;
    repository = repositoryReturning(const Success(42));
  });

  group('UsecaseBaseCallData (fetch + process)', () {
    test('Deve processar o dado carregado no fetch', () async {
      final result = await ValorUsecase(repository: repository)(parameters);

      switch (result) {
        case Success(:final value):
          expect(value, equals('valor: 42'));
        case Failure():
          fail('Esperava Success');
      }
    });

    test('Deve processar o dado carregado no fetch em isolate', () async {
      final result = await ValorUsecase(
        repository: repository,
        runInIsolate: true,
      )(parameters);

      switch (result) {
        case Success(:final value):
          expect(value, equals('valor: 42'));
        case Failure():
          fail('Esperava Success');
      }
    });

    test('Deve chamar o process quando o fetch tem sucesso', () async {
      await ValorUsecase(repository: repository)(parameters);

      expect(processCallCount, equals(1));
    });
  });

  group('Curto-circuito', () {
    test('Deve retornar o erro do fetch sem chamar o process', () async {
      final falho = repositoryReturning(
        const Failure(NotFoundError('falha de fetch')),
      );

      final result = await ValorUsecase(repository: falho)(parameters);

      expect(result, isA<Failure<String, TestError>>());
      expect(processCallCount, equals(0));
    });

    test('Deve preservar o caso concreto do erro do fetch', () async {
      final falho = repositoryReturning(
        const Failure(ValidationError('invalido')),
      );

      final result = await ValorUsecase(repository: falho)(parameters);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<ValidationError>());
          expect(textOf(error), equals('invalido'));
      }
    });
  });

  group('onUnexpected', () {
    test('Exceção no process vira Failure no caminho direto', () async {
      final result = await ExplodeCallDataUsecase(repository: repository)(
        parameters,
      );

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<UnexpectedError>());
          expect(textOf(error), contains('process-boom'));
      }
    });

    test('Exceção no process vira Failure no caminho isolate', () async {
      final result = await ExplodeCallDataUsecase(
        repository: repository,
        runInIsolate: true,
      )(parameters);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<UnexpectedError>());
          expect(textOf(error), contains('process-boom'));
      }
    });
  });

  group('Garantia: o usecase nunca propaga exceção', () {
    test('Repository que lança vira Failure via onUnexpected', () async {
      const usecase = ValorUsecase(repository: RepositoryQueLanca());

      final result = await usecase(parameters);

      switch (result) {
        case Success():
          fail('Esperava Failure');
        case Failure(:final error):
          expect(error, isA<UnexpectedError>());
          expect(textOf(error), contains('repository-boom'));
      }
      // A falha no fetch curto-circuita: o process não roda.
      expect(processCallCount, equals(0));
    });

    test('Repository que lança também não propaga com runInIsolate', () async {
      const usecase = ValorUsecase(
        repository: RepositoryQueLanca(),
        runInIsolate: true,
      );

      expect(await usecase(parameters), isA<Failure<String, TestError>>());
    });
  });

  group('Paridade direto × isolate', () {
    test('Resultado idêntico nos dois modos', () async {
      final direto = await ValorUsecase(repository: repository)(parameters);
      final isolate = await ValorUsecase(
        repository: repository,
        runInIsolate: true,
      )(parameters);

      expect(isolate, equals(direto));
    });
  });

  group('monitorExecutionTime', () {
    test('Desligado por padrão', () {
      expect(
        ValorUsecase(repository: repository).monitorExecutionTime,
        isFalse,
      );
    });

    test('Ligado não altera o resultado', () async {
      final result = await ValorUsecase(
        repository: repository,
        monitorExecutionTime: true,
      )(parameters);

      expect(result, equals(const Success<String, TestError>('valor: 42')));
    });
  });

  group('Integração das três camadas (Datasource → Repository → Usecase)', () {
    test('Deve processar o dado real da fonte', () async {
      const usecase = ValorUsecase(
        repository: DobroRepository(datasource: DobroDatasource()),
      );

      final result = await usecase(const TestParams());

      expect(result, equals(const Success<String, TestError>('valor: 21')));
    });

    test(
      'Falha da fonte é traduzida no repositório e curto-circuita',
      () async {
        const usecase = ValorUsecase(
          repository: DobroRepository(datasource: DobroDatasource()),
        );

        final result = await usecase(const TestParams(sucesso: false));

        switch (result) {
          case Success():
            fail('Esperava Failure');
          case Failure(:final error):
            expect(error, isA<ValidationError>());
            expect(textOf(error), contains('entrada invalida'));
        }
        expect(processCallCount, equals(0));
      },
    );

    test('O fetch roda fora do isolate, mesmo com runInIsolate', () async {
      // O datasource nunca cruza a fronteira: só o process vai para o isolate.
      const usecase = ValorUsecase(
        repository: DobroRepository(datasource: DobroDatasource()),
        runInIsolate: true,
      );

      final result = await usecase(const TestParams());

      expect(result, equals(const Success<String, TestError>('valor: 21')));
    });
  });
}
