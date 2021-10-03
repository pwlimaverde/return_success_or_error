import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/interfaces/repository.dart';
import 'package:return_success_or_error/src/interfaces/usecase.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error_class.dart';

class RepositoryMock extends Mock implements Repository<bool> {}

class TesteUsecaseMock extends UseCase<bool> {
  final Repository<bool> repository;

  TesteUsecaseMock({required this.repository});

  @override
  Future<ReturnSuccessOrError<bool>> call(
      {required ParametersReturnResult parameters}) async {
    final result = await returnRepository(
      repository: repository,
      parameters: parameters,
    );
    return result;
  }
}

void main() {
  late Repository<bool> repository;
  late UseCase<bool> usecase;

  setUp(() {
    repository = RepositoryMock();
    usecase = TesteUsecaseMock(repository: repository);
  });

  test('Deve retornar um success com true', () async {
    when(repository)
        .calls(#call)
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(result: true)));
    final result = await usecase(
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
    when(repository)
        .calls(#call)
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(result: false)));
    final result = await usecase(
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

  test('Deve retornar um Erro com ErroInesperado com teste error', () async {
    when(repository).calls(#call).thenAnswer((_) => Future.value(
        ErrorReturn<bool>(error: ErrorReturnResult(message: "teste error"))));
    final result = await usecase(
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

  test('Deve retornar um Erro com ErroInesperado com error direto usecase',
      () async {
    when(repository).calls(#call).thenThrow(Exception());
    final result = await usecase(
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
