import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/bases/usecase_base.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

final class TesteUsecaseCallData extends UsecaseBaseCallData<String, bool> {
  TesteUsecaseCallData({required super.datasource});

  @override
  Future<({AppError? error, String? result})> call(
      {required ParametersReturnResult parameters}) async {
    final teste = await resultDatasource(
      parameters: parameters,
      datasource: datasource,
    );
    print("Teste retorno Datasource - $teste");
    if (teste.error == null) {
      return (
        result: "Regra de negocio OK",
        error: null,
      );
    } else {
      return (
        result: null,
        error: parameters.basic.error,
      );
    }
  }
}

final class TesteUsecaseDirect extends UsecaseBase<String> {
  final bool testeDependencia;

  TesteUsecaseDirect({required this.testeDependencia});
  @override
  Future<({AppError? error, String? result})> call(
      {required ParametersReturnResult parameters}) async {
    if (testeDependencia) {
      final teste = "Teste UsecaseBase";
      return (result: teste, error: null);
    } else {
      return (result: null, error: parameters.basic.error);
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
    final result = await returnResultUsecaseBase(
      parameters: parameters,
    );
    print(result.result);
    print(result.error);
    expect(result.result, equals("Teste UsecaseBase"));
    expect(result.error, equals(null));
  });

  test('Deve retornar um AppError com ErrorGeneric - Error General Feature',
      () async {
    returnResultUsecaseBase = TesteUsecaseDirect(testeDependencia: false);
    final result = await returnResultUsecaseBase(
      parameters: parameters,
    );
    print(result.result);
    print(result.error);
    expect(result.result, equals(null));
    expect(result.error, isA<ErrorGeneric>());
  });

  test('Deve retornar um success com "Regra de negocio OK" data "true"',
      () async {
    when(() => datasource(parameters: parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final result = await returnResultUsecaseCallData(
      parameters: parameters,
    );
    print(result.result);
    print(result.error);
    expect(result.result, equals("Regra de negocio OK"));
    expect(result.error, equals(null));
  });

  test('Deve retornar um success com "Regra de negocio OK" data "false"',
      () async {
    when(() => datasource(parameters: parameters)).thenAnswer(
      (_) => Future.value(false),
    );
    final result = await returnResultUsecaseCallData(
      parameters: parameters,
    );
    print(result.result);
    print(result.error);
    expect(result.result, equals("Regra de negocio OK"));
    expect(result.error, equals(null));
  });

  test(
      'Deve retornar um AppError com ErrorGeneric - Error General Feature. Cod. 03-1 --- Catch: Exception',
      () async {
    when(() => datasource(parameters: parameters)).thenThrow(
      Exception(),
    );
    final result = await returnResultUsecaseCallData(
      parameters: parameters,
    );
    print(result.result);
    print(result.error);
    expect(result.result, equals(null));
    expect(result.error, isA<ErrorGeneric>());
  });
}
