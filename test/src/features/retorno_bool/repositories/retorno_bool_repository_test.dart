import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retorno_success_ou_error_package/retorno_success_ou_error_package.dart';
import 'package:retorno_success_ou_error_package/src/features/retorno_result/repositories/retorno_result_repository.dart';
import 'package:retorno_success_ou_error_package/src/utilitarios/Parameters.dart';

class FairebaseSalvarHeaderDatasourceMock extends Mock
    implements Datasource<bool, ParametersReturnResult> {}

void main() {
  late Datasource<bool, ParametersReturnResult> datasource;
  late Repository<bool, ParametersReturnResult> repository;
  late RuntimeMilliseconds tempo;

  setUp(() {
    tempo = RuntimeMilliseconds();
    datasource = FairebaseSalvarHeaderDatasourceMock();
    repository = ReturnResultRepository<bool>(datasource: datasource);
  });

  test('Deve retornar um success com true', () async {
    tempo.iniciar();
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await repository(
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
    tempo.terminar();
    print("Tempo de Execução do SalvarHeader: ${tempo.calcularExecucao()}ms");
    expect(result, isA<SuccessReturn<bool>>());
    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        true);
  });

  test('Deve retornar um success com false', () async {
    tempo.iniciar();
    when(datasource).calls(#call).thenAnswer((_) => Future.value(false));
    final result = await repository(
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
    tempo.terminar();
    print("Tempo de Execução do SalvarHeader: ${tempo.calcularExecucao()}ms");
    expect(result, isA<SuccessReturn<bool>>());
    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        false);
  });

  test(
      'Deve retornar ErroReturnResult com Erro ao salvar os dados do header Cod.02-1',
      () async {
    tempo.iniciar();
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await repository(
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
    tempo.terminar();
    print("Tempo de Execução do SalvarHeader: ${tempo.calcularExecucao()}ms");
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
