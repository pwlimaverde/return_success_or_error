import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:return_success_or_errorr/src/abstractions/datasource.dart';
import 'package:return_success_or_errorr/src/core/parameters.dart';
import 'package:return_success_or_errorr/src/core/return_success_or_error_class.dart';
import 'package:return_success_or_errorr/src/features/return_result/presenter/return_result_presenter.dart';

class FairebaseSalvarHeaderDatasourceMock extends Mock
    implements Datasource<bool, ParametersReturnResult> {}

void main() {
  late Datasource<bool, ParametersReturnResult> datasource;

  setUp(() {
    datasource = FairebaseSalvarHeaderDatasourceMock();
  });

  test('Deve retornar um success com true', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await ReturnResultPresenter<bool>(
      datasource: datasource,
      mostrarRuntimeMilliseconds: true,
      nameFeature: 'SalvarHeader',
    ).retornoResultado(
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
    expect(result, isA<SuccessReturn<bool>>());
    expect(
        result.fold(
          success: (value) => value.result,
          error: (value) => value.error,
        ),
        true);
  });

  test('Deve retornar success com false', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(false));
    final result = await ReturnResultPresenter<bool>(
      datasource: datasource,
      mostrarRuntimeMilliseconds: true,
      nameFeature: 'SalvarHeader',
    ).retornoResultado(
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
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await ReturnResultPresenter<bool>(
      datasource: datasource,
      mostrarRuntimeMilliseconds: true,
      nameFeature: 'SalvarHeader',
    ).retornoResultado(
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
  String get messageError => "Erro ao salvar os dados do Header";
}
