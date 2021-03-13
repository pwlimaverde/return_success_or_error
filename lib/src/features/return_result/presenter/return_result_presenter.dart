import '../../../abstractions/datasource.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';
import '../../../core/runtime_milliseconds.dart';
import '../repositories/return_result_repository.dart';
import '../usecases/return_result_usecase.dart';

class ReturnResultPresenter<T> {
  final Datasource<T, ParametersReturnResult> datasource;
  final bool mostrarRuntimeMilliseconds;
  final String nameFeature;

  ReturnResultPresenter({
    required this.datasource,
    required this.mostrarRuntimeMilliseconds,
    required this.nameFeature,
  });

  Future<ReturnSuccessOrError<T>> retornoResultado(
      {required ParametersReturnResult parameters}) async {
    RuntimeMilliseconds runtime = RuntimeMilliseconds();
    if (mostrarRuntimeMilliseconds) {
      runtime.startScore();
    }
    final result = await ReturnResultUsecase<T>(
      repository: ReturnResultRepository<T>(
        datasource: datasource,
      ),
    )(parameters: parameters);
    if (mostrarRuntimeMilliseconds) {
      runtime.finishScore();
      print("Execution Time $nameFeature: ${runtime.calculateRuntime()}ms");
    }
    return result;
  }
}
