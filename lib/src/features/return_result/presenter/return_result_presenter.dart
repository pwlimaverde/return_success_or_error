import '../../../abstractions/datasource.dart';
import '../../../core/parameters.dart';
import '../../../core/return_success_or_error_class.dart';
import '../../../core/runtime_milliseconds.dart';
import '../repositories/return_result_repository.dart';
import '../usecases/return_result_usecase.dart';

///Type the ReturnResultPresenter with the type of data expected on success. The
///class expects to receive by injection of dependency the Datasource typed with
///the expected data type.
class ReturnResultPresenter<T> {
  final Datasource<T> datasource;

  ///Bool responsible for activating the log of the time elapsed in the
  ///execution of the function.
  final bool showRuntimeMilliseconds;

  ///String responsible for identifying the feature.
  final String nameFeature;

  ReturnResultPresenter({
    required this.datasource,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });

  Future<ReturnSuccessOrError<T>> call(
      {required ParametersReturnResult parameters}) async {
    RuntimeMilliseconds runtime = RuntimeMilliseconds();
    if (showRuntimeMilliseconds) {
      runtime.startScore();
    }

    ///Access usecase, and call the repository to call the datasource, handling
    ///the result to return the ReturnSuccessOrError.
    final result = await ReturnResultUsecase<T>(
      repository: ReturnResultRepository<T>(
        datasource: datasource,
      ),
    )(parameters: parameters);
    if (showRuntimeMilliseconds) {
      runtime.finishScore();
      print("Execution Time $nameFeature: ${runtime.calculateRuntime()}ms");
    }
    return result;
  }
}
