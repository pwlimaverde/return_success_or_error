import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/interfaces/datasource.dart';
import 'package:return_success_or_error/src/interfaces/repository.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/features/return_result/repositories/return_result_repository.dart';

class FairebaseSalvarHeaderDatasourceMock extends Mock
    implements Datasource<bool> {}

void main() {
  late Datasource<bool> datasource;
  late Repository<bool> repository;
  final ParametersReturnResult paramets = NoParams(
    error: ErrorReturnResult(
      message: "teste error direto usecase",
    ),
    nameFeature: "Teste Usecase",
    showRuntimeMilliseconds: true,
  );

  setUp(() {
    datasource = FairebaseSalvarHeaderDatasourceMock();
    repository = ReturnResultRepository<bool>(datasource: datasource);
  });

  test('Deve retornar um success com true', () async {
    when(
      () => datasource(parameters: paramets),
    ).thenAnswer((_) => Future.value(true));
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
      () => datasource(parameters: paramets),
    ).thenAnswer((_) => Future.value(false));
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
    ).thenThrow(
      Exception(),
    );
    final result = await repository(
      parameters: paramets,
    );

    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.error));
    expect(result.result, isA<Exception>());
  });
}
