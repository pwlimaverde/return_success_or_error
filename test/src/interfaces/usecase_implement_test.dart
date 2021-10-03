import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/return_success_or_error.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error_class.dart';

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

  setUp(() {
    datasource = DatasourceMock();
    testeUsecaseImplement = TesteUsecaseImplement(datasource: datasource);
  });

  test('Deve retornar um success com true', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await testeUsecaseImplement(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto usecase",
        ),
        nameFeature: "Teste Usecase",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um success com false', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(false));
    final result = await testeUsecaseImplement(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto usecase",
        ),
        nameFeature: "Teste Usecase",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um Erro com ErroInesperado com error direto usecase',
      () async {
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await testeUsecaseImplement(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto usecase",
        ),
        nameFeature: "Teste Usecase",
        showRuntimeMilliseconds: true,
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}
