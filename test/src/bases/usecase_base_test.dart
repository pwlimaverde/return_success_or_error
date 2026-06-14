import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/bases/usecase_base.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:return_success_or_error/src/interfaces/parameters.dart';
import 'package:test/test.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String nome;
  final bool sucesso;

  ParametersSalvarHeader({required this.nome, this.sucesso = true});

  @override
  AppError get error => const ErrorGeneric(message: "teste parrametros");
}

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

/// Datasource concreto e *sendable* (sem closures/objetos não-transferíveis),
/// usado para exercitar Isolates em um [UsecaseBaseCallData].
final class SendableBoolDatasource implements Datasource<bool> {
  final bool value;

  const SendableBoolDatasource(this.value);

  @override
  Future<bool> call(ParametersReturnResult parameters) async => value;
}

/// Datasource que lança exceção para testar o fluxo de erro do fetch.
final class SendableExceptionDatasource implements Datasource<bool> {
  const SendableExceptionDatasource();

  @override
  Future<bool> call(ParametersReturnResult parameters) async {
    throw Exception('erro no datasource');
  }
}

// === Usecases de teste (process estático) ===

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData({
    required super.datasource,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessData<String, bool> get process => _process;

  static ReturnSuccessOrError<String> _process(
    bool data,
    ParametersReturnResult parameters,
  ) => data
      ? const SuccessReturn<String>(success: "Regra de negocio true")
      : const SuccessReturn<String>(success: "Regra de negocio false");
}

final class TesteUsecaseDirect extends UsecaseBase<String> {
  const TesteUsecaseDirect({super.runInIsolate, super.monitorExecutionTime});

  @override
  ProcessPure<String> get process => _process;

  static ReturnSuccessOrError<String> _process(
    ParametersReturnResult parameters,
  ) {
    final params = parameters as ParametersSalvarHeader;
    return params.sucesso
        ? SuccessReturn<String>(success: params.nome)
        : ErrorReturn(error: params.error);
  }
}

final class TesteUsecaseCallDataVoid extends UsecaseBaseCallData<Unit, bool> {
  TesteUsecaseCallDataVoid({required super.datasource, super.runInIsolate});

  @override
  ProcessData<Unit, bool> get process => _process;

  static ReturnSuccessOrError<Unit> _process(
    bool data,
    ParametersReturnResult parameters,
  ) => const SuccessReturn<Unit>(success: unit);
}

final class TesteUsecaseDirectVoid extends UsecaseBase<Unit> {
  const TesteUsecaseDirectVoid({
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  ProcessPure<Unit> get process => _process;

  static ReturnSuccessOrError<Unit> _process(
    ParametersReturnResult parameters,
  ) => const SuccessReturn<Unit>(success: unit);
}

final class TesteUsecaseCallDataNull extends UsecaseBaseCallData<Nil, bool> {
  TesteUsecaseCallDataNull({required super.datasource, super.runInIsolate});

  @override
  ProcessData<Nil, bool> get process => _process;

  static ReturnSuccessOrError<Nil> _process(
    bool data,
    ParametersReturnResult parameters,
  ) => const SuccessReturn<Nil>(success: nil);
}

final class TesteUsecaseDirectNull extends UsecaseBase<Nil> {
  const TesteUsecaseDirectNull({super.runInIsolate});

  @override
  ProcessPure<Nil> get process => _process;

  static ReturnSuccessOrError<Nil> _process(
    ParametersReturnResult parameters,
  ) => const SuccessReturn<Nil>(success: nil);
}

/// Usecase cujo [process] lança exceção — testa o catch do [Isolate.run]
/// (`Cod. IsolateCatch`).
final class TesteUsecaseLancaExcecao extends UsecaseBase<String> {
  const TesteUsecaseLancaExcecao({super.runInIsolate});

  @override
  ProcessPure<String> get process => _process;

  static ReturnSuccessOrError<String> _process(
    ParametersReturnResult parameters,
  ) {
    throw Exception('excecao direta no process');
  }
}

/// Conta quantas vezes o [process] foi executado — prova que o short-circuit no
/// erro do datasource impede a chamada do process.
int processCallCount = 0;

final class TesteUsecaseContaProcess extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseContaProcess({required super.datasource});

  @override
  ProcessData<String, bool> get process => _process;

  static ReturnSuccessOrError<String> _process(
    bool data,
    ParametersReturnResult parameters,
  ) {
    processCallCount++;
    return const SuccessReturn<String>(success: "ok");
  }
}

void main() {
  late Datasource<bool> datasource;
  final parameters = ParametersSalvarHeader(nome: 'Teste UsecaseBase');
  late TesteUsecaseCallData returnResultUsecaseCallData;
  late TesteUsecaseCallDataVoid returnResultUsecaseCallDataVoid;
  late TesteUsecaseCallDataNull returnResultUsecaseCallDataNull;

  setUp(() {
    datasource = ReturnResultDatasourceMock();
    returnResultUsecaseCallData = TesteUsecaseCallData(datasource: datasource);
    returnResultUsecaseCallDataVoid = TesteUsecaseCallDataVoid(
      datasource: datasource,
    );
    returnResultUsecaseCallDataNull = TesteUsecaseCallDataNull(
      datasource: datasource,
    );
    processCallCount = 0;
  });

  group('UsecaseBase (process puro)', () {
    test('Deve retornar um success com "Teste Void"', () async {
      const usecase = TesteUsecaseDirectVoid();
      final data = await usecase(
        const NoParams(error: ErrorGeneric(message: "teste parrametros")),
      );
      switch (data) {
        case SuccessReturn<Unit>():
          expect(data.result, isA<Unit>());
        case ErrorReturn<Unit>():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um success com "Teste Void" isolate', () async {
      const usecase = TesteUsecaseDirectVoid(
        runInIsolate: true,
        monitorExecutionTime: true,
      );
      final data = await usecase(
        const NoParams(error: ErrorGeneric(message: "teste parrametros")),
      );
      switch (data) {
        case SuccessReturn<Unit>():
          expect(data.result, isA<Unit>());
        case ErrorReturn<Unit>():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um success com "Teste Null"', () async {
      const usecase = TesteUsecaseDirectNull();
      final data = await usecase(
        const NoParams(error: ErrorGeneric(message: "teste parrametros")),
      );
      switch (data) {
        case SuccessReturn<Nil>():
          expect(data.result, isA<Nil>());
        case ErrorReturn<Nil>():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um success com "Teste Null" isolate', () async {
      const usecase = TesteUsecaseDirectNull(runInIsolate: true);
      final data = await usecase(
        const NoParams(error: ErrorGeneric(message: "teste parrametros")),
      );
      switch (data) {
        case SuccessReturn<Nil>():
          expect(data.result, isA<Nil>());
        case ErrorReturn<Nil>():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um success com "Teste UsecaseBase"', () async {
      const usecase = TesteUsecaseDirect();
      final data = await usecase(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Teste UsecaseBase"));
        case ErrorReturn():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um success com "Teste UsecaseBase" isolate', () async {
      const usecase = TesteUsecaseDirect(runInIsolate: true);
      final data = await usecase(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Teste UsecaseBase"));
        case ErrorReturn():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um AppError com ErrorGeneric', () async {
      const usecase = TesteUsecaseDirect();
      final data = await usecase(
        ParametersSalvarHeader(nome: 'falha', sucesso: false),
      );
      switch (data) {
        case SuccessReturn():
          fail('Esperava ErrorReturn');
        case ErrorReturn():
          expect(data.result, isA<ErrorGeneric>());
      }
    });

    test(
      'process que lança em isolate vira ErrorReturn com Cod. IsolateCatch',
      () async {
        const usecase = TesteUsecaseLancaExcecao(runInIsolate: true);
        final data = await usecase(parameters);
        switch (data) {
          case SuccessReturn<String>():
            fail('Esperava ErrorReturn');
          case ErrorReturn<String>():
            expect(data.result, isA<ErrorGeneric>());
            expect(data.result.message, contains('Cod. IsolateCatch'));
            expect(data.result.message, contains('excecao direta no process'));
        }
      },
    );
  });

  group('UsecaseBaseCallData (fetch + process)', () {
    test('Deve retornar um success void data "true"', () async {
      when(() => datasource(parameters)).thenAnswer((_) => Future.value(true));
      final data = await returnResultUsecaseCallDataVoid(parameters);
      switch (data) {
        case SuccessReturn<Unit>():
          expect(data.result, isA<Unit>());
        case ErrorReturn<Unit>():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um success void data "true" isolate', () async {
      final usecase = TesteUsecaseCallDataVoid(
        datasource: const SendableBoolDatasource(true),
        runInIsolate: true,
      );
      final data = await usecase(parameters);
      switch (data) {
        case SuccessReturn<Unit>():
          expect(data.result, isA<Unit>());
        case ErrorReturn<Unit>():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um AppError com ErrorGeneric void', () async {
      when(() => datasource(parameters)).thenThrow(Exception());
      final data = await returnResultUsecaseCallDataVoid(parameters);
      switch (data) {
        case SuccessReturn<Unit>():
          fail('Esperava ErrorReturn');
        case ErrorReturn<Unit>():
          expect(data.result, isA<ErrorGeneric>());
      }
    });

    test('Deve retornar um success null data "true"', () async {
      when(() => datasource(parameters)).thenAnswer((_) => Future.value(true));
      final data = await returnResultUsecaseCallDataNull(parameters);
      switch (data) {
        case SuccessReturn<Nil>():
          expect(data.result, isA<Nil>());
        case ErrorReturn<Nil>():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um AppError com ErrorGeneric null', () async {
      when(() => datasource(parameters)).thenThrow(Exception());
      final data = await returnResultUsecaseCallDataNull(parameters);
      switch (data) {
        case SuccessReturn<Nil>():
          fail('Esperava ErrorReturn');
        case ErrorReturn<Nil>():
          expect(data.result, isA<ErrorGeneric>());
      }
    });

    test('Deve retornar um success com "Regra de negocio true"', () async {
      when(() => datasource(parameters)).thenAnswer((_) => Future.value(true));
      final data = await returnResultUsecaseCallData(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Regra de negocio true"));
        case ErrorReturn():
          fail('Esperava SuccessReturn');
      }
    });

    test('Deve retornar um success com "Regra de negocio false"', () async {
      when(() => datasource(parameters)).thenAnswer((_) => Future.value(false));
      final data = await returnResultUsecaseCallData(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Regra de negocio false"));
        case ErrorReturn():
          fail('Esperava SuccessReturn');
      }
    });

    test(
      'Deve retornar um AppError quando o datasource lança exceção',
      () async {
        when(() => datasource(parameters)).thenThrow(Exception());
        final data = await returnResultUsecaseCallData(parameters);
        switch (data) {
          case SuccessReturn():
            fail('Esperava ErrorReturn');
          case ErrorReturn():
            expect(data.result, isA<ErrorGeneric>());
        }
      },
    );

    test('Erro do datasource é enriquecido com Cod. 02-1 preservando a '
        'original', () async {
      when(() => datasource(parameters)).thenThrow(Exception('boom'));
      final data = await returnResultUsecaseCallData(parameters);

      expect(data, isA<ErrorReturn<String>>());
      final message = (data as ErrorReturn<String>).result.message;
      expect(message, contains('teste parrametros')); // mensagem original
      expect(message, contains('Cod. 02-1')); // código do catch
      expect(message, contains('boom')); // contexto da exceção
    });

    test('Short-circuit: process NÃO é chamado quando o fetch falha', () async {
      when(() => datasource(parameters)).thenThrow(Exception('falha no fetch'));
      final usecase = TesteUsecaseContaProcess(datasource: datasource);

      final data = await usecase(parameters);

      expect(data, isA<ErrorReturn<String>>());
      expect(processCallCount, equals(0));
    });

    test('process É chamado quando o fetch tem sucesso', () async {
      when(() => datasource(parameters)).thenAnswer((_) => Future.value(true));
      final usecase = TesteUsecaseContaProcess(datasource: datasource);

      await usecase(parameters);

      expect(processCallCount, equals(1));
    });
  });

  group('Usecase processando o datasource em Isolate (sendable)', () {
    test('Deve retornar success processando o datasource em isolate', () async {
      final usecase = TesteUsecaseCallData(
        datasource: const SendableBoolDatasource(true),
        runInIsolate: true,
      );

      final data = await usecase(parameters);

      switch (data) {
        case SuccessReturn<String>():
          expect(data.result, equals("Regra de negocio true"));
        case ErrorReturn<String>():
          fail('Esperava SuccessReturn');
      }
    });

    test(
      'Deve retornar success "false" processando o datasource em isolate',
      () async {
        final usecase = TesteUsecaseCallData(
          datasource: const SendableBoolDatasource(false),
          runInIsolate: true,
        );

        final data = await usecase(parameters);

        switch (data) {
          case SuccessReturn<String>():
            expect(data.result, equals("Regra de negocio false"));
          case ErrorReturn<String>():
            fail('Esperava SuccessReturn');
        }
      },
    );

    test(
      'Erro do datasource em isolate é enriquecido com Cod. 02-1 (fetch roda '
      'fora do isolate)',
      () async {
        final usecase = TesteUsecaseCallData(
          datasource: const SendableExceptionDatasource(),
          runInIsolate: true,
        );

        final data = await usecase(parameters);

        switch (data) {
          case SuccessReturn<String>():
            fail('Esperava ErrorReturn');
          case ErrorReturn<String>():
            expect(data.result, isA<ErrorGeneric>());
            expect(data.result.message, contains('Cod. 02-1'));
        }
      },
    );
  });

  group('monitorExecutionTime', () {
    test('desligado por padrão', () {
      expect(const TesteUsecaseDirect().monitorExecutionTime, isFalse);
    });

    test(
      'com monitoramento ligado o resultado é idêntico (caminho direto)',
      () async {
        const usecase = TesteUsecaseDirect(monitorExecutionTime: true);
        final data = await usecase(parameters);
        switch (data) {
          case SuccessReturn<String>():
            expect(data.result, equals("Teste UsecaseBase"));
          case ErrorReturn<String>():
            fail('Esperava SuccessReturn');
        }
      },
    );

    test(
      'com monitoramento ligado o resultado é idêntico (caminho isolate)',
      () async {
        final usecase = TesteUsecaseCallData(
          datasource: const SendableBoolDatasource(true),
          runInIsolate: true,
          monitorExecutionTime: true,
        );
        final data = await usecase(parameters);
        switch (data) {
          case SuccessReturn<String>():
            expect(data.result, equals("Regra de negocio true"));
          case ErrorReturn<String>():
            fail('Esperava SuccessReturn');
        }
      },
    );
  });
}
