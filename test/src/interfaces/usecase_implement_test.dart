import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/usecase_implement.dart';

class DatasourceMock<bool> extends Mock implements Datasource<bool> {}

class TesteUsecaseImplement<bool> extends UseCaseImplement<bool> {
  final Datasource<bool> datasource;

  TesteUsecaseImplement({required this.datasource});

  @override
  Future<ReturnSuccessOrError<bool>> call(
      {required ParametersReturnResult parameters}) async {
    final result = await returnUseCase(
      parameters: parameters,
      datasource: datasource,
    );
    return result;
  }
}

void main() {
  late Datasource<bool> datasource;
  late TesteUsecaseImplement<bool> testeUsecaseImplement;
  final ParametersReturnResult paramets = NoParams(
    error: ErrorReturnResult(
      message: "teste error direto usecase",
    ),
    nameFeature: "Teste Usecase",
    showRuntimeMilliseconds: true,
    isIsolate: false,
  );

  setUp(() {
    datasource = DatasourceMock();
    testeUsecaseImplement = TesteUsecaseImplement(datasource: datasource);
  });

  test('Deve retornar um success com true', () async {
    when(
      () => datasource(parameters: paramets),
    ).thenAnswer((_) => Future.value(true));
    final result = await testeUsecaseImplement(
      parameters: paramets,
    );

    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(true));
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um success com false', () async {
    when(
      () => datasource(parameters: paramets),
    ).thenAnswer((_) => Future.value(false));
    final result = await testeUsecaseImplement(
      parameters: paramets,
    );

    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(false));
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um Erro com ErrorReturnResult com Exception', () async {
    when(
      () => datasource(parameters: paramets),
    ).thenThrow(Exception());
    final result = await testeUsecaseImplement(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.error));
    expect(result.result, isA<Exception>());
  });
}
