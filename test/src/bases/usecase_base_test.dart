import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/bases/usecase_base.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData({required super.datasource});

  @override
  Future<ReturnSuccessOrError<String>> call(
      {required ParametersReturnResult parameters}) async {
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
    required ParametersReturnResult parameters,
  }) async {
    if (testeDependencia) {
      final teste = "Teste UsecaseBase";
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

void main() {
  late Datasource<bool> datasource;
  late UsecaseBaseCallData<String, bool> returnResultUsecaseCallData;
  late UsecaseBase<String> returnResultUsecaseBase;
  final parameters = NoParamsGeneral();

  setUp(() {
    datasource = ReturnResultDatasourceMock();
    returnResultUsecaseCallData = TesteUsecaseCallData(datasource: datasource);
  });

  test('Deve retornar um success com "Teste UsecaseBase"', () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: true);
    final data = await returnResultUsecaseBase(
      parameters: parameters,
    );
    switch (data) {
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn<String>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });

  test('Deve retornar um AppError com ErrorGeneric - Error General Feature',
      () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
    final data = await returnResultUsecaseBase(
      parameters: parameters,
    );
    switch (data) {
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Teste UsecaseBase"));
      case ErrorReturn<String>():
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
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Regra de negocio true"));
      case ErrorReturn<String>():
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
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Regra de negocio false"));
      case ErrorReturn<String>():
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
      case SuccessReturn<String>():
        print(data.result);
        expect(data.result, equals("Regra de negocio OK"));
      case ErrorReturn<String>():
        print(data.result);
        expect(data.result, isA<ErrorGeneric>());
    }
  });
}
