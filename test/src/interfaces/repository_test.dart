import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/repository.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/mixins/return_datasource_mixin.dart';

class TestDatasourceMock extends Mock implements Datasource<bool> {}

class TesteRepositoryMock
    with ReturnDatasourcetMixin<bool>
    implements Repository<bool> {
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
  final Datasource<bool> datasource = TestDatasourceMock();
  final Repository<bool> repository = TesteRepositoryMock(
    datasource: datasource,
  );
  final ParametersReturnResult paramets = NoParams(
    error: ErrorReturnResult(
      message: "teste error direto usecase",
    ),
    nameFeature: "Teste Usecase",
    showRuntimeMilliseconds: true,
    isIsolate: false,
  );

  test('Deve retornar um success com true', () async {
    when(
      () => datasource(
        parameters: paramets,
      ),
    ).thenAnswer(
      (_) => Future.value(true),
    );
    final result = await repository(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(true));
  });

  test('Deve retornar um success com false', () async {
    when(
      () => datasource(
        parameters: paramets,
      ),
    ).thenAnswer(
      (_) => Future.value(false),
    );
    final result = await repository(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(false));
  });

  test('Deve retornar um Erro com ErrorReturnResult com Exception', () async {
    when(
      () => datasource(
        parameters: paramets,
      ),
    ).thenThrow(Exception());
    final result = await repository(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.error));
    expect(result.result, isA<Exception>());
  });
}
