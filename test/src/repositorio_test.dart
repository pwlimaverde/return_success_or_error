import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:retorno_success_ou_error_package/retorno_success_ou_error_package.dart';
import 'package:retorno_success_ou_error_package/src/core/repository.dart';

class ChecarConeccaoUsecase extends UseCase<bool, NoParams> {
  final Repository<bool, NoParams> repository;

  ChecarConeccaoUsecase({required this.repository});

  @override
  Future<ReturnSuccessOrError<bool>> call(
      {required NoParams parameters}) async {
    final result = await returnRepository(
      repository: repository,
      error: ErroInesperado(message: "teste error direto usecase"),
      parameters: NoParams(messageError: 'teste Usecase'),
    );
    return result;
  }
}

class ChecarConeccaoRepository extends Repository<bool, NoParams> {
  final Datasource<bool, NoParams> datasource;

  ChecarConeccaoRepository({required this.datasource});

  @override
  Future<ReturnSuccessOrError<bool>> call({required NoParams parameters}) {
    final result = returnDatasource(
      datasource: datasource,
      error: ErroInesperado(message: "teste error direto repository"),
      parameters: NoParams(messageError: 'teste Usecase'),
    );
    return result;
  }
}

class DatasourceMock extends Mock implements Datasource<bool, NoParams> {}

void main() {
  late Repository<bool, NoParams> repository;
  late Datasource<bool, NoParams> datasource;
  late UseCase<bool, NoParams> checarConeccaoUseCase;

  setUp(() {
    datasource = DatasourceMock();
    repository = ChecarConeccaoRepository(datasource: datasource);
    checarConeccaoUseCase = ChecarConeccaoUsecase(repository: repository);
  });

  test('Deve retornar um success com true', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await checarConeccaoUseCase(
        parameters: NoParams(messageError: 'teste Usecase'));
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um success com false', () async {
    checarConeccaoUseCase = ChecarConeccaoUsecase(repository: repository);
    when(datasource).calls(#call).thenAnswer((_) => Future.value(false));
    final result = await checarConeccaoUseCase(
        parameters: NoParams(messageError: 'teste Usecase'));
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test(
      'Deve retornar um Erro com ErroInesperado com teste error direto repository',
      () async {
    checarConeccaoUseCase = ChecarConeccaoUsecase(repository: repository);
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await checarConeccaoUseCase(
        parameters: NoParams(messageError: 'teste Usecase'));
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}
