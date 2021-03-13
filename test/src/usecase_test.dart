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
      parameters: NoParams(messageError: 'teste Usecase'),
      error: ErroInesperado(message: "teste error direto usecase"),
    );
    return result;
  }
}

class RepositoryMock extends Mock implements Repository<bool, NoParams> {}

void main() {
  late Repository<bool, NoParams> repository;
  late UseCase<bool, NoParams> checarConeccaoUseCase;

  setUp(() {
    repository = RepositoryMock();
    checarConeccaoUseCase = ChecarConeccaoUsecase(repository: repository);
  });

  test('Deve retornar um success com true', () async {
    when(repository)
        .calls(#call)
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(result: true)));
    final result = await checarConeccaoUseCase(
        parameters: NoParams(messageError: 'teste Usecase'));
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um success com false', () async {
    when(repository)
        .calls(#call)
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(result: false)));
    final result = await checarConeccaoUseCase(
        parameters: NoParams(messageError: 'teste Usecase'));
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um Erro com ErroInesperado com teste error', () async {
    when(repository).calls(#call).thenAnswer((_) => Future.value(
        ErrorReturn<bool>(error: ErroInesperado(message: "teste error"))));
    final result = await checarConeccaoUseCase(
        parameters: NoParams(messageError: 'teste Usecase'));
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });

  test('Deve retornar um Erro com ErroInesperado com error direto usecase',
      () async {
    when(repository).calls(#call).thenThrow(Exception());
    final result = await checarConeccaoUseCase(
        parameters: NoParams(messageError: 'teste Usecase'));
    print("teste result - ${result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    expect(result, isA<ErrorReturn<bool>>());
  });
}
