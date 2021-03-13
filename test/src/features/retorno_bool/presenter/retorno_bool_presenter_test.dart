import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retorno_sucesso_ou_erro_package/retorno_sucesso_ou_erro_package.dart';
import 'package:retorno_sucesso_ou_erro_package/src/features/retorno_resultado/presenter/retorno_resultado_presenter.dart';
import 'package:retorno_sucesso_ou_erro_package/src/utilitarios/Parametros.dart';

class FairebaseSalvarHeaderDatasourceMock extends Mock
    implements Datasource<bool, ParametrosRetornoResultado> {}

void main() {
  late Datasource<bool, ParametrosRetornoResultado> datasource;

  setUp(() {
    datasource = FairebaseSalvarHeaderDatasourceMock();
  });

  test('Deve retornar um sucesso com true', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(true));
    final result = await RetornoResultadoPresenter<bool>(
      datasource: datasource,
      mostrarTempoExecucao: true,
      nomeFeature: 'SalvarHeader',
    ).retornoResultado(
      parametros: ParametrosSalvarHeader(
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
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<SucessoRetorno<bool>>());
    expect(
        result.fold(
          sucesso: (value) => value.resultado,
          erro: (value) => value.erro,
        ),
        true);
  });

  test('Deve retornar sucesso com false', () async {
    when(datasource).calls(#call).thenAnswer((_) => Future.value(false));
    final result = await RetornoResultadoPresenter<bool>(
      datasource: datasource,
      mostrarTempoExecucao: true,
      nomeFeature: 'SalvarHeader',
    ).retornoResultado(
      parametros: ParametrosSalvarHeader(
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
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<SucessoRetorno<bool>>());
    expect(
        result.fold(
          sucesso: (value) => value.resultado,
          erro: (value) => value.erro,
        ),
        false);
  });

  test(
      'Deve retornar ErroRetornoResultado com Erro ao salvar os dados do header Cod.02-1',
      () async {
    when(datasource).calls(#call).thenThrow(Exception());
    final result = await RetornoResultadoPresenter<bool>(
      datasource: datasource,
      mostrarTempoExecucao: true,
      nomeFeature: 'SalvarHeader',
    ).retornoResultado(
      parametros: ParametrosSalvarHeader(
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
      sucesso: (value) => value.resultado,
      erro: (value) => value.erro,
    )}");
    expect(result, isA<ErroRetorno<bool>>());
  });
}

class ParametrosSalvarHeader implements ParametrosRetornoResultado {
  final String doc;
  final String nome;
  final int prioridade;
  final Map corHeader;
  final String user;

  ParametrosSalvarHeader({
    required this.doc,
    required this.nome,
    required this.prioridade,
    required this.corHeader,
    required this.user,
  });
  @override
  String get mensagemErro => "Erro ao salvar os dados do Header";
}
