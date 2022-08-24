import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/interfaces/repository.dart';
import 'package:return_success_or_error/src/interfaces/usecase.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error.dart';
import 'package:return_success_or_error/src/features/return_result/usecases/return_result_usecase.dart';

class ParametersSalvarHeader implements ParametersReturnResult {
  final String doc;
  final String nome;
  final int prioridade;
  final Map corHeader;
  final String user;
  final String nameFeature;
  final bool showRuntimeMilliseconds;

  ParametersSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
    required this.nameFeature,
    required this.showRuntimeMilliseconds,
  });

  @override
  AppError get error =>
      ErrorReturnResult(message: "Erro ao salvar os dados do Header");
}

class ReturnResultRepositoryMock extends Mock implements Repository<bool> {}

void main() {
  late Repository<bool> repository;
  late UseCase<bool> returnResultUsecase;
  final parameters = ParametersSalvarHeader(
    corHeader: {
      "r": 60,
      "g": 60,
      "b": 60,
    },
    doc: 'testedoc',
    nome: 'novidades',
    prioridade: 1,
    user: 'paulo',
    nameFeature: 'Teste Header',
    showRuntimeMilliseconds: true,
  );

  setUp(() {
    repository = ReturnResultRepositoryMock();
    returnResultUsecase = ReturnResultUsecase<bool>(
      repository: repository,
    );
  });

  test('Deve retornar um success com true', () async {
    when(() => repository(parameters: parameters))
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(success: true)));
    final result = await returnResultUsecase(
      parameters: parameters,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(true));
  });

  test('Deve retornar um success com false', () async {
    when(() => repository(parameters: parameters))
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(success: false)));
    final result = await returnResultUsecase(
      parameters: parameters,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.success));
    expect(result.result, equals(false));
  });

  test(
      'Deve retornar um ErrorReturnResult com Erro ao salvar os dados do header Cod.02-1',
      () async {
    when(() => repository(parameters: parameters)).thenAnswer(
      (_) => Future.value(
        ErrorReturn<bool>(
          error: ErrorReturnResult(
            message: "Erro ao salvar os dados do header Cod.02-1",
          ),
        ),
      ),
    );
    final result = await returnResultUsecase(
      parameters: parameters,
    );
    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.error));
    expect(result, isA<ErrorReturn<bool>>());
  });

  test(
      'Deve retornar um ErrorReturnResult, pela exeption do repository com Erro ao salvar os dados do header Cod.01-3',
      () async {
    when(
      () => repository(
        parameters: parameters,
      ),
    ).thenThrow(
      Exception(),
    );
    final result = await returnResultUsecase(
      parameters: parameters,
    );

    print(result.status);
    print(result.result);
    expect(result.status, equals(StatusResult.error));
    expect(result, isA<ErrorReturn<bool>>());
  });
}
