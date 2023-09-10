import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
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
  ParametersBasic get basic => ParametersBasic(
        error: ErrorGeneric(message: "teste parrametros"),
        showRuntimeMilliseconds: true,
        isIsolate: true,
      );
}

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(
      {required ParametersSalvarHeader parameters}) async {
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
        return ErrorReturn<String>(error: parameters.basic.error);
    }
  }
}

final class TesteUsecaseDirect extends UsecaseBase<String> {
  final bool testeDependencia;

  TesteUsecaseDirect({required this.testeDependencia});

  @override
  Future<ReturnSuccessOrError<String>> call({
    required ParametersSalvarHeader parameters,
  }) async {
    if (testeDependencia) {
      final teste = parameters.nome;
      return SuccessReturn<String>(
        success: teste,
      );
    } else {
      return ErrorReturn(
        error: parameters.basic.error,
      );
    }
  }
}

final class TesteUsecaseCallDataVoid extends UsecaseBaseCallData<void, bool> {
  TesteUsecaseCallDataVoid({required super.datasource});

  @override
  Future<ReturnSuccessOrError<void>> call(
      {required ParametersSalvarHeader parameters}) async {
    final teste = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    print("Teste retorno Datasource - $teste");
    switch (teste) {
      case SuccessReturn<bool>():
        if (teste.result) {
          print("Teste retorno opção 1 $teste");
          return SuccessReturn<void>.voidResult();
        } else {
          print("Teste retorno opção 2 $teste");
          return SuccessReturn<void>.voidResult();
        }

      case ErrorReturn<bool>():
        return ErrorReturn<void>(error: parameters.basic.error);
    }
  }
}

final class TesteUsecaseDirectVoid extends UsecaseBase<void> {
  @override
  Future<ReturnSuccessOrError<void>> call(
      {required NoParamsGeneral parameters}) async {
    print("teste void usecase");
    return SuccessReturn<void>.voidResult();
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

  setUp(() {
    datasource = ReturnResultDatasourceMock();
    returnResultUsecaseCallData = TesteUsecaseCallData(datasource: datasource);
    returnResultUsecaseCallDataVoid =
        TesteUsecaseCallDataVoid(datasource: datasource);
  });

  test('Deve retornar um success com "Teste Void"', () async {
    returnResultUsecaseBaseVoid = TesteUsecaseDirectVoid();
    final data = await returnResultUsecaseBaseVoid.callIsolate(
        parameters: NoParamsGeneral());
    switch (data) {
      case SuccessReturn():
        print(data);
        expect(data, isA<void>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Teste UsecaseBase"', () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: true);
    final data =
        await returnResultUsecaseBase.callIsolate(parameters: parameters);
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
    final data =
        await returnResultUsecaseBase.callIsolate(parameters: parameters);
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
    when(() => datasource(parameters: parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallDataVoid(
      parameters: parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data);
        expect(data, isA<void>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success void data "false"', () async {
    when(() => datasource(parameters: parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallDataVoid(
      parameters: parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data);
        expect(data, isA<void>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric void', () async {
    when(() => datasource(parameters: parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallDataVoid(
      parameters: parameters,
    );
    switch (data) {
      case SuccessReturn():
        print(data);
        expect(data, isA<void>());
      case ErrorReturn():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um success com "Regra de negocio OK" data "true"',
      () async {
    when(() => datasource(parameters: parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final data = await returnResultUsecaseCallData(
      parameters: parameters,
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
    when(() => datasource(parameters: parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final data = await returnResultUsecaseCallData(
      parameters: parameters,
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
    when(() => datasource(parameters: parameters)).thenThrow(
      Exception(),
    );
    final data = await returnResultUsecaseCallData(
      parameters: parameters,
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
