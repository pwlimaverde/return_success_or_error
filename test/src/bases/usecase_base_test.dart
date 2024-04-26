import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/interfaces/parameters.dart';
import 'package:return_success_or_error/src/bases/usecase_base.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String nome;

  ParametersSalvarHeader({
    required this.nome,
  });

  @override
  AppError get error => ErrorGeneric(message: "teste parrametros");
}

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData(super.datasource);

  @override
  Future<ReturnSuccessOrError<String>> call(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    print("Teste retorno Datasource - $teste");
    switch (teste) {
      case SuccessReturn<bool>():
        if (teste.result) {
          return SuccessReturn<String>(success: "Regra de negocio true");
        } else {
          return SuccessReturn<String>(success: "Regra de negocio false");
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
      final teste = parameters.nome;
      return SuccessReturn<String>(
        success: teste,
      );
    } else {
      return ErrorReturn(
        error: parameters.error,
      );
    }
  }
}

final class TesteUsecaseCallDataVoid extends UsecaseBaseCallData<Unit, bool> {
  TesteUsecaseCallDataVoid(super.datasource);

  @override
  Future<ReturnSuccessOrError<Unit>> call(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    print("Teste retorno Datasource - $teste");
    switch (teste) {
      case SuccessReturn<bool>():
        if (teste.result) {
          print("Teste retorno opção 1 $teste");
          return SuccessReturn<Unit>(success: unit);
        } else {
          print("Teste retorno opção 2 $teste");
          return SuccessReturn<Unit>(success: unit);
        }

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
    print("teste void usecase");
    return SuccessReturn<Unit>(success: unit);
  }
}

final class TesteUsecaseCallDataNull extends UsecaseBaseCallData<Nil, bool> {
  TesteUsecaseCallDataNull(super.datasource);

  @override
  Future<ReturnSuccessOrError<Nil>> call(
    ParametersSalvarHeader parameters,
  ) async {
    final teste = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    print("Teste retorno Datasource - $teste");
    switch (teste) {
      case SuccessReturn<bool>():
        if (teste.result) {
          print("Teste retorno opção 1 $teste");
          return SuccessReturn<Nil>(success: nil);
        } else {
          print("Teste retorno opção 2 $teste");
          return SuccessReturn<Nil>(success: nil);
        }

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
    print("teste null usecase");
    return SuccessReturn<Nil>(success: nil);
  }
}

void main() {
  late Datasource<bool> datasource;
  final parameters = ParametersSalvarHeader(
    nome: 'Teste UsecaseBase',
  );
  late TesteUsecaseCallData returnResultUsecaseCallData;
  late TesteUsecaseDirect returnResultUsecaseBase;
  late TesteUsecaseCallDataVoid returnResultUsecaseCallDataVoid;
  late TesteUsecaseDirectVoid returnResultUsecaseBaseVoid;
  late TesteUsecaseCallDataNull returnResultUsecaseCallDataNull;
  late TesteUsecaseDirectNull returnResultUsecaseBaseNull;

  setUp(() {
    datasource = ReturnResultDatasourceMock();
    returnResultUsecaseCallData = TesteUsecaseCallData(datasource);
    returnResultUsecaseCallDataVoid = TesteUsecaseCallDataVoid(datasource);
    returnResultUsecaseCallDataNull = TesteUsecaseCallDataNull(datasource);
  });

  test('Deve retornar um success com "Teste Void"', () async {
    returnResultUsecaseBaseVoid = TesteUsecaseDirectVoid();
    final data = await returnResultUsecaseBaseVoid(
      NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Void" isolate', () async {
    returnResultUsecaseBaseVoid = TesteUsecaseDirectVoid();
    final data = await returnResultUsecaseBaseVoid.callIsolate(
      NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Null"', () async {
    returnResultUsecaseBaseNull = TesteUsecaseDirectNull();
    final data = await returnResultUsecaseBaseNull(
      NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste Null" isolate', () async {
    returnResultUsecaseBaseNull = TesteUsecaseDirectNull();
    final data = await returnResultUsecaseBaseNull.callIsolate(
      NoParams(error: ErrorGeneric(message: "teste parrametros")),
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste UsecaseBase"', () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: true);
    final data = await returnResultUsecaseBase(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste UsecaseBase" isolate', () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: true);
    final data = await returnResultUsecaseBase.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric - Error General Feature',
      () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
    final data = await returnResultUsecaseBase(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
      'Deve retornar um AppError com ErrorGeneric - Error General Feature isolate',
      () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
    final data = await returnResultUsecaseBase.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "true"', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallDataVoid(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "true" isolate', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallDataVoid.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "false"', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallDataVoid(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "false" isolate', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallDataVoid.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric void', () async {
    when(() => datasource(parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallDataVoid(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric void isolate', () async {
    when(() => datasource(parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallDataVoid.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Unit>():
        print(data.result);
        expect(data.result, isA<Unit>());
      case ErrorReturn<Unit>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success null data "true"', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallDataNull(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn<Nil>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success null data "true" isolate', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallDataNull.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn<Nil>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success null data "false"', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallDataNull(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn<Nil>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success null data "false" isolate', () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallDataNull.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn<Nil>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric null', () async {
    when(() => datasource(parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallDataNull(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn<Nil>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric null isolate', () async {
    when(() => datasource(parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallDataNull.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn<Nil>():
        print(data.result);
        expect(data.result, isA<Nil>());
      case ErrorReturn<Nil>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Regra de negocio OK" data "true"',
      () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallData(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Regra de negocio true"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Regra de negocio OK" data "true" isolate',
      () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallData.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Regra de negocio true"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Regra de negocio OK" data "false"',
      () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallData(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Regra de negocio false"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
      'Deve retornar um success com "Regra de negocio OK" data "false" isolate',
      () async {
    when(() => datasource(parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallData.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Regra de negocio false"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
      'Deve retornar um AppError com ErrorGeneric - Error General Feature. Cod. 03-1 --- Catch: Exception',
      () async {
    when(() => datasource(parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallData(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Regra de negocio OK"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test(
      'Deve retornar um AppError com ErrorGeneric - Error General Feature. Cod. 03-1 --- Catch: Exception isolate',
      () async {
    when(() => datasource(parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallData.callIsolate(
      parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data.result);
        expect(data.result, equals("Regra de negocio OK"));
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });
}
