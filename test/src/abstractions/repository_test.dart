import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/abstractions/datasource.dart';
import 'package:return_success_or_error/src/abstractions/repository.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error_class.dart';

class DatasourceMock extends Mock implements Datasource<bool> {}

class TesteRepositoryMock extends Repository<bool> {
  final Datasource<bool> datasource;

  TesteRepositoryMock({required this.datasource});

  @override
  Future<ReturnSuccessOrError<bool>> call(
      {required ParametersReturnResult parameters}) {
    final result = returnDatasource(
      datasource: datasource,
      parameters: parameters,
    );
    return result;
  }
}

void main() {
  late Repository<bool> repository;
  late Datasource<bool> datasource;

  setUp(() {
    datasource = DatasourceMock();
    repository = TesteRepositoryMock(datasource: datasource);
  });

  test('Deve retornar um success com true', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await repository(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto usecase",
        ),
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
    final result = await repository(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto usecase",
        ),
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um Erro com ErrorReturnResult com Exception', () async {
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await repository(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto usecase",
        ),
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });

  test('Deve retornar um Erro com ErrorReturnResult com erro datasource',
      () async {
    when(datasource)
        .calls(#call)
        .thenThrow(ErrorReturnResult(message: "erro datasource"));
    final result = await repository(
      parameters: NoParams(
        error: ErrorReturnResult(
          message: "teste error direto usecase",
        ),
      ),
    );
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}
