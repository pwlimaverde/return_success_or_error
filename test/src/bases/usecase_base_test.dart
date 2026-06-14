import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/bases/usecase_base.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:return_success_or_error/src/interfaces/parameters.dart';
import 'package:test/test.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String nome;

  ParametersSalvarHeader({required this.nome});

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

/// Datasource que lança exceção para testar fluxo de erro no isolate.
final class SendableExceptionDatasource implements Datasource<bool> {
  const SendableExceptionDatasource();

  @override
  Future<bool> call(ParametersReturnResult parameters) async {
    throw Exception('erro no datasource do isolate');
  }
}

/// Usecase que **propaga** o erro enriquecido devolvido por `resultDatasource`
/// (ao contrário de [TesteUsecaseCallData], que devolve `parameters.error` cru).
final class TesteUsecasePropagaErro extends UsecaseBaseCallData<String, bool> {
  TesteUsecasePropagaErro({required super.datasource, super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<String>> run(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(parameters);
    switch (teste) {
      case SuccessReturn<bool>():
        return const SuccessReturn<String>(success: "ok");
      case ErrorReturn<bool>():
        return ErrorReturn<String>(error: teste.result);
    }
  }
}

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData({
    required super.datasource,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  Future<ReturnSuccessOrError<String>> run(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(parameters);
    switch (teste) {
      case SuccessReturn<bool>():
        if (teste.result) {
          return const SuccessReturn<String>(success: "Regra de negocio true");
        } else {
          return const SuccessReturn<String>(success: "Regra de negocio false");
        }

      case ErrorReturn<bool>():
        return ErrorReturn<String>(error: parameters.error);
    }
  }
}

final class TesteUsecaseDirect extends UsecaseBase<String> {
  final bool testeDependencia;

  TesteUsecaseDirect({
    required this.testeDependencia,
    super.runInIsolate,
    super.monitorExecutionTime,
  });

  @override
  Future<ReturnSuccessOrError<String>> run(
    ParametersSalvarHeader parameters,
  ) async {
    if (testeDependencia) {
      return SuccessReturn<String>(success: parameters.nome);
    } else {
      return ErrorReturn(error: parameters.error);
    }
  }
}

final class TesteUsecaseCallDataVoid extends UsecaseBaseCallData<Unit, bool> {
  TesteUsecaseCallDataVoid({required super.datasource, super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<Unit>> run(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(parameters);
    switch (teste) {
      case SuccessReturn<bool>():
        return const SuccessReturn<Unit>(success: unit);
      case ErrorReturn<bool>():
        return ErrorReturn<Unit>(error: parameters.error);
    }
  }
}

final class TesteUsecaseDirectVoid extends UsecaseBase<Unit> {
  TesteUsecaseDirectVoid({super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<Unit>> run(NoParams parameters) async {
    return const SuccessReturn<Unit>(success: unit);
  }
}

final class TesteUsecaseCallDataNull extends UsecaseBaseCallData<Nil, bool> {
  TesteUsecaseCallDataNull({required super.datasource, super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<Nil>> run(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(parameters);
    switch (teste) {
      case SuccessReturn<bool>():
        return const SuccessReturn<Nil>(success: nil);
      case ErrorReturn<bool>():
        return ErrorReturn<Nil>(error: parameters.error);
    }
  }
}

final class TesteUsecaseDirectNull extends UsecaseBase<Nil> {
  TesteUsecaseDirectNull({super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<Nil>> run(NoParams parameters) async {
    return const SuccessReturn<Nil>(success: nil);
  }
}

final class TesteUsecaseLancaExcecao extends UsecaseBase<String> {
  TesteUsecaseLancaExcecao({super.runInIsolate});

  @override
  Future<ReturnSuccessOrError<String>> run(
    ParametersSalvarHeader parameters,
  ) async {
    throw Exception('excecao direta no run');
  }
}

void main() {
  late Datasource<bool> datasource;
  final parameters = ParametersSalvarHeader(nome: 'Teste UsecaseBase');
  late TesteUsecaseCallData returnResultUsecaseCallData;
  late TesteUsecaseDirect returnResultUsecaseBase;
  late TesteUsecaseCallDataVoid returnResultUsecaseCallDataVoid;
  late TesteUsecaseDirectVoid returnResultUsecaseBaseVoid;
  late TesteUsecaseCallDataNull returnResultUsecaseCallDataNull;
  late TesteUsecaseDirectNull returnResultUsecaseBaseNull;

  setUp(() {
    datasource = ReturnResultDatasourceMock();
    returnResultUsecaseCallData = TesteUsecaseCallData(datasource: datasource);
    returnResultUsecaseCallDataVoid = TesteUsecaseCallDataVoid(
      datasource: datasource,
    );
    returnResultUsecaseCallDataNull = TesteUsecaseCallDataNull(
      datasource: datasource,
    );
  });

  test('Deve retornar um success com "Teste Void"', () async {
    returnResultUsecaseBaseVoid = TesteUsecaseDirectVoid();
    final data = await returnResultUsecaseBaseVoid(
      const NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Void" isolate', () async {
    returnResultUsecaseBaseVoid = TesteUsecaseDirectVoid(runInIsolate: true);
    final data = await returnResultUsecaseBaseVoid(
      const NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Null"', () async {
    returnResultUsecaseBaseNull = TesteUsecaseDirectNull();
    final data = await returnResultUsecaseBaseNull(
      const NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Nil>():
        expect(data.result, isA<Nil>());
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Null" isolate', () async {
    returnResultUsecaseBaseNull = TesteUsecaseDirectNull(runInIsolate: true);
    final data = await returnResultUsecaseBaseNull(
      const NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Nil>():
        expect(data.result, isA<Nil>());
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste UsecaseBase"', () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: true);
    final data = await returnResultUsecaseBase(parameters);
    switch (data) {
      case SuccessReturn():
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste UsecaseBase" isolate', () async {
    returnResultUsecaseBase = TesteUsecaseDirect(
      testeDependencia: true,
      runInIsolate: true,
    );
    final data = await returnResultUsecaseBase(parameters);
    switch (data) {
      case SuccessReturn():
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
    'Deve retornar um AppError com ErrorGeneric - Error General Feature',
    () async {
      returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
      final data = await returnResultUsecaseBase(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Teste UsecaseBase"));
        case ErrorReturn():
          expect(data.result, isA<ErrorGeneric>());
      }
    },
  );

  test(
    'Deve retornar um AppError com ErrorGeneric - Error General Feature isolate',
    () async {
      returnResultUsecaseBase = TesteUsecaseDirect(
        testeDependencia: false,
        runInIsolate: true,
      );
      final data = await returnResultUsecaseBase(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Teste UsecaseBase"));
        case ErrorReturn():
          expect(data.result, isA<ErrorGeneric>());
      }
    },
  );

  test('Deve retornar um success void data "true"', () async {
    when(() => datasource(parameters)).thenAnswer((_) => Future.value(true));
    final data = await returnResultUsecaseCallDataVoid(parameters);
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        expect(data.result, isA<ErrorGeneric>());
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
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "false"', () async {
    when(() => datasource(parameters)).thenAnswer((_) => Future.value(false));
    final data = await returnResultUsecaseCallDataVoid(parameters);
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric void', () async {
    when(() => datasource(parameters)).thenThrow(Exception());
    final data = await returnResultUsecaseCallDataVoid(parameters);
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
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
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric null', () async {
    when(() => datasource(parameters)).thenThrow(Exception());
    final data = await returnResultUsecaseCallDataNull(parameters);
    switch (data) {
      case SuccessReturn<Nil>():
        expect(data.result, isA<Nil>());
      case ErrorReturn<Nil>():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
    'Deve retornar um success com "Regra de negocio OK" data "true"',
    () async {
      when(() => datasource(parameters)).thenAnswer((_) => Future.value(true));
      final data = await returnResultUsecaseCallData(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Regra de negocio true"));
        case ErrorReturn():
          expect(data.result, isA<ErrorGeneric>());
      }
    },
  );

  test(
    'Deve retornar um success com "Regra de negocio OK" data "false"',
    () async {
      when(() => datasource(parameters)).thenAnswer((_) => Future.value(false));
      final data = await returnResultUsecaseCallData(parameters);
      switch (data) {
        case SuccessReturn():
          expect(data.result, equals("Regra de negocio false"));
        case ErrorReturn():
          expect(data.result, isA<ErrorGeneric>());
      }
    },
  );

  test('Deve retornar um AppError quando o datasource lança exceção', () async {
    when(() => datasource(parameters)).thenThrow(Exception());
    final data = await returnResultUsecaseCallData(parameters);
    switch (data) {
      case SuccessReturn():
        fail('Esperava ErrorReturn');
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('resultDatasource deve enriquecer a mensagem de erro com Cod. 02-1 '
      'preservando a original', () async {
    when(() => datasource(parameters)).thenThrow(Exception('boom'));
    final usecase = TesteUsecasePropagaErro(datasource: datasource);

    final data = await usecase(parameters);

    expect(data, isA<ErrorReturn<String>>());
    final message = (data as ErrorReturn<String>).result.message;
    expect(message, contains('teste parrametros')); // mensagem original
    expect(message, contains('Cod. 02-1')); // código do catch
    expect(message, contains('boom')); // contexto da exceção
  });

  group('Usecase executando em Isolate (datasource sendable)', () {
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
      'Deve retornar ErrorReturn com AppError contendo a mensagem de erro do isolate',
      () async {
        final usecase = TesteUsecaseLancaExcecao(runInIsolate: true);

        final data = await usecase(parameters);

        switch (data) {
          case SuccessReturn<String>():
            fail('Esperava ErrorReturn');
          case ErrorReturn<String>():
            expect(data.result, isA<ErrorGeneric>());
            expect(data.result.message, contains('Cod. IsolateCatch'));
            expect(data.result.message, contains('excecao direta no run'));
        }
      },
    );
  });

  group('monitorExecutionTime', () {
    test('desligado por padrão', () {
      expect(
        TesteUsecaseDirect(testeDependencia: true).monitorExecutionTime,
        isFalse,
      );
    });

    test(
      'com monitoramento ligado o resultado é idêntico (caminho direto)',
      () async {
        final usecase = TesteUsecaseDirect(
          testeDependencia: true,
          monitorExecutionTime: true,
        );
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
