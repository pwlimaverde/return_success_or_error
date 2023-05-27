import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/features/return_result/usecases/return_result_usecase.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';

final class ReturnResultDatasourceMock extends Mock
    implements Datasource<bool> {}

final class TesteUsecase extends ReturnResultUsecase<String, bool> {
  TesteUsecase({required super.datasource});

  @override
  Future<({AppError? error, String? result})> call(
      {required ParametersReturnResult parameters}) async {
    final teste = await returResult(
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

void main() {
  late Datasource<bool> datasource;
  late ReturnResultUsecase<String, bool> returnResultUsecase;
  final parameters = NoParamsGeneral();

  setUp(() {
    datasource = ReturnResultDatasourceMock();
    returnResultUsecase = TesteUsecase(datasource: datasource);
  });

  test('Deve retornar um success com "Regra de negocio OK" data "true"',
      () async {
    when(() => datasource(parameters: parameters)).thenAnswer(
      (_) => Future.value(true),
    );
    final result = await returnResultUsecase(
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
    final result = await returnResultUsecase(
      parameters: parameters,
    );
    print(result.result);
    print(result.error);
    expect(result.result, equals("Regra de negocio OK"));
    expect(result.error, equals(null));
  });

  test(
      'Deve retornar um AppError com ErrorReturnResult - Error General Feature. Cod. 03-1 --- Catch: Exception',
      () async {
    when(() => datasource(parameters: parameters)).thenThrow(
      Exception(),
    );
    final result = await returnResultUsecase(
      parameters: parameters,
    );
    print(result.result);
    print(result.error);
    expect(result.result, equals(null));
    expect(result.error, isA<ErrorReturnResult>());
  });
}
