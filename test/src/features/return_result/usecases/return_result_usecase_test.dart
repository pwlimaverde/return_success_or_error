import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_error/src/abstractions/repository.dart';
import 'package:return_success_or_error/src/abstractions/usecase.dart';
import 'package:return_success_or_error/src/core/errors.dart';
import 'package:return_success_or_error/src/core/parameters.dart';
import 'package:return_success_or_error/src/core/return_success_or_error_class.dart';
import 'package:return_success_or_error/src/core/runtime_milliseconds.dart';
import 'package:return_success_or_error/src/features/return_result/usecases/return_result_usecase.dart';

class ReturnResultRepositoryMock extends Mock
    implements Repository<bool, ParametersReturnResult> {}

void main() {
  late Repository<bool, ParametersReturnResult> repository;
  late UseCase<bool, ParametersReturnResult> returnResultUsecase;
  late RuntimeMilliseconds tempo;

  setUp(() {
    tempo = RuntimeMilliseconds();
    repository = ReturnResultRepositoryMock();
    returnResultUsecase = ReturnResultUsecase(repository: repository);
  });

  test('Deve retornar um success com true', () async {
    tempo.startScore();
    when(repository)
        .calls(#call)
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(result: true)));
    final result = await returnResultUsecase(
      parameters: ParametersSalvarHeader(
        corHeader: {
          "r": 60,
          "g": 60,
          "b": 60,
        },
        doc: 'testedoc',
        nome: 'novidades',
        prioridade: 1,
        user: 'paulo',
      ),
    );
    print("teste result - ${await result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    tempo.finishScore();
    print("Tempo de Execução do SalvarHeader: ${tempo.calculateRuntime()}ms");
    expect(result, isA<SuccessReturn<bool>>());
    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        true);
  });

  test('Deve retornar um success com false', () async {
    tempo.startScore();
    when(repository)
        .calls(#call)
        .thenAnswer((_) => Future.value(SuccessReturn<bool>(result: false)));
    final result = await returnResultUsecase(
      parameters: ParametersSalvarHeader(
        corHeader: {
          "r": 60,
          "g": 60,
          "b": 60,
        },
        doc: 'testedoc',
        nome: 'novidades',
        prioridade: 1,
        user: 'paulo',
      ),
    );
    print("teste result - ${await result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    tempo.finishScore();
    print("Tempo de Execução do SalvarHeader: ${tempo.calculateRuntime()}ms");
    expect(result, isA<SuccessReturn<bool>>());
    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        false);
  });

  test(
      'Deve retornar um ErroReturnResult com Erro ao salvar os dados do header Cod.02-1',
      () async {
    tempo.startScore();
    when(repository).calls(#call).thenAnswer(
          (_) => Future.value(
            ErrorReturn<bool>(
              error: ErroReturnResult(
                message: "Erro ao salvar os dados do header Cod.02-1",
              ),
            ),
          ),
        );
    final result = await returnResultUsecase(
      parameters: ParametersSalvarHeader(
        corHeader: {
          "r": 60,
          "g": 60,
          "b": 60,
        },
        doc: 'testedoc',
        nome: 'novidades',
        prioridade: 1,
        user: 'paulo',
      ),
    );
    print("teste result - ${await result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    tempo.finishScore();
    print("Tempo de Execução do SalvarHeader: ${tempo.calculateRuntime()}ms");
    expect(result, isA<ErrorReturn<bool>>());
  });

  test(
      'Deve retornar um ErroReturnResult, pela exeption do repository com Erro ao salvar os dados do header Cod.01-2',
      () async {
    tempo.startScore();
    when(repository).calls(#call).thenThrow(Exception());
    final result = await returnResultUsecase(
      parameters: ParametersSalvarHeader(
        corHeader: {
          "r": 60,
          "g": 60,
          "b": 60,
        },
        doc: 'testedoc',
        nome: 'novidades',
        prioridade: 1,
        user: 'paulo',
      ),
    );
    print("teste result - ${await result.fold(
      success: (value) => value.result,
      error: (value) => value.error,
    )}");
    tempo.finishScore();
    print("Tempo de Execução do SalvarHeader: ${tempo.calculateRuntime()}ms");
    expect(result, isA<ErrorReturn<bool>>());
  });
}

class ParametersSalvarHeader implements ParametersReturnResult {
  final String doc;
  final String nome;
  final int prioridade;
  final Map corHeader;
  final String user;

  ParametersSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
  });
  @override
  String get messageError => "Erro ao salvar os dados do Header Cod.01-1";
}
