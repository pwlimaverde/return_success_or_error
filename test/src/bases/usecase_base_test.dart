import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/bases/usecase_base.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:return_success_or_error/src/interfaces/parameters.dart';
import 'package:test/test.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String nome;

  ParametersSalvarHeader({
    required this.nome,
  });

  @override
  AppError get error => const ErrorGeneric(message: "teste parrametros");
}

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(
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

  TesteUsecaseDirect({required this.testeDependencia});

  @override
  Future<ReturnSuccessOrError<String>> call(
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
  TesteUsecaseCallDataVoid({required super.datasource});

  @override
  Future<ReturnSuccessOrError<Unit>> call(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(parameters);
    switch (teste) {
      case SuccessReturn<bool>():
        return SuccessReturn<Unit>(success: unit);
      case ErrorReturn<bool>():
        return ErrorReturn<Unit>(error: parameters.error);
    }
  }
}

final class TesteUsecaseDirectVoid extends UsecaseBase<Unit> {
  @override
  Future<ReturnSuccessOrError<Unit>> call(
    NoParams parameters,
  ) async {
    return SuccessReturn<Unit>(success: unit);
  }
}

final class TesteUsecaseCallDataNull extends UsecaseBaseCallData<Nil, bool> {
  TesteUsecaseCallDataNull({required super.datasource});

  @override
  Future<ReturnSuccessOrError<Nil>> call(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(parameters);
    switch (teste) {
      case SuccessReturn<bool>():
        return SuccessReturn<Nil>(success: nil);
      case ErrorReturn<bool>():
        return ErrorReturn<Nil>(error: parameters.error);
    }
  }
}

final class TesteUsecaseDirectNull extends UsecaseBase<Nil> {
  @override
  Future<ReturnSuccessOrError<Nil>> call(
    NoParams parameters,
  ) async {
    return SuccessReturn<Nil>(success: nil);
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
    returnResultUsecaseCallDataVoid =
        TesteUsecaseCallDataVoid(datasource: datasource);
    returnResultUsecaseCallDataNull =
        TesteUsecaseCallDataNull(datasource: datasource);
  });

  test('Deve retornar um success com "Teste Void"', () async {
    returnResultUsecaseBaseVoid = TesteUsecaseDirectVoid();
    final data = await returnResultUsecaseBaseVoid(
      NoParams(error: const ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Void" isolate', () async {
    returnResultUsecaseBaseVoid = TesteUsecaseDirectVoid();
    final data = await returnResultUsecaseBaseVoid.callIsolate(
      NoParams(error: const ErrorGeneric(message: "teste parrametros")),
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
      NoParams(error: const ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Nil>():
        expect(data.result, isA<Nil>());
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Null" isolate', () async {
    returnResultUsecaseBaseNull = TesteUsecaseDirectNull();
    final data = await returnResultUsecaseBaseNull.callIsolate(
      NoParams(error: const ErrorGeneric(message: "teste parrametros")),
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
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: true);
    final data = await returnResultUsecaseBase.callIsolate(parameters);
    switch (data) {
      case SuccessReturn():
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric - Error General Feature',
      () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
    final data = await returnResultUsecaseBase(parameters);
    switch (data) {
      case SuccessReturn():
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
      'Deve retornar um AppError com ErrorGeneric - Error General Feature isolate',
      () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
    final data = await returnResultUsecaseBase.callIsolate(parameters);
    switch (data) {
      case SuccessReturn():
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "true"', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallDataVoid(parameters);
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "true" isolate', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallDataVoid.callIsolate(parameters);
    switch (data) {
      case SuccessReturn<Unit>():
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "false"', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
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
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
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

  test('Deve retornar um success com "Regra de negocio OK" data "true"',
      () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallData(parameters);
    switch (data) {
      case SuccessReturn():
        expect(data.result, equals("Regra de negocio true"));
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Regra de negocio OK" data "false"',
      () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallData(parameters);
    switch (data) {
      case SuccessReturn():
        expect(data.result, equals("Regra de negocio false"));
      case ErrorReturn():
        expect(data.result, isA<ErrorGeneric>());
    }
  });

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

  group('Helpers de ReturnSuccessOrError', () {
    test('fold deve resolver o caso de sucesso', () async {
      returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: true);
      final data = await returnResultUsecaseBase(parameters);

      final message = data.fold(
        onSuccess: (value) => 'OK: $value',
        onError: (error) => 'Fail: ${error.message}',
      );

      expect(message, equals('OK: Teste UsecaseBase'));
      expect(data.isSuccess, isTrue);
      expect(data.isError, isFalse);
      expect(data.getOrNull, equals('Teste UsecaseBase'));
    });

    test('fold deve resolver o caso de erro', () async {
      returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
      final data = await returnResultUsecaseBase(parameters);

      final message = data.fold(
        onSuccess: (value) => 'OK: $value',
        onError: (error) => 'Fail: ${error.message}',
      );

      expect(message, equals('Fail: teste parrametros'));
      expect(data.isError, isTrue);
      expect(data.isSuccess, isFalse);
      expect(data.getOrNull, isNull);
    });
  });
}
