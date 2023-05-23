import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/interfaces/repository.dart';
import 'package:return_success_or_error/src/interfaces/usecase.dart';
import 'package:return_success_or_error/src/interfaces/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/mixins/return_repository_mixin.dart';

class RepositoryMock extends Mock implements Repository<bool> {}

class TesteUsecaseMock extends UseCase<bool> with ReturnRepositoryMixin<bool> {
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

  final ParametersReturnResult paramets = NoParams(
    error: ErrorReturnResult(
      message: "teste error direto usecase",
    ),
    nameFeature: "Teste Usecase",
    showRuntimeMilliseconds: true,
    isIsolate: true,
  );

  setUp(() {
    repository = RepositoryMock();
    usecase = TesteUsecaseMock(repository: repository);
  });

  test('Deve retornar um success com true', () async {
    when(() => repository(parameters: paramets))
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(success: true)));
    final result = await usecase(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(true));
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um success com false', () async {
    when(() => repository(parameters: paramets))
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(success: false)));
    final result = await usecase(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(false));
    expect(result, isA<SuccessReturn<bool>>());
  });

  test('Deve retornar um Erro com ErroInesperado com teste error', () async {
    when(() => repository(parameters: paramets)).thenAnswer(
      (_) => Future.value(
        ErrorReturn<bool>(
          error: ErrorReturnResult(message: "teste error"),
        ),
      ),
    );
    final result = await usecase(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.error));
    expect(result, isA<ErrorReturn<bool>>());
  });

  test('Deve retornar um Erro com ErrorReturnResult com Exception', () async {
    when(
      () => repository(parameters: paramets),
    ).thenThrow(Exception());
    final result = await usecase(
      parameters: paramets,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.error));
    expect(result.result, isA<Exception>());
  });
}
