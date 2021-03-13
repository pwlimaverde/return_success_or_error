import '../../../../retorno_sucesso_ou_erro_package.dart';
import '../../../utilitarios/Parametros.dart';
import '../repositories/retorno_resultado_repository.dart';
import '../usecases/retorno_resultado_usecase.dart';

class RetornoResultadoPresenter<T> {
  final Datasource<T, ParametrosRetornoResultado> datasource;
  final bool mostrarTempoExecucao;
  final String nomeFeature;

  RetornoResultadoPresenter({
    required this.datasource,
    required this.mostrarTempoExecucao,
    required this.nomeFeature,
  });

  Future<RetornoSucessoOuErro<T>> retornoResultado(
      {required ParametrosRetornoResultado parametros}) async {
    TempoExecucao tempo = TempoExecucao();
    if (mostrarTempoExecucao) {
      tempo.iniciar();
    }
    final resultado = await RetornoResultadoUsecase<T>(
      repositorio: RetornoResultadoRepositorio<T>(
        datasource: datasource,
      ),
    )(parametros: parametros);
    if (mostrarTempoExecucao) {
      tempo.terminar();
      print("Tempo de Execução do $nomeFeature: ${tempo.calcularExecucao()}ms");
    }
    return resultado;
  }
}
