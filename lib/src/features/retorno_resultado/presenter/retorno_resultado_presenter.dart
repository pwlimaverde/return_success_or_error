import '../../../../retorno_success_ou_error_package.dart';
import '../../../utilitarios/parameters.dart';
import '../repositories/retorno_result_repository.dart';
import '../usecases/retorno_result_usecase.dart';

class ReturnResultPresenter<T> {
  final Datasource<T, ParametersReturnResult> datasource;
  final bool mostrarRuntimeMilliseconds;
  final String nomeFeature;

  ReturnResultPresenter({
    required this.datasource,
    required this.mostrarRuntimeMilliseconds,
    required this.nomeFeature,
  });

  Future<ReturnSuccessOrError<T>> retornoResultado(
      {required ParametersReturnResult parameters}) async {
    RuntimeMilliseconds tempo = RuntimeMilliseconds();
    if (mostrarRuntimeMilliseconds) {
      tempo.iniciar();
    }
    final result = await ReturnResultUsecase<T>(
      repository: ReturnResultRepository<T>(
        datasource: datasource,
      ),
    )(parameters: parameters);
    if (mostrarRuntimeMilliseconds) {
      tempo.terminar();
      print("Tempo de Execução do $nomeFeature: ${tempo.calcularExecucao()}ms");
    }
    return result;
  }
}
